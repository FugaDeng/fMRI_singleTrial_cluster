function ST_wrapper(infofile)

% inputs needed: a file with name like 'sub-03320.mat', that contains the
% scanID like '102' and the type of task
%%
addpath('/mnt/munin2/Cabeza/SchemRep.01/Scripts/spm12')
%%
sessinfo=load(fullfile('/mnt/munin2/Cabeza/SchemRep.01/Scripts/SingleTrialModelling/scan_info/to_be_submitted/',infofile));
scanID=sessinfo.scanID;
subjectID=sessinfo.subjectID;
scanDay=sessinfo.scanDay; % 'Day1', 'Day2', 'Day3'
%
behFilePath='/mnt/munin2/Cabeza/SchemRep.01/Analysis/behavFiles';
%
imgbasedir='/mnt/munin2/Cabeza/SchemRep.01/Data/fMRIprep_out/fmriprep';
imgdir=fullfile(imgbasedir, ['sub-' scanID], 'ses-1', 'func');
if exist(imgdir,'dir')==0
    disp('cannot find preprocessed fMRI data. quitting the job now')
    return
else
    disp(['found image directory ' imgdir])
end
% add folders like '102/Day1' as a subdirectory of resultsbasedir. mkdir if the
% folder doesn't exist.
resultsbasedir='/mnt/munin2/Cabeza/SchemRep.01/Data/SingleTrial_unsmoothed';
resultsdir=fullfile(resultsbasedir, subjectID, scanDay);
if exist(resultsdir,'dir')==0
    mkdir(resultsdir)
else
    disp('result directory already exists!')
end
%%
%% handle different types of tasks

switch scanDay
    case 'Day1'
        funcImgs={...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-BL_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-BL_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-BL_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] )};%%%
        confoundfiles={...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-BL_run-1_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-BL_run-2_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-BL_run-3_desc-confounds_timeseries.tsv'] )};%%%
        funcFrames{1}=5:162; % BL
        funcFrames{2}=5:162;
        funcFrames{3}=5:162;
        
    case 'Day2'
        funcImgs={...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-ENC_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-ENC_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-ENC_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] )};%%%
        confoundfiles={...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-ENC_run-1_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-ENC_run-2_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-ENC_run-3_desc-confounds_timeseries.tsv'] )};%%%
        funcFrames{1}=5:276; % ENC
        funcFrames{2}=5:276;
        funcFrames{3}=5:276;
        
    case 'Day3'
        funcImgs={...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RCON_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RCON_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RCON_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RVIS_run-4_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RVIS_run-5_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RVIS_run-6_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'] )};%%%
        confoundfiles={...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RCON_run-1_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RCON_run-2_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RCON_run-3_desc-confounds_timeseries.tsv'] ),...
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RVIS_run-4_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RVIS_run-5_desc-confounds_timeseries.tsv'] ),...%%%
            fullfile(imgdir, ['sub-' scanID '_ses-1_task-RVIS_run-6_desc-confounds_timeseries.tsv'] )};%%%
        funcFrames{1}=5:190; % RCON
        funcFrames{2}=5:190;
        funcFrames{3}=5:190;
        funcFrames{4}=5:168; % RVIS
        funcFrames{5}=5:168;
        funcFrames{6}=5:168;
end

%%
for i=1:length(funcImgs) %3 runs
    try
        % create a folder for storing single-trial outputs for a specific run
        tmprundirBase = fullfile(resultsdir,['run' num2str(i)]);
        disp(tmprundirBase)
        mkdir(tmprundirBase)
        disp(['mkdir temporary directory OK: run' num2str(i) ' of ' scanDay])
        % load trial onset information from behavior files
        switch scanDay
            case 'Day1'
                pdata=load(fullfile(behFilePath, 'BL', ['S' subjectID, '_run', num2str(i), '.mat'] ));
                onsets=cell2mat(pdata.pdata.tObjOnset)'; % OK
                durations = repmat(4,length(onsets),1);% OK
                assert(length(onsets)==38); % OK
            case 'Day2'
                pdata=load(fullfile(behFilePath, 'ENC', ['S' subjectID, '_run', num2str(i), '.mat'] ));
                sceneOnset=cell2mat(pdata.pdata.tTrial)';
                objectOnset=cell2mat(pdata.pdata.tObjOnset)';
                onsets = zeros(length(sceneOnset)*2,1);
                onsets(1:2:end)=sceneOnset;
                onsets(2:2:end)=objectOnset;
                durations = repmat([3;4],length(sceneOnset),1);% scene 3s, object 4s
                assert(length(onsets)==38*2);
            case 'Day3'
                if i<4 % conceptual
                    pdata=load(fullfile(behFilePath, 'RET_con', ['S' subjectID,  '_run', num2str(i), '_RC.mat'] ));
                    onsets=cell2mat(pdata.pdata.tObjOnset)'; % OK
                    durations = repmat(4,length(onsets),1);% OK
                    assert(length(onsets)==48); % OK
                else % visual
                    pdata=load(fullfile(behFilePath, 'RET_vis', ['S' subjectID,  '_run', num2str(i-3), '_RV.mat'] ));
                    onsets=cell2mat(pdata.pdata.tObjOnset)'; % OK
                    durations = repmat(4,length(onsets),1);% OK
                    assert(length(onsets)==42); % OK
                end
        end
        disp(['load behav file OK: run' num2str(i) ' of ' scanDay])
        % regressor processing
        nuaregr=fullfile(tmprundirBase, 'regressors.mat'); % the name of the regressor file to create
        make_nuanceRegressor(confoundfiles{i},funcFrames{i},nuaregr)
        disp(['create regressor file OK: run' num2str(i) ' of ' scanDay])
        % unzip functional images
        if exist(funcImgs{i},'file')==0
            disp([funcImgs{i} ' not exist'])
            if exist( [funcImgs{i} '.gz'],'file')~=0
                disp('zip file of the nifti image exist, try unzipping')
                [~,cmdout]=system(['gunzip ' funcImgs{i} '.gz']);
                disp(cmdout)
                % gunzip([ funcImgs{i}, '.gz']) requires Java, not working
            end
        end
        disp(['unzip OK: run' num2str(i) ' of ' scanDay])
        % run the single trial model for the current run
        matlabbatch=ST_base(funcImgs{i},funcFrames{i},onsets,durations,nuaregr,tmprundirBase); % #ok <NASGU>
        save(fullfile([tmprundirBase, 'SPM_jobs.mat']),'matlabbatch')
        disp(['success: run' num2str(i) ' of ' scanDay])
    catch
        disp(['error: run' num2str(i) ' of ' scanDay])
    end
end
