function parisbps(roi,outpath,psess,data)
	system(['touch ' outpath num2str(roi) '.mat']);
	temp=0;
	ppc=0; % Pairwise Phase Consistency is forced to zero since it needs to be validated first
	if(ppc==0)
		for s=1:psess.Nsubj
			ar=data(:,roi+1:end,s);
			ac=repmat(data(:,roi,s),1,size(data,2)-roi);
			temp=temp+exp(j*ar) +exp(j*ac);
		end
		isbpsts=abs(temp)/(2*psess.Nsubj);
	else
		DN=((psess.Nsubj^2)-psess.Nsubj)/2;
		dval=zeros(DN,psess.T);   % the distance matrix
		count=0;
		for s1=1:psess.Nsubj
			rts1=load([psess.roidata{s1} num2str(r) '.mat']);
			cts1=load([psess.roidata{s1} num2str(c) '.mat']);
			ar1=angle(rts1.roits);
			ac1=angle(cts1.roits);
			a1=(ar1-ac1);
			for s2=(s1+1):psess.Nsubj
				count=count+1;
				rts2=load([psess.roidata{s2} num2str(r) '.mat']);
				cts2=load([psess.roidata{s2} num2str(c) '.mat']);
				ar2=angle(rts2.roits);
				ac2=angle(cts2.roits);
				a2=(ar2-ac2);
				dval(count,:)=abs(angle(exp(j*(a1-a2))));   %pairwise distances
			end
		end
		D=zeros(psess.T,1);
		D(:,1)=angle(sum(exp(j*dval),1)/count);
		dfpsts=angle(exp(j*(pi-2*D)))/pi;
	end
	save([outpath num2str(roi) '.mat'],'isbpsts');
