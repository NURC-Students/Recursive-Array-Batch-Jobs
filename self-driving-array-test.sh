#!/bin/bash

#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:00:2
#SBATCH --array=[0-9]%2

MULTIPLIER=$1

if [ -z "$MULTIPLIER" ]
then
  MULTIPLIER=0
fi

# determine my real task-id
MY_TASK=$(( $MULTIPLIER * 10 + $SLURM_ARRAY_TASK_ID ))

echo "MY_TASK is $MY_TASK"

# quit when you have had enough 
if [ "$MULTIPLIER" == "3" ]
then
  exit
fi

# but sometimes you want more
sleep $[ ( $RANDOM % 5 ) + 1 ]s
MOAR=$( squeue -u gshomo -t pd -h | wc -l )
if [ $MOAR -eq 0 ]
then
   echo "making moar"
   sbatch self-driving-array-test.sh $(( $MULTIPLIER + 1 ))
fi

