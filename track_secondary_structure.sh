#!/bin/bash 

#TO DO modify for all secondary structure output types given by STRIDE
#now just works on helix, it is very easy, just add more variables like H= and searches in the awk statement
#ask me for help

STRIDE=/gscratch/pfaendtner/codes/stride/stride

#REF pdb should be from trjconv with pbc whole 
REF=$1
#TRAJ pdb should be your protein only traj made into pdb from trjconv with -pbc whole
TRAJ=$2

refline=`wc -l $1 | awk '{print $1}'`
trajline=`wc -l $2 | awk '{print $1}'`
frame=$((trajline/refline))

rm -rf dumtemp.pdb
rm -rf COLV_stride.txt
for ((i=1;i<=$frame;i++)); do

  head -n $[$i*refline] $TRAJ | tail -n $refline > dumtemp.pdb 
  $STRIDE -f dumtemp.pdb | grep ASG | awk 'BEGIN{H=0;tot=0}{tot=tot+1; if($6=="H") H=H+1}END{print H/tot}' >>  COLV_stride.txt
  rm -rf dumtemp.pdb

done;

rm -rf dumtemp.pdb
