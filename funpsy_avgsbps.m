function psess=funpsy_avgsbps(cfg);
	load(cfg.sessionfile); % psess loaded
	if(exist([psess.outpath '/results/avgsbps.mat'])==0)
		% check history
		R=length(psess.rois);
		net=zeros(R);
		for r=1:R-1
			fprintf([num2str(r) '..']);
			load([psess.outpath '/results/sbps/' num2str(r)]);	%sbpsts
			if(any(isnan(sbpsts)))
				disp('nan!')
			end
			net(r,r+1:R)=mean(sbpsts,1);
		end
		disp(['saving avg sbps network']);
		avgsbps=net+net';
		save([psess.outpath '/results/avgsbps.mat'],'avgsbps');
	else
		disp(['File ' psess.outpath '/results/avgsbps.mat' ' exists and will not be overwritten']);
	end
