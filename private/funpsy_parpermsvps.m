function funpsy_parpermsvps(perm,psess,pts,randthres)    
    sz=psess.datasize;
    randif=ceil((psess.T-2*randthres)*rand(psess.Nsubj,2))+randthres;
    temp=zeros(sz(1),sz(2),sz(3));
    t=ceil(psess.T*rand);
    for s=1:psess.Nsubj
        t1=mod(t+randif(s,1),psess.T)+1;
        t2=mod(t+randif(s,2),psess.T)+1;
        load([psess.outdata{s} '/' num2str(t1) '.mat']);
        temp=temp+exp(j*(angle(Hvol)-pts(t2,s)));
    end
            
    svps=cos(angle(temp)).*abs(temp)/psess.Nsubj;
    save([psess.outpath 'stats/svps/perm/' num2str(perm) '.mat'],'svps');