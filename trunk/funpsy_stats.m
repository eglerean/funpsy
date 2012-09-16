function [psess] = funpsy_stats(cfg)

%FUNPSY_STATS Computes the statistical values for DFPS, IFPS, IPS or SVPS
%   psess = funpsy_stats(cfg)
%   'cfg' is a struct with mandatory and optional fields
%   MANDATORY:
%       cfg.sessionfile = string with the path of the sessionfile
%       cfg.statstype='sbps';
%           statistics for SBPS, results saved in out.sbps_stats
%   
%       cfg.statstype='isbps';
%           statistics for ISBPS, results saved in out.isbps_stats
%
%       cfg.statstype='svps';
%           statistics for SVPS, results saved in out.svps_stats // NOT YET IMPLEMENTED
% 
%       cfg.statstype='ips';
%           statictics for IPS, results saved in out.ips_stats
%   OPTIONAL:
%       cfg.nonparam = 1 ;     
%           recommended. If 0 uses parametric tests. Right now only nonparam is implemented.
%       cfg.parallel = 1;   
%           Experimental feature - uses parallel computing
%       cfg.perm=1000;     
%           for each ROI pair, does a non parametric test.
%       cfg.reduced = p;
%           uses a reduced set of ROIs. P is the percentage of rois to use taken from the maximum positive and maximum negative of the temporal averaged data

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
    {'reduced'}
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

flag=-1; % sbps=1 isbps=2 svps=3 ips=4
switch cfg.statstype
    case 'sbps'
        flag=1;
        disp([processID 'Statistics for SBPS']);
    case 'isbps'
        flag=2;
        disp([processID 'Statistics for ISBPS']);
    case 'svps'
        flag=3;
        disp([processID 'Statistics for SVPS']);
        error(['Feature not yet available'])
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


%%SBPS

if(flag == 1)
    perc=cfg.reduced;
    if(perc>100) perc=100;end
    if(perc > 0 && perc~=100)
        % load avgsbps / should compute it if it is not there yet. Add a check
        load([psess.outpath 'results/avgsbps.mat']); % variable avgsbps, zeros on main diagonal, simmetric adj matrix
        % ---add here the removal of the blacklisted nodes
        R=size(avgsbps,1);
        triuIDs=find(triu(ones(R),1)==1);
        th=prctile(avgsbps(triuIDs),[perc 100-perc]);
        avgsbps(find(avgsbps<=th(1)))=1;
        avgsbps(find(avgsbps>=th(2)))=1;
        avgsbps(find(avgsbps~=1))=0;
        counter=1;
        edges=[];
    	for r=1:R
	    	for c=r+1:R
	    	    if(avgsbps(r,c)==1)
    		    	edges(counter,:)=[ r c];
	    		    counter=counter+1;
	    		end
		    end    
	    end
	    % should test that these folders are not already created
	    mkdir([psess.outpath 'stats/sbps/']);
        mkdir([psess.outpath 'stats/sbps/perm/']);
        tempfolder=[psess.outpath 'stats/sbps/perm/'];
        if(cfg.parallel == 1)
            disp([processID 'computing permutation using distributed computing on ' num2str(size(edges,1)) ' permutations']);
            % Do it for all edges
            %cfg.perm=10;
            edgeout=zeros(psess.T*cfg.perm,size(edges,1));
            parfor perm=1:size(edges,1)
                edgeout(:,perm)=funpsy_parpermsbps(edges,perm,tempfolder,psess,cfg.perm)
            end
        end
        %edgeout=reshape(edgeout,psess.T,[]);
        
        stats.l.p_info=[.05 .01 .005 .001 .0005 .0001];
        stats.r.p_info=[.95 .99 .995 .999 .9995 .9999];
        
        stats.l.th=prctile(edgeout(:),100*stats.l.p_info);
        stats.r.th=prctile(edgeout(:),100*stats.r.p_info);
        
        stats.l.th_FDR=min(prctile(edgeout',100*stats.l.p_info),[],2);
	stats.l.th_FDR=stats.l.th_FDR';
	stats.r.th_FDR=max(prctile(edgeout',100*stats.r.p_info),[],2)
	stats.r.th_FDR=stats.r.th_FDR';

        stats.l.th_FWE=prctile(min(edgeout,[],2),100*stats.l.p_info);
        stats.r.th_FWE=prctile(max(edgeout,[],2),100*stats.r.p_info);

        ma=mean(reshape(edgeout,psess.T,[]));
        ma=reshape(ma,cfg.perm,[]);

        stats.l.avgth=prctile(ma(:),100*stats.l.p_info);
        stats.r.avgth=prctile(ma(:),100*stats.r.p_info);

        stats.l.avgth_FDR=min(prctile(ma',100*stats.l.p_info),[],2);        
        stats.l.avgth_FDR=stats.l.avgth_FDR';
	stats.r.avgth_FDR=max(prctile(ma',100*stats.r.p_info),[],2);
        stats.r.avgth_FDR=stats.r.avgth_FDR';

        stats.l.avgth_FWE=prctile(min(ma,[],2),100*stats.l.p_info);
        stats.r.avgth_FWE=prctile(max(ma,[],2),100*stats.r.p_info);
        
        psess.stats.sbps.stats=stats;
        psess.history.stats.sbps=1;
        
    else
        % add here test for all rois
    end
end

%% ISBPS

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
        





