#!/bin/sh

# --- BEGIN GLOBAL DIRECTIVE --
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
# -- END GLOBAL DIRECTIVE --

# -- BEGIN PRE-USER --
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}

source /etc/biac_sge.sh

EXPERIMENT=`findexp $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}

if [ $EXPERIMENT = "ERROR" ]
then
	exit 32
else
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----"

# -- BEGIN USER SCRIPT --
# User script goes here 
SUB=$1 # this should be the .mat file containing task type, scanID, and PTB ID

matlab -nodisplay -nodesktop -nojvm -singleCompThread -r "cd('/mnt/munin2/Cabeza/SchemRep.01/Scripts/SingleTrialModelling');try, ST_wrapper('$SUB'); end; exit;" 

subjectPath=/mnt/munin2/Cabeza/SchemRep.01/Scripts/SingleTrialModelling/scan_info/to_be_submitted/
submittedPath=/mnt/munin2/Cabeza/SchemRep.01/Scripts/SingleTrialModelling/scan_info/already_submitted/
mv ${subjectPath}${SUB} ${submittedPath}${SUB}

OUT_logDIR=${EXPERIMENT}/Scripts/SingleTrialModelling/job_log

echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----"
mv $HOME/$JOB_NAME.$JOB_ID.out $OUT_logDIR/$SUB.$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi