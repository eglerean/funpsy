function sessionfile=funpsy_makepsess(cfg)

%FUNPSY_MAKEPSESS Creates an analysis session for FUNPSY
%   sessionfile=funpsy_makepsess(cfg) returns a string with the path of the math file containing the
%   session file. The analysis session is the main handle between the processed data and the user.
%   'cfg' is a struct with mandatory and optional fields
%       cfg.indata = CELL ARRAY OF STRINGS; an array with paths with 4D NIFTI files for each subject
%       cfg.outpath = STRING; the folder where the data will be saved
%       cfg.Fs=1/TR;    the sampling frequency in Hertz, 1 over TR. 
%       cfg.F=[Fcut_low Fpass_low Fpass_high Fcut_high]; the specification of the bandpass filter, e.g. cfg.F=[0.025 0.04 0.07 0.09];
%       cfg.DEV=[0.05 0.01 0.05];   the tollerance for the FIR design
%       cfg.coregistered_mask='MNI152_T1_2mm_brain_mask.nii';   a brain mask (where the actual signal is in the 3D space)
%       cfg.compute_group_mask=1;     % if = 1, it computes a group mask based on the power of each voxel
%       cfg.compute_spectrum=1;       % if = 1, it computes a group frequency spectrum for each voxel
%       cfg.session_name = 'session_name'; the name of your session for your reference


%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%


processID='funpsy_makepsess >> ';

%% check that we have the right toolboxes
% NIFTI toolbox
hasnifti = exist('load_nii.m');
if(hasnifti ~= 2)
    error([processID 'It seems you do not have the NIFTI toolbox in your path.'])
end

%% check that we have specified all fields
% to be added here

%% processing starts

%% Input validation
% output path
    
if(cfg.outpath(end) ~= '/')
    cfg.outpath=[cfg.outpath '/'];
end

if(~exist(cfg.outpath))
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(cfg.outpath);
    if(SUCCESS)
        disp([processID 'Folder ' cfg.outpath ' created']);
    else
        error([processID 'Could not create ' cfg.outpath '.' MESSAGE]);
    end
end

psess.outpath=cfg.outpath;
sessionfile=[cfg.outpath cfg.session_name '.mat'];
psess.sessionfile=sessionfile;
psess.session_name=cfg.session_name;
psess.history.init=0;

alreadythere=0;
if(exist(psess.sessionfile))
    alreadythere=1;
    fprintf('%s\n',[processID 'Session ' psess.sessionfile ' exists. ']);
end

overexists=isfield(cfg,'overwrite');
overwrite=0;
if(overexists==1)
    overwrite=cfg.overwrite;
end

if(alreadythere==1 && overwrite == 1)
    fprintf('%s\n',[processID 'The session will be overwritten, all previous data will be lost.'])
    % should add here a cleaning script to remove old data
end

if(alreadythere==1 && overwrite == 0)
    fprintf('%s\n',[processID 'The session will not be overwritten.']);
    load(psess.sessionfile)
    psess
    disp([processID 'No new session created']);
    return
end

fprintf('%s\n',[processID 'Session file ' psess.sessionfile ' does not exist. Creating a new one']);

if(~exist([psess.outpath 'ASdata/']))
    mkdir([psess.outpath 'ASdata/']);  % where the analytic signal will go
end

% input/output data
if(ismember(1,size(cfg.indata)))
    psess.Nsubj=length(cfg.indata);
else
    error([processID 'Input data array is not a valid one dimensional array'])
end

for s=1:psess.Nsubj
    psess.indata{s}=cfg.indata{s};
    if(~exist(psess.indata{s}))
        error([processID 'File ' psess.indata{s} ' does not exist.']);
    end
    [hdr, filetype, fileprefix, machine] = load_nii_hdr(psess.indata{s});
    if(s == 1)
        prev_hdr=hdr;
        psess.datasize=hdr.dime.dim(2:5);
    else
        if(length(find(hdr.dime.dim ~= prev_hdr.dime.dim))>0)
            error([processID 'File ' psess.indata{s} ' has incompatible NIFTI dimensions']);
        end
        prev_hdr=hdr;
    end    
    
    psess.outdata{s}=[psess.outpath 'ASdata/' num2str(s) '/'];
    if(~exist(psess.outdata{s})) 
        mkdir(psess.outdata{s}); 
    end
end


%% Filter

if(length(cfg.F)~=4)
    error([processID 'Wrong filter bands']);
end
if(length(cfg.DEV)~=3)
    error([processID 'Wrong tollerances in bands']);
end

cfg.A=[0 1 0];

[N,Fo,Ao,W] = firpmord(cfg.F,cfg.A,cfg.DEV,cfg.Fs);
if(mod(N,2)==1)
    N=N+1;	% it has to be even -> b is odd -> delay is integer = N/2
end
psess.filter.b=firpm(N,Fo,Ao,W);
psess.filter.N=N;
psess.filter.F=cfg.F;
psess.filter.Fs=cfg.Fs;
psess.filter.A=cfg.A;
psess.filter.DEV=cfg.DEV;

%% other params, they can be overwritten
psess.coregistered_mask=cfg.coregistered_mask;
psess.compute_group_mask=cfg.compute_group_mask;
psess.compute_spectrum=cfg.compute_spectrum;
psess.NFFT=512;

psess.history.init=1;

%% save the session data
save(sessionfile,'psess');
disp([processID 'Session created and stored in ' psess.sessionfile]);

