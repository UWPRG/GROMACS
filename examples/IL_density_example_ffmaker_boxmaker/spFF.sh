#!/bin/bash
set -e

###PACK THE BOX USING BOXMAKER 
echo " "
echo "checking for force field files"
  cp $SCRIPTS/ffmaker.bash $STRUCTURES/${name}.bash
  cp $INPUTS/ffmaker.inp $STRUCTURES/${name}.inp
  cp $SCRIPTS/boxmaker.pbs $STRUCTURES/${name}.pbs
  cd $STRUCTURES/
  sed -i "33s/.*/source ${name}.bash/" ${name}.pbs
  sed -i "40s/.*/source ${name}.inp/" ${name}.bash
  sed -i "44s/.*/cat ${name}.inp/" ${name}.bash
if [ ! -f $STRUCTURES/${IL_CAT}.frcmod ] ; then
  echo "creating cation force field"
  sed -i "4s/.*/RESIDUE_NAME=${IL_CAT}    #three characters, letters should be caps. example: BMI, 1EM, P00/" ${name}.inp
  sed -i "6s/.*/CHARGE=1            #1,-1, or 0 usually/" ${name}.inp
  qsub ${name}.pbs
fi
while true ; do
  bad_news=`grep "ERROR: ${IL_CAT}.mol2" leu* | wc -l`
  if [ $bad_news -gt 0 ] ; then
    echo "error creating mol2 file for ${name}. Exiting"
    #echo "gaussian error for ${name} in ${ROOT}" | mail -s "sad message from hyak" wesleybeckner@gmail.com
    return 1
  elif [ ! -f $STRUCTURES/${IL_CAT}.frcmod ] ; then
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
  sed -i "4s/.*/RESIDUE_NAME=${IL_AN}    #three characters, letters should be caps. example: BMI, 1EM, P00/" ${name}.inp
  sed -i "6s/.*/CHARGE=-1            #1,-1, or 0 usually/" ${name}.inp
  qsub ${name}.pbs
fi
while true ; do
  bad_news=`grep "ERROR: ${IL_AN}.mol2" leu* | wc -l`
  if [ $bad_news -gt 0 ] ; then
    echo "error creating mol2 file for ${name}. Exiting"
    #echo "gaussian error for ${name} in ${ROOT}" | mail -s "sad message from hyak" wesleybeckner@gmail.com
    return 1
  elif [ ! -f $STRUCTURES/${IL_AN}.frcmod ] ; then
    sleep 60
  else
    echo "anion force field complete... moving forward"
    sleep 1
    break
  fi
done
echo " "
echo "ffmaker for ${name} complete"
cd $SCRIPTS
