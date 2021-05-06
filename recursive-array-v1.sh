#!/bin/bash

#SBATCH --partition=express
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:00:02
#SBATCH --array=[0-1]

MULTIPLIER=$1

if [ -z "$MULTIPLIER" ]
then
  MULTIPLIER=0
fi

echo "multiplier is $MULTIPLIER"

# determine my real task-id
#MY_TASK=$(( $MULTIPLIER * 10 + $SLURM_ARRAY_TASK_ID ))
MY_TASK=$((MULTIPLIER * 10 + SLURM_ARRAY_TASK_ID))

echo "Job array ID: $SLURM_ARRAY_JOB_ID , sub-job $SLURM_ARRAY_TASK_ID is running!"

echo "MY_TASK is $MY_TASK"

#echo "Multiplier value is $MULTIPLIER"

# quit when you have had enough 
if [ "$MULTIPLIER" == "3" ]
then
  exit
fi

# but sometimes you want more
SLEEPVAR=$(( $RANDOM % 5 + 1 ))
echo "sleep time is $SLEEPVAR"

#echo "$(( $RANDOM % 5) + 1)"
#sleep $(( $RANDOM % 5) + 1)s
sleep $SLEEPVAR s

CMD="squeue -u m.joshi --jobs=$SLURM_ARRAY_JOB_ID -t pd -h | wc -l"

echo "executing command: $CMD"

MORE=$( `$CMD` )

echo "More is $MORE"

if [ $MORE -eq 0 ]
then
   echo "making more"
   sbatch recursive-array.sh $((MULTIPLIER + 1 ))
fi