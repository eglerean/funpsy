function psess = funpsy_stats(cfg)
%FUNPSY_STATS Computes the statistical values for DFPS, IFPS, IPS or SVPS
%       psess=funpsy_stats(cfg)
%       'cfg' is a struct with mandatory and optional fields
%       MANDATORY:
%           cfg.sessionfile = string with the path of the sessionfile
%           cfg.statstype='dfps';
%               statistics for DFPS, results saved in out.dfps_stats
%
%           cfg.statstype='ifps';
%               statistics for IFPS, results saved in out.ifps_stats
%
%           cfg.statstype='svps';
%               statistics for SVPS, results saved in out.svps_stats
% 
%           cfg.statstype='ips';
%               statictics for IPS, results saved in out.ips_stats
%       OPTIONAL:
%           cfg.nonparam=1;     
%               recommended. If 0 uses parametric tests. 
%           cfg.parallel = 1;   
%               Experimental feature - uses parallel computing
%           cfg.perm=1000;     
%               for each ROI pair, does a non parametric test

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%



processID='funpsy_stats >> ';
if(nargin == 0)
    error([processID 'Function called with no parameters, please specify cfg parameters.']);
end

mandatoryfields=[
    {'sessionfile'}
    {'statstype'}
    ];
    
optionalfields=[
    {'nonparam'}
    {'parallel'}
    {'perm'}
    {'parallel'}
];    

defaults= [
    1
    0
    10000
    1
];

fields=fieldnames(cfg);

% test mandatory fields
for f=1:length(mandatoryfields)
    hasfield=ismember(mandatoryfields{f},fields);
    if(hasfield==0)
        error([processID 'Missing mandatory field ' mandatoryfields{f}]);
    end
end

% test optional fields
for f=1:length(optionalfields)
    hasfield=ismember(optionalfields{f},fields);
    if(hasfield==0)
        cfg.(optionalfields{f}) = defaults(f);
    end
end

% Test: does the session file exist?
psess=funpsy_loadsession(cfg,processID);        % also loads the session file
% Test: was the session initialized?
funpsy_testinit(psess,processID);
% Test: was the analytic signal created?
funpsy_testAS(psess,processID);

mkdir([psess.outpath 'stats/']);

%% FUNCTION SPECIFIC PARAMETERS TEST 
% more to be added

cfg.randthres=3;    % pick a random time point at least 3 volumes away

flag=-1; % dfps=1 ifps=2 svps=3 ips=4
switch cfg.statstype
    case 'dfps'
        flag=1;
        disp([processID 'Statistics for DFPS']);
    case 'ifps'
        flag=2;
        disp([processID 'Statistics for IFPS']);
    case 'svps'
        flag=3;
        disp([processID 'Statistics for SVPS']);
    case 'ips'
        flag=4;
        disp([processID 'Statistics for IPS']);
    otherwise
        error([processID 'Parameter cfg.statstype = ' cfg.statstype ' not recognized']);
end

%% check if we are going to use PPC


useppc=0;
if(isfield(cfg,'ppc'))
    useppc=cfg.ppc;
    fprintf('%s\n',[processID 'Using PPC measure.']);
end


%% DFPS

if(flag == 1)
	R=length(psess.rois);
	edges=zeros((R*R-R)/2,2);
	counter=1;
	for r=1:R
		for c=r+1:R
			edges(counter,:)=[ r c];
			counter=counter+1;
		end
	end
    mkdir([psess.outpath 'stats/dfps/']);
    mkdir([psess.outpath 'stats/dfps/perm/']);
    tempfolder=[psess.outpath 'stats/dfps/perm/'];
    if(cfg.parallel == 1)
        disp([processID 'computing permutation using distributed computing on ' num2str(size(edges,1)) ' permutations']);
        
        parfor perm=1:size(edges,1)
            parpermdfps2(edges,perm,tempfolder,psess,cfg.perm)
        end
    end
end

%% IFPS

%% SVPS

if(flag == 3)
    R=length(psess.rois);
    for r=1:R
        disp([processID 'Processing ROI #' num2str(r)]);
        % make the roi into analytic signals
        ts=zeros(psess.T,psess.Nsubj);
        for s=1:psess.Nsubj
            temp=load([psess.roidata{s} num2str(r) '.mat']);
            ts(:,s)=temp.roits;
        end
        Hts=hilbert(ts);
        pts=angle(Hts);     % phase of the roi time series
        sz=psess.datasize;
        svps=zeros(sz(1),sz(2),sz(3));
        mkdir([psess.outpath 'stats/svps/']);
        mkdir([psess.outpath 'stats/svps/perm/']);
        tempfolder=[psess.outpath 'stats/svps/perm/'];
        

        
        if(cfg.parallel == 1)
            disp([processID 'computing permutation using distributed computing']);
            parfor perm=1:cfg.perm
                funpsy_parpermsvps(perm,psess,pts,cfg.randthres);
            end
        else
            disp([processID 'computing permutations']);
            for perm = 1:cfg.perm
                randif=ceil((psess.T-2*cfg.randthres)*rand(psess.Nsubj,2))+cfg.randthres;
                temp=zeros(sz(1),sz(2),sz(3));
                if(mod(perm,100)==0)
                    fprintf('%s',['..' num2str(round(10000*perm/cfg.perm)/100)]);
                end
                t=ceil(psess.T*rand);
                for s=1:psess.Nsubj
                    t1=mod(t+randif(s,1),psess.T)+1;
                    t2=mod(t+randif(s,2),psess.T)+1;
                    load([psess.outdata{s} '/' num2str(t1) '.mat']);
                    temp=temp+exp(j*(angle(Hvol)-pts(t2,s)));
                end
                svps=cos(angle(temp)).*abs(temp)/psess.Nsubj;
                save([psess.outpath 'stats/svps/perm/' num2str(perm) '.mat'],'svps');
            end 
        end

        clear svps;
        fprintf('\n%s\n',[processID 'computing probability distribution function.'])
        % add a test if we computed the group mask
        img=load(psess.groupmask);
        inmask=find(img.groupmask>0);
        pdfdata=zeros(length(inmask),cfg.perm);
        for perm=1:cfg.perm;
            if(mod(perm,100)==0)
                fprintf('%s',['..' num2str(round(10000*perm/cfg.perm)/100)]);
            end
            load([psess.outpath 'stats/svps/perm/' num2str(perm) '.mat']);  % variable is svps
            pdfdata(:,perm)=svps(inmask);
        end
        pval=prctile(pdfdata(:),[95 99 99.9 99.99 99.999 99.9999 99.99999]);
        psess.stats.svps.rois(r).pval=pval;
        psess.history.stats.svps=1;
        % add cleaning of the perm folder for next ROI
    end    
end

%% IPS

if(flag == 4)
    mkdir([psess.outpath 'stats/ips/']);
    mkdir([psess.outpath 'stats/ips/perm/']);
    sz=psess.datasize;
    if(cfg.parallel == 1)
        disp([processID 'computing permutation using parallel computing']);
        if(matlabpool('size')==0)   % if there is no matlabpool we start it
            disp([processID 'starting matlabpool']);
            matlabpool;
        end
        parfor perm=1:cfg.perm
            funpsy_parpermips(perm,psess,cfg.randthres,useppc);
        end
    else
        disp([processID 'computing permutations']);
        for perm = 1:cfg.perm
            randif=ceil((psess.T-2*cfg.randthres)*rand(psess.Nsubj,1))+cfg.randthres;
            temp=zeros(sz(1),sz(2),sz(3));
            if(mod(perm,100)==0)
                fprintf('%s',['..' num2str(round(10000*perm/cfg.perm)/100)]);
            end
            t=ceil(psess.T*rand);
            for s=1:psess.Nsubj
                t1=mod(t+randif(s,1),psess.T)+1;
                load([psess.outdata{s} '/' num2str(t1) '.mat']);
                temp=temp+exp(j*(angle(Hvol)));
            end
            ips=abs(temp)/psess.Nsubj;
            save([psess.outpath 'stats/ips/perm/' num2str(perm) '.mat'],'ips');
        end 
    end
    fprintf('\n%s\n',[processID 'computing probability distribution function.'])
    % add a test if we computed the group mask
    img=load(psess.groupmask);
    inmask=find(img.groupmask>0);
    pdfdata=zeros(length(inmask),cfg.perm);
    for perm=1:cfg.perm;
        if(mod(perm,100)==0)
            fprintf('%s',['..' num2str(round(10000*perm/cfg.perm)/100)]);
        end
        load([psess.outpath 'stats/ips/perm/' num2str(perm) '.mat']);  % variable is ips
        pdfdata(:,perm)=ips(inmask);
    end
    pval=prctile(pdfdata(:),[95 99 99.9 99.99 99.999 99.9999 99.99999]);
    psess.stats.ips.pval=pval;
    psess.history.stats.ips=1;
end


%% UPDATING SESSION
disp([processID 'Updating session: ' psess.session_name]);
save(psess.sessionfile,'psess');
disp([processID '...done']);
        





