The original AAL atlas is stored in aal_original.nii
The atlas is not in the FSL 2mm conventional size, so the function
transform_2mm.m will take care of this. The result is saved in aal_2mm.nii

The labels can be loaded in matlab using the file aal_labels.mat which is made with the function make_labels.m

The cortex is also consolidated for better labeling: this means that regions are contiguous, clearly separated between left and right and with no empty voxels in the middle.
See the result in the file aal_cortex_consolidated.nii
