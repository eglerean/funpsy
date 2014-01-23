clear all
close all

cfg=[];

cfg.roimask='./AAL/aal_2mm.nii';
load AAL/aal_labels.mat
cfg.labels=aal_labels;

rois=bramila_makeRoiStruct(cfg);
save aal_2mm_rois rois