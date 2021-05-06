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
#SBATCH --array=[0-9]

# Not redirecting the output & error to corresponding files but can be
# done if desired.

# To keep track of Iteration, create a counter
MULTIPLIER=$1
if [ -z "$MULTIPLIER" ]
then
  MULTIPLIER=0
fi

#PARENT_DIR="$(dirname $PWD)"
WORKDIR=$PWD
echo "Main directory for recursive-array script is: $WORKDIR"

# Create a directory corresponding to each iteration                                                                                                                                                                                             
# number, Slurm Job ID, & Slurm Array Index.
DIRNAME=d$MULTIPLIER-$SLURM_ARRAY_JOB_ID-$SLURM_ARRAY_TASK_ID
mkdir $DIRNAME

# Switch to that directory, capture screen output, and execute your
# science there
#cd $DIRNAME
echo "Entering directory"
pushd $DIRNAME
echo "In $DIRNAME" >> screen.out

echo "Multiplier is $MULTIPLIER" >> screen.out

# Determine my task-id
MY_TASK=$((MULTIPLIER * 10 + SLURM_ARRAY_TASK_ID))

echo "Job array ID: $SLURM_ARRAY_JOB_ID , sub-job $SLURM_ARRAY_TASK_ID is running!" >> screen.out
echo "Highest job array index value is $SLURM_ARRAY_TASK_MAX" >> screen.out
echo "MY_TASK is $MY_TASK" >> screen.out

# Science happens here
for ((k = 0; k < 3; k++)); do 
    python $WORKDIR/test_function_script-mj.py > test-array-express-$SLURM_ARRAY_JOB_ID-$SLURM_ARRAY_TASK_ID-$k.out

done 

# Switch back to the working directory
#cd $WORKDIR
echo "Exiting current directory and moving back to directory of origin"
popd

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

# Put to sleep for few seconds
SLEEPVAR=$(( $RANDOM % 5 + 1 ))
echo "sleep time is $SLEEPVAR" 

sleep $SLEEPVAR

# Start next generation of iterations only when array index matches
# the highest array index
if [ $SLURM_ARRAY_TASK_ID -eq $SLURM_ARRAY_TASK_MAX ]
then
   echo "Continuing Next Iteration"
   sbatch recursive-array-v9.sh $((MULTIPLIER + 1)) $USERLIMIT
fi
