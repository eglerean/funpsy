function psess=funpsy_isbps(cfg)

%FUNPSY_SBPS Takes a list of seeds/ROIs and computes full differential phase synchrony between each pair of seeds/ROIs as well as intersubject synchronization
%	psess=funpsy_isbps(cfg) stores the results in psess.results.isbps
%	'cfg' is a struct with mandatory and optional fields
%	    cfg.sessionfile=string with the path of the sessionfile
%	    cfg.rois=string array with a list of ROIs, at least 2 needed
%	OPTIONAL:
%	    cfg.pairwise=1

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


processID='funpsy_isbps>>>';

load(cfg.sessionfile)
	
	
% Test: does the session file exist?
psess=funpsy_loadsession(cfg,processID);        % also loads the session file
% Test: was the session initialized?
funpsy_testinit(psess,processID);
% Test: was the analytic signal created?
funpsy_testAS(psess,processID);
% Test: do we already have the roi data?
funpsy_testROIdata(psess,processID);
	
%% FUNCTION SPECIFIC PARAMETERS TEST 
% more to be added

%% cfg.overwrite
% Did we compute ISBPS already? Should we recompute it?
isinit=0;
if(isfield(psess.history,'isbps'))
    if(psess.history.isbps == 1)
        isinit=1;
    end
end       
overexists=isfield(cfg,'overwrite');
overwrite=0;
if(overexists==1)
    overwrite=cfg.overwrite;
end
if(isinit==1 && overwrite == 1)
    fprintf('%s\n',[processID 'The ISBPS data will be overwritten.'])
    psess.history.svps=0;
end
if(isinit==1 && overwrite == 0)
    fprintf('%s\n',[processID 'ISBPS data exist and will not be overwritten.']);
    return
end

%% Processing

R=length(psess.rois);
data=zeros(psess.T,R,psess.Nsubj);
for sub=1:psess.Nsubj
	disp(num2str(sub))
	for r=1:R
		temp=load([psess.roidata{sub} '/' num2str(r) '.mat']);
		data(:,r,sub)=angle(temp.roits);
	end
end
	
outpath=[psess.outpath 'results/isbps/'];
disp('Creating folder')
mkdir(outpath)
% to add here a check if matlabpool is open
parfor roi=1:(R-1)
	funpsy_parisbps(roi,outpath,psess,data)
end

fprintf('\n%s\n',[processID 'Intersubject Seed based phase synchrony computed'])

psess.history.isbps=1;
psess.results.isbps=outpath;
disp([processID 'Updating session: ' psess.session_name]);
save(psess.sessionfile,'psess');
disp([processID '...done']);

	
