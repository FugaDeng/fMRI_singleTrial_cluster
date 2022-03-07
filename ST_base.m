function matlabbatch=ST_base(imagename,funcFrames,onsets,durations,regressorfile,tmpdirBase)
% performs single trial analysis for one run
% funcFrames: use this to discard the first 4 frames, e.g., 5:190
% regressorfile: full path to the regressor file
% tmpdirBase: a path for storing temporary analyses files
imagevols = cell(length(funcFrames),1);
for i=1:length(funcFrames)
    imagevols{i} = [imagename,',',num2str(funcFrames(i))];
end
% regressorfile = 'path to regressor file';
assert(length(onsets)==length(durations));

%% main loop
matlabbatch=cell(length(onsets)*2,1);

for i=1:length(onsets)
    tmpdir=fullfile(tmpdirBase,['trial' num2str(i)]);%%%
    mkdir(tmpdir)
    %
    tmpind = setdiff( 1:length(onsets) , i );
    noInterestOnsets = onsets(tmpind);
    noInterestDurations = durations(tmpind);
    interestOnset = onsets(i);
    interestDuration = durations(i);
    %
    matlabbatch{i*2-1}.spm.stats.fmri_spec.dir = {tmpdir}; %#ok<*AGROW>
    matlabbatch{i*2-1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{i*2-1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.timing.fmri_t = 36;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.timing.fmri_t0 = 18;% formerly 1, modified to match fMRIprep->3dTshift
    %
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.scans = imagevols;
    %
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(1).name = 'Inteterest';
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(1).onset = interestOnset;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(1).duration = interestDuration;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
    %    
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(2).name = 'NO_inteterest';
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(2).onset = noInterestOnsets;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(2).duration = noInterestDurations;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
    %
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.multi_reg = {regressorfile};
    matlabbatch{i*2-1}.spm.stats.fmri_spec.sess.hpf = 128;
    %
    matlabbatch{i*2-1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{i*2-1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];
    matlabbatch{i*2-1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{i*2-1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{i*2-1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{i*2-1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    %
    matlabbatch{i*2}.spm.stats.fmri_est.spmmat = {fullfile(tmpdir,'SPM.mat')};
    matlabbatch{i*2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{i*2}.spm.stats.fmri_est.method.Classical = 1; 
end
% run the jobs
%try
spm_jobman('initcfg')
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);
%catch
%    disp('jobs failed to run')
%end
