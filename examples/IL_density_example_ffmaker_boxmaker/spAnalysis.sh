echo " "
echo "starting Analysis"
if [ ! -d ${ILhome}/analysis ] ; then
  mkdir ${ILhome}/analysis
fi
  cd ${ILhome}/equilibrate
###*****************************************************************
###heat capacity   
if [ ! -f ${ILhome}/analysis/${name}.cpt ] ; then
  nmol=`tail -2 conf.gro | head -1 | awk '{print $1}' | sed "s/[[:alpha:].-]/ /g" | awk '{print $1}'`
  echo "calculating heat capacity" 
  echo 10 13 22 0 | gmx_8c energy -f ener.edr -driftcorr -fluct_props -nmol ${nmol} >> temp
  rm energy.xvg
  grep -i 'Heat capacity' temp >> ${name}.cpt 
  mv ${name}.cpt ${ILhome}/analysis/
  rm temp
fi
wait
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
