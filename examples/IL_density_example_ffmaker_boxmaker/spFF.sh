#!/bin/bash
set -e

###PACK THE BOX USING BOXMAKER 
echo " "
echo "checking for force field files"
  cp $SCRIPTS/ffmaker.bash $STRUCTURES/
  cp $INPUTS/ffmaker.inp $STRUCTURES/
  cp $SCRIPTS/boxmaker.pbs $STRUCTURES/ffmaker.pbs
  cd $STRUCTURES/
  sed -i "33s/.*/source ffmaker.bash/" ffmaker.pbs
if [ ! -f $STRUCTURES/${IL_CAT}.frcmod ] ; then
  echo "creating cation force field"
  sed -i "4s/.*/RESIDUE_NAME=${IL_CAT}    #three characters, letters should be caps. example: BMI, 1EM, P00/" ffmaker.inp
  sed -i "6s/.*/CHARGE=1            #1,-1, or 0 usually/" ffmaker.inp
  qsub ffmaker.pbs
fi
while true ; do
  if [ ! -f $STRUCTURES/${IL_CAT}.frcmod ] ; then
    echo "waiting for ffmaker to complete"
    sleep 60
  else
    echo " "
    echo "cation force field complete... moving forward"
    sleep 1
    break
  fi
done
if [ ! -f $STRUCTURES/${IL_AN}.frcmod ] ; then
  echo "creating anion force field"
  sed -i "4s/.*/RESIDUE_NAME=${IL_AN}    #three characters, letters should be caps. example: BMI, 1EM, P00/" ffmaker.inp
  sed -i "6s/.*/CHARGE=-1            #1,-1, or 0 usually/" ffmaker.inp
  qsub ffmaker.pbs
fi
while true ; do
  if [ ! -f $STRUCTURES/${IL_AN}.frcmod ] ; then
    echo "waiting for ffmaker to complete"
    sleep 60
  else
    echo "anion force field complete... moving forward"
    sleep 1
    break
  fi
done
echo " "
echo "ffmaker complete"
cd $SCRIPTS
