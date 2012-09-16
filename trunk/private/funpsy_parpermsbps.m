function data=funpsy_parpermsbps(edges,perm,outpath,psess,ranperm);

	%disp([num2str(perm) '..'])
	%system(['touch ' outpath num2str(perm) '.mat']);
	%id=mod((perm-1),size(edges,1))+1;
	r=edges(perm,1);
	c=edges(perm,2);
	
	for s=1:psess.Nsubj
		load([psess.roidata{s} '/' num2str(r) '.mat']);
		rts(:,s)=angle(roits);
		load([psess.roidata{s} '/' num2str(c) '.mat']);
		cts(:,s)=angle(roits);
	end
	T=psess.T;
	sbpsts=zeros(T,ranperm);
    for thisperm=1:ranperm
    	temp=0;
        for s=1:psess.Nsubj
    		ran1=3+round((T-4)*rand);
	    	ran2=3+round((T-4)*rand);
		    ar=rts(:,s);
		    ac=cts(:,s);		
    		ar=[ar(ran1:end); ar(1:ran1-1)];
	    	a2=[ac(ran2:end); ac(1:ran2-1)];
		
    		temp=temp+exp(j*(ar-ac));
    	end
	    sbpsts(:,thisperm)=cos(angle(temp)).*abs(temp)/psess.Nsubj;
    end
	%save([outpath num2str(perm) '.mat'],'dfpsts');
	data=sbpsts(:);
