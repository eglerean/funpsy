function funpsy_parpermips(perm,psess,randthres)    
    sz=psess.datasize;
    randif=ceil((psess.T-2*randthres)*rand(psess.Nsubj,2))+randthres;
    temp=zeros(sz(1),sz(2),sz(3));
    t=ceil(psess.T*rand);
    for s=1:psess.Nsubj
        t1=mod(t+randif(s,1),psess.T)+1;
        load([psess.outdata{s} '/' num2str(t1) '.mat']);
        temp=temp+exp(j*(angle(Hvol)));
    end
            
    ips=abs(temp)/psess.Nsubj;
    save([psess.outpath 'stats/ips/perm/' num2str(perm) '.mat'],'ips');