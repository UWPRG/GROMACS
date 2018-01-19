#!/bin/bash
set -e

###PACK THE BOX USING BOXMAKER 
echo " "
echo "checking for setup files"
cd $SETUP
currentTemp=298.15
if [ ! -f $SETUP/conf.gro ] ; then
  cp $SCRIPTS/acpype.py $SETUP/
  cp $INPUTS/packmol.inp $SETUP/
  cp $SCRIPTS/boxmaker.bash $SETUP/
  cp $STRUCTURES/${IL_CAT}* $SETUP/
  cp $STRUCTURES/${IL_AN}* $SETUP/
  cp $SCRIPTS/boxmaker.pbs $SETUP/
  cp $INPUTS/${name}.inp $SETUP/
  cp $INPUTS/directory.inp $SETUP/
  sed -i "8s/.*/source ${name}.inp/" $SETUP/boxmaker.bash
  cd $SETUP/
  qsub boxmaker.pbs
fi
while true ; do
  if [ ! -f $SETUP/conf.gro ] ; then
    echo "waiting for boxmaker to complete"
    sleep 60
  else
    echo "boxmaker complete... moving forward"
    sleep 1
    break
  fi
done
###ENERGY MINIMIZE THE BOXMAKER STRUCTURE
echo " "
echo "beginning energy minimization"
cd $ILhome
if [ ! -d $ILhome/min ] ; then
  mkdir min
  echo "made mini directory"
fi
if [ ! -f min/confout.gro ] && [ ! -f min/md.log ] ; then
  echo "initiating energy minimization" 
  cp $INPUTS/min.mdp min/
  cp $SCRIPTS/GROMACS.pbs min/GROMACS.pbs
  cp $SCRIPTS/nodeseaker.sh min/nodeseaker.sh
  cp $SETUP/conf.gro min/
  cp $SETUP/topol.top min/
  cd min/
  gmx_8c grompp -f min.mdp
  source nodeseaker.sh
  wait
  qsub GROMACS.pbs
  cd -
fi
while true ; do
  if [ ! -f $ILhome/min/confout.gro ] ; then
    echo "waiting for minimization to complete"
    sleep 60
  else
    echo "minimization complete... moving forward"
    sleep 1
    break
  fi
done
###RUN BERENDSEN EQUILIBRATION
echo " "
if [ -f $ILhome/min/confout.gro ] ; then  
  if [ ! -d $ILhome/equilibrate ] ; then
    mkdir $ILhome/equilibrate
    echo "made equilibrate directory"
  fi
  cd $ILhome
  if [ -f equilibrate/confout.gro ] ; then    
    echo "equilibrate files present..."
  elif [ ! -f equilibrate/md.log ] ; then
    echo "creating new files: equilibrate/"
    cd $ILhome/min/
    cp confout.gro ../equilibrate/conf.gro
    cd -
    cp $SCRIPTS/GROMACS_5.pbs equilibrate/GROMACS.pbs
    cp $INPUTS/npt.mdp equilibrate/npt.mdp
    cp $SCRIPTS/nodeseaker.sh equilibrate/nodeseaker.sh
    cp min/topol.top equilibrate/
    cd equilibrate/
    sed -i "51s/.*/ref_t			= ${currentTemp}/" npt.mdp 
    sed -i "62s/.*/gen_temp		= ${currentTemp}/" npt.mdp 
    gmx_8c grompp -f npt.mdp -maxwarn 1
    source nodeseaker.sh
    wait
    qsub GROMACS.pbs
    sleep 5
    cd -
    echo "equilibration setup complete" 
  else
    echo "It looks like equilibration is currently running"
  fi
fi
cd $ILhome/
while true ; do
  if [ ! -f $ILhome/equilibrate/confout.gro ] ; then
    sleep 600
    echo "waiting for equilibration to complete"
    if [ -f $ILhome/equilibrate/md.log ] ; then 
      tail -11 $ILhome/equilibrate/md.log
    fi
  else
    echo "equilibration complete... moving forward"
    sleep 1
    break
  fi
done
echo " "
echo "production runs complete"
cd $SCRIPTS
