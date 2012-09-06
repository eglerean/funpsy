%
% This is a demo file to load the parameters of your analysis. Please refer to the manual.
%


funpsy();

% EDIT BELOW HERE

%% INPUT DATA // An array of strings of valid files with location
% For data requirements look at the manual

cfg=[];  % this will contain the parameters of our expriment

cfg.indata{1}='./fMRIdata/subject_1/1.nii';
cfg.indata{2}='./fMRIdata/subject_2/2.nii';
cfg.indata{3}='./fMRIdata/subject_3/3.nii';
% etc.. for all subjects

% ... or the same with a for cycle

for s=1:16
    cfg.indata{s}=['./fMRIdata/subject_' num2str(s) '/' num2str(s)  '.nii'];
end

% OUTPUT FOLDER // A folder where the software will write all data. 
% Disk space: you need at least twice the space occupied by the original datasets
cfg.outpath='./funpsy_out/';   % Please, create the folder before using it

% SAMPLING RATE // In Hertz (1/TR)
cfg.Fs=1/2; 

% FILTER BAND // In Hertz, it has to be a four element vector
cfg.F=[0.025 0.04 0.07 0.09];

% FILTER DEVIATION // see 'help firpmord'
cfg.DEV=[0.05 0.01 0.05];

% BRAIN MASKS // masks that the software will use
cfg.coregistered_mask='/proj/braindata2/neurocinematics/HarvardOxford/MNI152_T1_2mm_brain_mask.nii';
cfg.compute_group_mask = 1;     % if = 1, it computes a group mask based on the power of each voxel
cfg.compute_spectrum = 0;       % if = 1, it computes a group frequency spectrum for each voxel

% NAME OF YOUR ANALYSIS SESSION
cfg.session_name = 'test_funpsy';

% RUN PRE-ANALYSIS
sessionfile=funpsy_makepsess(cfg);  % validates input parameters
                                    % sessionfile will be the only variable needed in next function calls
                                    % it's a string with the path to the matlab file with all informations about
                                    % this phase analysis session


%% MAKE THE DATA // creates analytic signal
cfg=[];
cfg.sessionfile=sessionfile;
% cfg.compute_group_mask=1;     % overrides session settings
% cfg.compute_spectrum=1;       % overrides session settings
out = funpsy_makedata(cfg);     % filters, compute masks and creates the analytic signal


%% Pairwise ROIs analysis
cfg=[];
cfg.sessionfile=sessionfile;
cfg.rois=rois;
out = funpsy_makeroidata(cfg);  % extract first principal component for each roi

% SBPS (Seed Based Phase Synchrony)
cfg=[];
cfg.sessionfile=sessionfile;
%cfg.rois=rois;                  % a list of ROIs (at least 2!)
cfg.ppc=0;
out = funpsy_sbps(cfg);         % takes a list of seeds/rois and computes full differential functional phase synchrony
                                % between each pair of seeds/rois.
                                % results stored in out.results.dfps

%% Whole brain analysis
cfg=[];
cfg.sessionfile=sessionfile;
out = funpsy_ips(cfg);          % compute whole brain intersubject phase synchrony
                                % results stored in out.results.ips
                         
%% Statistics
% SBPS (pairwise ROI analysis)
cfg=[];
cfg.sessionfile=sessionfile;
cfg.nonparam=1;     % recommended. If 0 uses parametric tests. 
cfg.parallel = 1;   % Experimental feature - uses parallel computing
cfg.perm=1000;     % for each ROI pair, does a non parametric test
                    % NOTE: the rois are already specified in data creation
                    % To modify them you need to rerun the analysis
cfg.statstype='dfps';
out = funpsy_stats(cfg);    % results in out.dfps_stats


% IPS (Whole)
cfg.statstype='ips';
out = funpsy_stats(cfg);    % results in out.ips_stats
