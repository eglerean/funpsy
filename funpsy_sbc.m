function psess=funpsy_sbc(cfg)
%
% add checks about history, the function could be splitted in the mean part as funpsy_avgsbc
%
load(cfg.sessionfile);
R=length(psess.rois);
Nsubj=psess.Nsubj;
avgsbc=zeros(R,R);

if(isfield(cfg, 'overwrite'))
	overwrite=cfg.overwrite;
else
	% default option for the overwrite
	overwrite=0;
end

for subj=1:Nsubj
    disp(['Subject ' num2str(subj)])
    %net=zeros(R);
	if(~(2==exist([psess.outpath '/results/sbc/sbc_' num2str(subj) '.mat']) && overwrite==0))
		data=zeros(psess.T,R);
		for r=1:R
			fprintf([num2str(r) '..']);
			ts=load([psess.roidata{subj} '/' num2str(r) '.mat']);
			ts=ts.roits;
			data(:,r)=real(ts);
		end
		sbc=corr(data);
		sbc(isnan(sbc))=0;

		mkdir([psess.outpath '/results/sbc/'])
		save([psess.outpath '/results/sbc/sbc_' num2str(subj) '.mat'],'sbc');
	else
		disp(['Loading existing data ' psess.outpath '/results/sbc/sbc_' num2str(subj) '.mat ...']);
		load([psess.outpath '/results/sbc/sbc_' num2str(subj) '.mat']);
	end
	sbc(find(sbc==1))=1-eps;
	sbc(find(sbc==-1))=-1+eps;
	avgsbc=avgsbc+atanh(sbc);
    disp(['Subject ' num2str(subj) ' SBC done']);
end

avgsbc=avgsbc/Nsubj;	% mean
avgsbc=tanh(avgsbc);
save([psess.outpath '/results/avgsbc.mat'],'avgsbc');

%% add here part about psess.history
