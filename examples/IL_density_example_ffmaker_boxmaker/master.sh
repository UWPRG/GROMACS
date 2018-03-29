#!/bin/bash
set -e
name=$1
cd ../inputs/
source ${name}.inp
echo "sourcing ${name}.inp"
cat ${name}.inp 
sed -i "3s/.*/name=${name}/" ${name}.inp
wait
source directory.inp
cd -
###*****************************************************************
###Create Force Field Files

source spFF.sh
wait

###*****************************************************************
###Run EQ
  
source spMD.sh 
wait

###*****************************************************************
###Run Analysis

source spAnalysis.sh
wait

echo "job complete"
echo "job complete for ${name} in ${ROOT}" | mail -s "message from hyak" wesleybeckner@gmail.com
