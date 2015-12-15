function psess=funpsy_makeroidata(cfg)
%FUNPSY_MAKEROIDATA Runs a principal component analysis for each ROI for a subject group
%       psess=funpsy_makeroidata(cfg) returns the extracted first principal component for each region of interest
%       'cfg' is a struct with mandatory and optional field
%           cfg.rois=string array with a list of ROIs
%           cfg.sessionfile=string with the path of the sessionfile
%       OPTIONAL:
%           cfg.rois='HarOx-2mm-50'; pre-computed ROIs based on anatomical parcellation
%           cfg.overwrite=1 (or 0, default);
%               if 1, the previously done ROIs will be overwritten 
%           cfg.usegroupmask=1 (or 0, default);
%               if 1, the function will exclude voxels that are not included in the group mask
%           cfg.sphere=0
%               if 1, uses a sphere centered in the centroid of the ROI
%           cfg.radius=0

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


processID='funpsy_makeroidata >> ';
if(nargin == 0)
    error([processID 'Function called with no parameters, please specify cfg parameters.']);
end

% Test: does the session file exist?
psess=funpsy_loadsession(cfg,processID);        % also loads the session file
% Test: was the session initialized?
funpsy_testinit(psess,processID);
% Test: was the analytic signal created?
funpsy_testAS(psess,processID);

%% FUNCTION SPECIFIC PARAMETERS TEST 
% more to be added

%% cfg.overwrite
% Test: do we already have  the rois been done already? Do we want to overwrite them?
isinit=0;
if(isfield(psess.history,'roidata'))
    if(psess.history.roidata == 1)
        isinit=1;
    end
end       
overexists=isfield(cfg,'overwrite');
overwrite=0;
if(overexists==1)
    overwrite=cfg.overwrite;
end
if(isinit==1 && overwrite == 1)
    fprintf('%s\n',[processID 'The ROI data will be overwritten.'])
    psess.history.roidata=0;
end
if(isinit==1 && overwrite == 0)
    fprintf('%s\n',[processID 'ROI data exist and will not be overwritten.']);
    return
end

%% cfg.usegroupmask
% Options: do we want to exclude voxels that are not in the group mask?
if(isfield(cfg,'usegroupmask'))
    if(cfg.usegroupmask == 1)
        usegroup=1;
    end
end       
% Test: did we create a group mask?
funpsy_testGroupmask(psess,processID);

%% cfg.sphere
% add here

%% cfg.usemean
usemean=0;
if(isfield(cfg,'usemean'))
	usemean=cfg.usemean;
end


%% cfg.rois
if(isfield(cfg,'rois'))
    rois=cfg.rois;
    if(isa(rois,'char'))        % if we are passing a string
        % add here a test that it is a valid string
        temp=load(rois);
        rois=temp.rois;
    else
        % otherwise we are passing a roi struct
        % add here some tests on the struct
    end
end
    
    
%% Processing
roibasepath=[psess.outpath 'ROIdata/'];
if(~exist(roibasepath))
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(roibasepath);
    if(SUCCESS)
        disp([processID 'Folder ' roibasepath ' created']);
    else
        error([processID 'Could not create ' roibasepath '.' MESSAGE]);
    end
end

R=length(rois);
load(psess.groupmask);
for s=1:psess.Nsubj
    disp([processID 'Processing subj ' num2str(s)]);
    for t=1:psess.T
        img=load([psess.outdata{s} '/' num2str(t) '.mat']);
        if(t==1)
            sIMG=zeros(size(img.Hvol,1),size(img.Hvol,2),size(img.Hvol,3),psess.T);
        end
        sIMG(:,:,:,t)=real(img.Hvol);    % only the real part
    end
    psess.roidata{s}=[roibasepath num2str(s) '/'];
    mkdir(psess.roidata{s});
    for r=1:R;
        roi=rois(r);
	cen=round(roi.centroid);
	if(groupmask(cen(1),cen(2),cen(3))==0)
		disp([processID 'Warning: ROI ' num2str(r) ' is out of group mask']);
	end
        M=size(roi.map,1);
        ts=zeros(psess.T,M);    % contains all time series for this roi
        for m=1:M
            voxel=roi.map(m,:);
            ts(:,m)=squeeze(sIMG(voxel(1),voxel(2),voxel(3),:));
        end    
        
        if(M > 1)
			if(usemean == 0 )
				% run PCA
				[roits,dpc,upc,vpc,perc] = funpsy_princomp(ts);
				if(perc(1)<0.5)
					warning([processID 'The first pca explains ' num2str(round(perc(1)*100)) '% of the variance. You might want to reduce the size of ROI #' num2str(r)]);
				end
			else
				roits=mean(ts,2);
			end
		else
            roits=ts;
        end
        
	roits=hilbert(roits);
        fprintf('%s',['..#' num2str(r)]);
        save([psess.roidata{s} num2str(r) '.mat'],'roits');
	clear roits;
    end
    fprintf('\n%s\n',[processID 'All rois extracted for subj ' num2str(s) ]);
end

psess.history.roidata = 1;
psess.rois=rois;
disp([processID 'Updating session: ' psess.session_name]);
save(psess.sessionfile,'psess');
disp([processID '...done']);

