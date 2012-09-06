function rois=funpsy_makerois(cfg)
%FUNPSY_MAKEROIS Creates region of interested based on a given brain mask
%   rois=funpsy_makerois(cfg) returns the rois struct
%   'cfg' is a struct with mandatory and optional fields
%       cfg.nii ='mask.nii' a string with the path of the ROIs mask as NIFTI file
%       OPTIONAL:
%       cfg.labels=<array of strings> (default value is 'automatic');
%           a list of strings for each ID in the mask file.     
%       cfg.splitrois=1     (or 0, default);
%           if 1, split the rois over a certain threshold into smaller rois
%       cfg.splitthr=3      (default 3)
%           maximum number of voxels allowed in one x/y/z direction for the given ROI
%           

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%



processID='funpsy_makerois >> ';



%% input validation

if(isfield(cfg,'nii'))
    roinii=cfg.nii;
else
    error([processID 'A NIFTI file with regions of interest must be specified in cfg.nii']);
end

if(~isfield(cfg,'labels'))
    disp([processID 'labels not specified, using automatic labelling']);
    cfg.labels='automatic';
end


nii=load_nii(roinii);
roiIDs=unique(nii.img(find(nii.img>0)));

AAL=0;
if(strcmp(cfg.labels,'automatic'))
    AAL=1;
    load('AAL.mat');
    if(any(~(nii.hdr.dime.dim(2:4) == [91 109 91])))    % if at least one dimension is not matching the AAL file
        error([processID 'Automatic labeling is only supported for images of size [91 109 91] i.e. the FSL templates']);
    end
else
    if(length(roiIDs) ~= length(cfg.labels))
        error([processID 'Lenght of labels does not match number of rois in the NIFTI file']);
end

%% Processing

for r=1:length(roiIDs)
    ids=find(nii.img==roiIDs(r));
    [x y z]=ind2sub(size(nii.img),ids);
    roi.map=[x y z];
    roi.centroid=[mean(roi.map(:,1)) mean(roi.map(:,2)) mean(roi.map(:,3))];
    if(AAL==0)
        roi.label=cfg.labels(r);
    else
        roi.label=AAL(round(roi.centroid(1)),round(roi.centroid(2)),round(roi.centroid(3)),
    rois(r)=roi;
end

%% OPTIONAL - splitting the ROIs

splitit=0;
splitthr=10;
if(isfield(cfg.splitrois))
    splitit=cfg.splitrois;
end

if(isfield(cfg.splitthr))
    splitthr=cfg.splitthr;
end

if(splitit)
    newROIs=[];
    cfgsplit=[];
    cfgsplit.splitthr=splitthr;
    newROIs=funpsy_splitroi(cfg,rois,newROIs);
end

% if everything went well (add a test?) we overwrite the output

rois = newROIs;




