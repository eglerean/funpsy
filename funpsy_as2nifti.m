function funpsy_as2nifti(cfg)

% FUNPSY_AS2NIFTI Saves the analytic signal into a NIFTI file
% funpsy_as2nifti(cfg)
%   'cfg' is a struct with mandatory and optional fields
% 	cfg.psess=sessionfile.mat;	path to the session file
% 	cfg.type='real';	other options 'imaginary', 'amplitude', 'phase', 'complex'	
%   OPTIONAL:
% 	cfg.subject = 1; 	a vector with a subject number, if empty it does it for all subjects
% 	cfg.outpath = STRING; the folder where the data will be saved ('/path/to/folder/', if empty it saves it in the analysis path)
%

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


load(cfg.psess);

nii=load_nii(psess.coregistered_mask);

for s=1:psess.Nsubj;
	disp(['converting subject ' num2str(s)]);
	img=zeros(91,109,91,psess.T);
	for t=1:psess.T
		disp(num2str(t));
		load([psess.outdata{s} '/' num2str(t) '.mat']);	% variable Hvol

		img(:,:,:,t)=real(Hvol);
	end
	
	nii.img=img;
	nii.hdr.dime.bitpix=64;
	nii.hdr.dime.datatype=64;
	nii.hdr.dime.dim(1)=4;
	nii.hdr.dime.dim(5)=psess.T;
	nii.hdr.dime
	mkdir([psess.outpath '/nifti/']);
	save_nii(nii,[psess.outpath '/nifti/' num2str(s) '_real' '.nii']);
end

