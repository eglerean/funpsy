function nii=funpsy_ips2nii(cfg)
%FUNPSY_IPS2NII Converts the IPS data created by funpsy_ips into a NIFTI file
%     nii=funpsy_ips2nii(cfg) saves the results in out.results.ips

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


    processID='>>> funpsy_ips2nii';
    psess=funpsy_loadsession(cfg,processID);
    load(cfg.psess);
    % ADD A acheck that we have done IPS from psess.history
    %if(cfg.average==1)
        load(psess.results.ips);    % matrix IPS


	nii=load_nii(psess.coregistered_mask);

        nii.img=double(ips);

        nii.hdr.dime.bitpix=64;
        nii.hdr.dime.datatype=64;
        nii.hdr.dime.dim(1)=4;
        nii.hdr.dime.dim(5)=psess.T;
        nii.hdr.dime
        mkdir([psess.outpath '/nifti/']);
        save_nii(nii,[psess.outpath '/nifti/ips.nii']);


