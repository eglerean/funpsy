function psess=funpsy_makedata(cfg)
%FUNPSY_MAKEDATA Creates the analytic signal for phase synchrony analysis
%   session=funpsy_makedata(cfg) returns the session struct
%   'cfg' is a struct with mandatory and optional fields
%       cfg.sessionfile = string with the path of the sessionfile
%       OPTIONAL:
%       cfg.compute_group_mask=1 (or 0);     % overrides session settings
%       cfg.compute_spectrum=1  (or 0);     % overrides session settings


%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%

processID='funpsy_makedata >> ';
if(exist(cfg.sessionfile))
    load(cfg.sessionfile)
else
    error([processID 'File ' cfg.sessionfile ' does not exist']);
end

% Test: was the session initialized?
isinit=0;
if(isfield(psess.history,'init'))
    if(psess.history.init == 1)
        isinit=1;
    end
end       

if(isinit == 0)
    error([processID 'The session ' cfg.sessionfile ' was not initialized']);
end

isAS=0;
if(isfield(psess.history,'ASdatacreated'))
    if(psess.history.ASdatacreated == 1)
        isAS=1;
    end
end

overexists=isfield(cfg,'overwrite');
overwrite=0;
if(overexists==1)
    overwrite=cfg.overwrite;
end


if(isAS==1 && overwrite == 1)
    fprintf('%s\n',[processID 'The pre-processed data will be overwritten.'])
end

if(isAS==1 && overwrite == 0)
    fprintf('%s\n',[processID 'Preprocessed data exist and will not be overwritten.']);
    return  % should be improved to test other parts like the group mask and the spectrum
end
    
    


%% Input checking
% to be added here


%% Standard template
mask=load_nii(psess.coregistered_mask);
maskimg=mask.img;
inmask=find(maskimg>0); % indexes with standard template mask
groupmask=zeros(size(maskimg));
groupmask(inmask)=1;

%% Processing
for s=1:psess.Nsubj
    disp([processID 'Loading original data subj ' num2str(s)]);
    img=load_nii(psess.indata{s});

    siz=size(img.img);
    img.img=double(img.img);        % making sure we have high precision values
    %%%%
    % compute individual mask and spectrum if wanted, skipped for now
    %%%%
    disp([processID '1.Computing analytic signal for subj ' num2str(s)]);
    runonce=1;
    fprintf('%s','   Slice x = '); 
    for x = 1:siz(1);
        fprintf('%s',[num2str(x) '...']);
        for y = 1:siz(2)
            for z = 1:siz(3)
                if(maskimg(x,y,z)==1)
                    ts=squeeze(img.img(x,y,z,:));   % the original timeseries
                    tsnorm=ts-mean(ts);             % removing DC for optimal bandpass filtering
                    T=length(tsnorm);
		    tsout=conv(psess.filter.b,tsnorm);  % produces a T+N-1 length signal
		    tsout=flipud(conv(psess.filter.b,flipud(tsout)));
		    if(0) % delay compensation, normal filter [not implemented]
		        tsout = tsout((psess.filter.N/2+1):(end-psess.filter.N/2));
		    else
			tsout = tsout(length(psess.filter.b):end);
			tsout(T+1:end)=[];
		    end
                    if(0)       % option for filter transient removal
		    	tsout=tsout((psess.filter.N+1):end); % removing N filter transient and N/2 filter tail of factual data
		    end
                    if(runonce==1)
                        % to speed up matlab, initialize the variables at the very first cycle 
                        H=zeros(siz(1),siz(2),siz(3),length(tsout));
                        if(psess.compute_group_mask)
                            Pow=zeros(siz(1),siz(2),siz(3));
                        end
                        if(psess.compute_spectrum)
                            Spec=zeros(siz(1),siz(2),siz(3),psess.NFFT)
                        end
                        runonce=0;
                    end
                    H(x,y,z,:)=hilbert(tsout);
                    if(psess.compute_group_mask)
                        pow=sum(ts.^2)/length(ts);
                        Pow(x,y,z)=pow;
                    end
                    if(psess.compute_spectrum)
                        disp('psess.compute_spectrum to be implemented');
                    end
                end
            end
        end
    end
    fprintf('%s\n','.');
    disp([processID '1. done']);
    disp([processID '2. Saving data in ' psess.outdata{s}]);
    for t=1:length(tsout)
        filename=[psess.outdata{s} '/' num2str(t) '.mat'];
        Hvol=H(:,:,:,t);
        save(filename,'Hvol');
    end
    if(psess.compute_group_mask)
        filename=[psess.outdata{s} '/Pow.mat'];
        save(filename,'Pow');
        p=prctile(Pow(inmask),2);
        smask=zeros(size(Pow));
        smask(find(Pow>=p))=1;
        groupmask=groupmask.*smask;
    end
    if(psess.compute_spectrum)
        %filename=[psess.outdata{s} '/Pow.mat'];
        %save(filename,'Pow');
    end 
    disp([processID '2. done']);
end


%% finalizing and updating the session file
psess.T=size(H,4);
psess.history.ASdatacreated=1;
if(psess.compute_group_mask)
    psess.history.groupmaskcreated=1;
    psess.groupmask=[psess.outpath 'mask.mat'];
    save(psess.groupmask,'groupmask');
else
    psess.history.groupmaskcreated=0;
end

if(psess.compute_spectrum)
    psess.history.spectrumcreated=1;
    psess.spectrum=[psess.outpath 'spectrum.mat'];
    save(psess.spectrum,'groupSpec');
else
    psess.history.spectrumcreated=0;
end

disp([processID '3. updating session: ' psess.session_name]);
save(psess.sessionfile,'psess');
disp([processID '3. done']);



