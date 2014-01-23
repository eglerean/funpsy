clear all
close all
TH=30;
blacklist=[];
%% cortex
nii=load_nii('HarvardOxford/HarvardOxford-cortl-prob-2mm.nii');
% thresholding
for n=1:size(nii.img,4)
    temp=double(nii.img(:,:,:,n));
    if(n==1)
        out=zeros(size(temp));
    end
    ids=find(temp>TH);
    out(ids)=n;
end
count=n;

%% subcortex
nii=load_nii('HarvardOxford/HarvardOxford-sub-prob-2mm.nii');
nii.img(:,:,:,[1 2 3 12 13 14])=[];  % getting rid of masks for white matter, cortex and ventricles
% thresholding
for n=1:size(nii.img,4)
    temp=double(nii.img(:,:,:,n));
    ids=find(temp>TH);
    out(ids)=n+count;
end
count=n+count;

%% cerebellum
nii=load_nii('Cerebellum/Cerebellum-MNIfnirt-prob-2mm.nii');
% thresholding
for n=1:size(nii.img,4)
    temp=double(nii.img(:,:,:,n));
    ids=find(temp>TH);
    out(ids)=n+count;
    if(length(ids)==0)
        blacklist=[blacklist;n+count];
    end
end
count=n+count;

save_nii(make_nii(out),['HarvardOxford/HarvardOxford-maxprob-' num2str(TH) '-2mm.nii'])


cfg=[];
cfg.roimask=['HarvardOxford/HarvardOxford-maxprob-' num2str(TH) '-2mm.nii'];
load HarvardOxford/HO_labels.mat
labels([97 98 99 108 109 110])=[]; % as above, we remove label masks for white matter, cortex and ventricles
labels(blacklist)=[];
cfg.labels=labels;
rois=bramila_makeRoiStruct(cfg);

save HO_2mm_rois rois
