#!/bin/bash

# This script submits an array job on a single node with the highest
# array index job launching the next set of job recursively.

# Usage:
#   sbatch recursive-array.sh multiplier-initial-value multiplier-max-limit
#   For example:
#   sbatch recursive-array.sh 0 3

#SBATCH --partition=express
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=100M
#SBATCH --output=%A_first_pass_%a.out
#SBATCH --error=%A_first_pass_%a.err
#SBATCH --array=[0-9]

# To keep track of Iteration, create a counter
MULTIPLIER=$1
if [ -z "$MULTIPLIER" ]
then
  MULTIPLIER=0
fi

echo "Multiplier is $MULTIPLIER"

# Determine my task-id
MY_TASK=$((MULTIPLIER * 10 + SLURM_ARRAY_TASK_ID))

echo "Job array ID: $SLURM_ARRAY_JOB_ID , sub-job $SLURM_ARRAY_TASK_ID is running!"
echo "Highest job array index value is $SLURM_ARRAY_TASK_MAX"
echo "MY_TASK is $MY_TASK"

# Science happens here
PARENT_DIR="$(dirname $PWD)"
echo "Main directory for recursive-array script is: $PARENT_DIR"

# Quit when the counter reaches user-specified limit 
USERLIMIT=$2
if [ -z "$USERLIMIT" ]
then
    USERLIMIT=3
fi

echo "USERLIMIT is $USERLIMIT"

if [ $MULTIPLIER -eq $USERLIMIT ]
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
   sbatch recursive-array-v5.sh $((MULTIPLIER + 1)) $USERLIMIT
fi
