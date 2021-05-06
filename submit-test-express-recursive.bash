#!/bin/bash

# This script submits an array job on a single node with each job                                                                                                                                                                            
# running multiple iterations of the task that needs to be processed. 
#
# Usage:
#   sbatch submit-test-express.bash 

#! /bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=express
#SBATCH --time=01:00:00
#SBATCH --mem-per-cpu=100M
#SBATCH --output=%A_first_pass_%a.out
#SBATCH --error=%A_first_pass_%a.err
#SBATCH --array=1-1000


# keep track of which generation
MULTIPLIER=$1
if [ -z "$MULTIPLIER" ]
then
  MULTIPLIER=0
fi

PARENT_DIR="$(dirname $PWD)"
echo "Main directory for submit-test-express script is: $PARENT_DIR"


echo "Job array ID: $SLURM_ARRAY_JOB_ID , sub-job $SLURM_ARRAY_TASK_ID is running!"

for ((k = 0; k < 3; k++)); do
    # account for the MUlTIPLIER
    REAL_ITERATION=$(( $MULTIPLIER * 1000 + $SLURM_ARRAY_TASK_ID ))
    #srun python test_function_script-mj.py > test-array-express-$SLURM_ARRAY_JOB_ID-$SLURM_ARRAY_TASK_ID-$k.out
    python $PARENT_DIR/test_function_script-mj.py > test-array-express-$SLURM_ARRAY_JOB_ID-$SLURM_ARRAY_TASK_ID-$k.out

done 

# if _all_ the jobs completed successfully
# then submit the next generation of jobs

# in other words, do not submit the next generation
# multiple times
echo sbatch $NAME_OF_SCRIPT $(( MULTIPLIER + 1 ))



