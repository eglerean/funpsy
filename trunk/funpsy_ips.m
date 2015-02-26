function psess=funpsy_ips(cfg)
%FUNPSY_IPS Computes functional intersubject phase synchrony between each pair of seeds/rois
%       psess=funpsy_ips(cfg) stores the results in out.results.ips
%          	cfg.sessionfile=string with the path of the sessionfile
%          	cfg.rois=string array with a list of ROIs
%       OPTIONAL:
%          	cfg.overwrite=0
%               if 1, the previously done IPS data will be overwritten
%			cfg.useppc=0
%				if 0, it computes phase synchrony across subjects. By default it is set to one, i.e. use pairwise phase consistency (unbiased)

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%



processID='funpsy_ips >> ';

% Test: does the session file exist?
psess=funpsy_loadsession(cfg,processID);        % also loads the session file
% Test: was the session initialized?
funpsy_testinit(psess,processID);
% Test: was the analytic signal created?
funpsy_testAS(psess,processID);

%% FUNCTION SPECIFIC PARAMETERS TEST 
% more to be added

%% cfg.overwrite
% Did we compute IPS already? Should we recompute it?
isinit=0;
if(isfield(psess.history,'ips'))
    if(psess.history.ips == 1)
        isinit=1;
    end
end       
overexists=isfield(cfg,'overwrite');
overwrite=0;
if(overexists==1)
    overwrite=cfg.overwrite;
end
if(isinit==1 && overwrite == 1)
    fprintf('%s\n',[processID 'The IPS data will be overwritten.'])
    psess.history.svps=0;
end
if(isinit==1 && overwrite == 0)
    fprintf('%s\n',[processID 'IPS data exist and will not be overwritten.']);
    return
end

useppc=1; % by default it uses ppc
if(isfield(cfg,'ppc'))
    useppc=cfg.ppc;
    fprintf('%s\n',[processID 'Using PPC measure.']);
end

%%% TO BE REMOVED
psess.datasize=[91 109 91 psess.T];
%%%

%% Processing

load(psess.groupmask);  %the variable is groupmask
sz=psess.datasize;
ips=zeros(sz(1),sz(2),sz(3),psess.T);
disp([processID 'computing time:']);
for t=1:psess.T;
    fprintf('%s',['..' num2str(t)]);
    temp=ips(:,:,:,t);
    if(useppc==0)
        for s=1:psess.Nsubj
            load([psess.outdata{s} '/' num2str(t) '.mat']);
            temp=temp+exp(j*(angle(Hvol)));
        end
        ips(:,:,:,t)=abs(temp)/psess.Nsubj;
    else
        DN=((psess.Nsubj^2)-psess.Nsubj)/2;
        dval=zeros(sz(1),sz(2),sz(3),DN);   % the distance matrix
        count=0;
        for s1=1:psess.Nsubj
            load([psess.outdata{s1} '/' num2str(t) '.mat']);
            Hvol1=Hvol;
            for s2=(s1+1):psess.Nsubj
                count=count+1;
                load([psess.outdata{s2} '/' num2str(t) '.mat']);
                Hvol2=Hvol;
                dval(:,:,:,count)=abs(angle(exp(j*(angle(Hvol1)-angle(Hvol2)))));   %pairwise distances
            end
        end
        D=angle(sum(exp(j*dval),4)/count);        
        ips(:,:,:,t)=groupmask.*angle(exp(j*(pi-2*D)))/pi;
    end
end    
fprintf('\n%s\n',[processID 'Intersubject phase synchrony computed'])


% to be ipmlemented ,save as nii
%disp([processID 'Saving nifti data');
svpsfile=psess.outpath;
mkdir([psess.outpath 'results/']);
psess.results.ips=[psess.outpath 'results/ips.mat'];
save(psess.results.ips,'ips','-v7.3');
psess.history.ips=1;
disp([processID 'Updating session: ' psess.session_name]);
save(psess.sessionfile,'psess');
disp([processID '...done']);



