function psess=funpsy_nodeblacklist(cfg)

% add explanation here

load(cfg.sessionfile)
load(psess.groupmask)
thr=.75;
blacklist=[];
for r=1:length(psess.rois)
	map=psess.rois(r).map;
	score=0;
	for m=1:size(map,1);
		score=score+groupmask(map(m,1),map(m,2),map(m,3));
	end
	if(score/size(map,1)<thr)
		blacklist=[blacklist;r];
	end
end	

psess.blacklist=blacklist;
disp(num2str(length(psess.blacklist)))
save(psess.sessionfile,'psess')



