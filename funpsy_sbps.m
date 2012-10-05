function psess=funpsy_sbps(cfg)

%FUNPSY_SBPS Takes a list of seeds/ROIs and computes full differential phase synchrony between each pair of seeds/ROIs
%	psess=funpsy_dfps(cfg) stores the results in out.results.dfps
%	'cfg' is a struct with mandatory and optional fields
%	    cfg.sessionfile=string with the path of the sessionfile
%	    cfg.rois=string array with a list of ROIs, at least 2 needed
%	OPTIONAL:
%	    cfg.pairwise=1

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


processID='funpsy_sbps>>>';

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
% Did we compute SBPS already? Should we recompute it?
isinit=0;
if(isfield(psess.history,'sbps'))
    if(psess.history.sbps == 1)
        isinit=1;
    end
end       
overexists=isfield(cfg,'overwrite');
overwrite=0;
if(overexists==1)
    overwrite=cfg.overwrite;
end
if(isinit==1 && overwrite == 1)
    fprintf('%s\n',[processID 'The SBPS data will be overwritten.'])
    psess.history.svps=0;
end
if(isinit==1 && overwrite == 0)
    fprintf('%s\n',[processID 'SBPS data exist and will not be overwritten.']);
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
	
outpath=[psess.outpath 'results/sbps/'];
disp('Creating folder')
mkdir(outpath)
% to add here a check if matlabpool is open
parfor roi=1:(R-1)
	funpsy_parsbps(roi,outpath,psess,data)
end

fprintf('\n%s\n',[processID 'Seed based phase synchrony computed'])

psess.history.sbps=1;
psess.results.sbps=outpath;
disp([processID 'Updating session: ' psess.session_name]);
save(psess.sessionfile,'psess');
disp([processID '...done']);

	
