#!/bin/bash

#SBATCH --partition=express
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:00:02
#SBATCH --array=[0-9]

MULTIPLIER=$1

if [ -z "$MULTIPLIER" ]
then
  MULTIPLIER=0
fi

echo "multiplier is $MULTIPLIER"

# determine my real task-id
MY_TASK=$((MULTIPLIER * 10 + SLURM_ARRAY_TASK_ID))

echo "Job array ID: $SLURM_ARRAY_JOB_ID , sub-job $SLURM_ARRAY_TASK_ID is running!"
echo "Highest job array index value is $SLURM_ARRAY_TASK_MAX"

echo "MY_TASK is $MY_TASK"

# quit when you have had enough 
if [ "$MULTIPLIER" == "3" ]
then
  exit
fi

# but sometimes you want more
SLEEPVAR=$(( $RANDOM % 5 + 1 ))
echo "sleep time is $SLEEPVAR"

sleep $SLEEPVAR

CMD='squeue -u $USER --jobs=$SLURM_ARRAY_JOB_ID -t pd -h | wc -l'

echo "executing command: $CMD"

PDJOBS=$(squeue -u $USER --jobs=$SLURM_ARRAY_JOB_ID -t pd -h | wc -l)

echo "Pending Jobs are $PDJOBS"

if [ $SLURM_ARRAY_TASK_ID -eq $SLURM_ARRAY_TASK_MAX ]
then
   echo "Continuing Next Iteration"
   sbatch recursive-array-v4.sh $((MULTIPLIER + 1))
fi
