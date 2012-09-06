function nii=funpsy_svps2nii(cfg)
%FUNPSY_SVPS2NII Converts the SVPS data created by funpsy_svps into a NIFTI file
%     nii=funpsy_svps2nii(cfg) saves the results in out.results.svps 


%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


    processID='>>> funpsy_svps2nii';
    psess=funpsy_loadsession(cfg,processID);
    load(cfg.psess);
    % ADD A acheck that we have done IPS from psess.history
    %if(cfg.average==1)
        load(psess.results.svps);    % matrix svps


	nii=load_nii(psess.coregistered_mask);

        nii.img=double(svps);

        nii.hdr.dime.bitpix=64;
        nii.hdr.dime.datatype=64;
        nii.hdr.dime.dim(1)=4;
        nii.hdr.dime.dim(5)=psess.T;
        nii.hdr.dime
        mkdir([psess.outpath '/nifti/']);
        save_nii(nii,[psess.outpath '/nifti/svps.nii']);


