echo " "
echo "starting Analysis"
if [ ! -d ${ILhome}/analysis ] ; then
  mkdir ${ILhome}/analysis
fi
  cd ${ILhome}/equilibrate
###*****************************************************************
###density
if [ ! -f density.xvg ] ; then
echo "calculating density" 
sed -i "6s/.*/#PBS -l walltime=1:00:00/" GROMACS.pbs
sed -i "37s/.*/traj=traj_comp/" GROMACS.pbs
sed -i "38s/.*/echo 0 | \$EXEC density -f \${traj}.xtc -s -xvg none/" GROMACS.pbs
qsub GROMACS.pbs
while true ; do
  if [ -f density.xvg ] ; then
    break
  else
    echo "waiting for density calculation"
    sleep 20 
  fi
done
fi
if [ ! -f ${ILhome}/analysis/${name}.dens ] ; then
  grep ^" " density.xvg | awk '{print $1,$2}' | tr ' ' ',' >> temp
  mv temp ${ILhome}/analysis/${name}.dens 
fi
echo "equilibrium analysis complete"
cd $SCRIPTS
