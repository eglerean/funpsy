function outROIs=splitROIs(cfg,ROIs,outROIs)
    if(isfield(cfg,'splitthr'))
        mx=cfg.splitthr;
        my=cfg.splitthr;
        mz=cfg.splitthr;
    else
        mx=10;
        my=10;
        mz=10;
    end
    for r=1:length(ROIs)
        map=ROIs(r).map;
        x=ROIs(r).map(:,1);
        y=ROIs(r).map(:,2);
        z=ROIs(r).map(:,3);
        X=1+max(x)-min(x);
        Y=1+max(y)-min(y);
        Z=1+max(z)-min(z);
        label=ROIs(r).label;
        if(X>mx)
            sp=(min(x)+max(x))/2;
            low=find(x<sp);
            high=find(x>=sp);
            tempROI(1).map=map(low,:);
            tempROI(1).label=label;
            tempROI(2).map=map(high,:);
            tempROI(2).label=label;            
            outROIs=splitROIs(cfg,tempROI,outROIs);
        elseif(Y>my)
            sp=(min(y)+max(y))/2;
            low=find(y<sp);
            high=find(y>=sp);
            tempROI(1).map=map(low,:);
            tempROI(1).label=label;            
            tempROI(2).map=map(high,:);
            tempROI(2).label=label;            
            outROIs=splitROIs(cfg,tempROI,outROIs);
        elseif(Z>mz)
            sp=(min(z)+max(z))/2;
            low=find(z<sp);
            high=find(z>=sp);
            tempROI(1).map=map(low,:);
            tempROI(1).label=label;            
            tempROI(2).map=map(high,:);
            tempROI(2).label=label;            
            outROIs=splitROIs(cfg,tempROI,outROIs);
        else
            %disp('merge');
            newid=length(outROIs)+1;
            outROIs(newid).map=map;
            outROIs(newid).label=[label '-' num2str(round(mean(x))) '.' num2str(round(mean(y))) '.' num2str(round(mean(z)))];
            outROIs(newid).centroid=[mean(x) mean(y) mean(z)];
        end
    end
            