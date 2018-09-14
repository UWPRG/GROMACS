#!/bin/bash 
#SBATCH --job-name=*CHANGE*
#SBATCH -p pfaendtner
#SBATCH -A pfaendtner
#SBATCH -N 1       
#SBATCH --ntasks-per-node=28 
#SBATCH -t 12:00:00 
#SBATCH --mail-type=NONE
#SBATCH --mem=120G 

cd $SLURM_SUBMIT_DIR

# loads gromacs 18.3 and plumed 2.4.2

module load icc_17-impi_2017
source /gscratch/pfaendtner/sarah/codes/gromacs18.3/gromacs-2018.3/bin/bin/GMXRC
source /gscratch/pfaendtner/sarah/scripts/activate_plumed2.4.2.sh

# uncomment the following to specify plumed threading 
# export PLUMED_NUM_THREADS=18

#script for submission 

mpiexec.hydra -np 28 gmx_mpi mdrun -s topol.tpr -o traj.trr -x traj.xtc -cpi restart -cpo restart -c confout.gro -e ener.edr -g md.log -ntomp 1

exit 0
