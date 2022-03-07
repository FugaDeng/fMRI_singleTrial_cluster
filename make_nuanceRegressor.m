function make_nuanceRegressor(fName,timepoints,saveName)
% takes fMRIprep confounds.tsv as input and convert the signals to matlab
% file for SPM
% the timepoints argument is for removing the first few volumes

%%

tmp=tdfread(fName);
%%
% R: timepoints x types 

R0 = [tmp.global_signal,... 
    tmp.csf,... 
    tmp.white_matter,... 
    tmp.trans_x,...
    tmp.trans_y,...
    tmp.trans_z,...
    tmp.rot_x,...
    tmp.rot_y,...
    tmp.rot_z];

Rdiff = [zeros(1,size(R0,2));
    diff(R0,1)];

try
    fd = [0 ; str2num(tmp.framewise_displacement(2:end,:))];
    rmsd = [0; str2num(tmp.rmsd(2:end,:))];
    R = [R0, Rdiff, fd, rmsd];
catch
    R = [R0, Rdiff];
end

R = R(timepoints,:);

for i=1:size(R,2)
    tmptc=R(:,i);
    tmptc(isnan(tmptc)) = mean( tmptc, 'omitnan');
    R(:,i)=tmptc;
end

%%


save(saveName,'R');




% 
% fID=fopen(motionfName);
% R=fscanf(fID,'%d %f',[6 Inf]);
% R=R';
% R=R(timepoints,:);
% fclose(fID);
% 
% %% CHANGE THIS SECTION WHEN MOVING TO CLUSTER
% addpath('D:\MATLABlib\NIfTI_toobox') %!!
% wmask=load_nii('D:\Research_local\SchemRep\data_sample\resample_atlases\WhiteMask_3mm_53x63x52.nii');
% wmask=wmask.img;
% csfmask=load_nii('D:\Research_local\SchemRep\data_sample\resample_atlases\CsfMask_3mm_53x63x52.nii');
% csfmask=csfmask.img;