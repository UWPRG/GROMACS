nodes=$(nodestate pfaendtner | grep nodes)
lines=$(nodestate pfaendtner | grep nodes | tee /dev/tty | wc -l)
#if lines = 1 there's only one type of node. Find the type
if [ "$lines" == 1 ] ; then
  type=$(echo $nodes | awk '{print $3}')
  if [ "$type" == "8core" ] ; then
    sed -i "3s/.*/#PBS -l nodes=2:ppn=8/" GROMACS.pbs
    sed -i "4s/.*/#PBS -l feature=8core/" GROMACS.pbs
    sed -i "35s/.*/EXEC=\/gscratch\/pfaendtner\/codes\/gromacs-5.1.2\/inst\/bin\/gmx_8c/" GROMACS.pbs
  elif [ "$type" == "16core" ] ; then
    sed -i "3s/.*/#PBS -l nodes=1:ppn=16/" GROMACS.pbs
    sed -i "4s/.*/#PBS -l feature=16core/" GROMACS.pbs
    sed -i "35s/.*/EXEC=\/gscratch\/pfaendtner\/codes\/gromacs-5.1.2\/inst\/bin\/gmx_mpi/" GROMACS.pbs
  fi
elif [ "$lines" -eq 2 ] || [ "$lines" -eq 0 ] ; then
  sed -i "3s/.*/#PBS -l nodes=1:ppn=16/" GROMACS.pbs
  sed -i "4s/.*/#PBS -l feature=16core/" GROMACS.pbs
  sed -i "35s/.*/EXEC=\/gscratch\/pfaendtner\/codes\/gromacs-5.1.2\/inst\/bin\/gmx_mpi/" GROMACS.pbs
fi
