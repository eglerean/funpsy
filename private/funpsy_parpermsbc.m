function data=funpsy_parpermsbc(edges,perm,psess,ranperm);

	%disp([num2str(perm) '..'])
	%system(['touch ' outpath num2str(perm) '.mat']);
	%id=mod((perm-1),size(edges,1))+1;
	r=edges(perm,1);
	c=edges(perm,2);
	
	for s=1:psess.Nsubj
		load([psess.roidata{s} '/' num2str(r) '.mat']);
		rts(:,s)=real(roits);	% we take the real part because this is just correlation	
		load([psess.roidata{s} '/' num2str(c) '.mat']);
		cts(:,s)=real(roits);
	end
	T=psess.T;
	sbc=zeros(ranperm,1);
    for thisperm=1:ranperm
    	temp=0;
        for s=1:psess.Nsubj
    		ran1=3+round((T-4)*rand);
	    	ran2=3+round((T-4)*rand);
		    ar=rts(:,s);
		    ac=cts(:,s);		
    		ar=[ar(ran1:end); ar(1:ran1-1)];
	    	ac=[ac(ran2:end); ac(1:ran2-1)];
			c=corr(ar,ac);
			if(isnan(c)) c=0; end
			if(c==1)	c=1-eps; end
			if(c==-1)	c=-1+eps;end
    		temp=temp+atanh(c);
    	end
	    sbc(thisperm)=temp/psess.Nsubj;
    end
	%save([outpath num2str(perm) '.mat'],'dfpsts');
	data=tanh(sbc);
