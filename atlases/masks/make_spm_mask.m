mni=load_nii('MNI152_T1_2mm_brain_mask.nii');

spmsize=[79 95 68];

mask=mni.img;
mnisize=size(mask);
szdiff=floor((mnisize-spmsize)/2);

spmmask=mask(szdiff(1)+(1:spmsize(1)),szdiff(2)+(1:spmsize(2)),szdiff(3)-2+(1:spmsize(3)));

save_nii(make_nii(spmmask),'MNI_spm_cropped.nii');


