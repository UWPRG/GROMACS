#!/bin/bash 
#SBATCH --job-name=*CHANGE*
#SBATCH -p pfaendtner 
#SBATCH -A pfaendtner
#SBATCH -N 1       
#SBATCH --ntasks-per-node=16 
#SBATCH -t 12:00:00 
#SBATCH --mail-type=NONE
#SBATCH --mem=20G 

cd $SLURM_SUBMIT_DIR

# calls Gromacs18.3 and Plumed-2.4.2 which were compiled with icc-17

module load icc_17-impi_2017
source /suppscr/pfaendtner/codes/gromacs18.3/gromacs-2018.3/bin/bin/GMXRC
source /suppscr/pfaendtner/codes/plumed-2.4.2_july2/plumed-2.4.2/sourceme.sh

# uncomment the following flag to adjust plumed threading 
#export PLUMED_NUM_THREADS=16

#
#script for submission 

mpiexec.hydra -np 16 gmx_mpi mdrun -s topol.tpr -o traj.trr -x traj.xtc -cpi restart -cpo restart -c confout.gro -e ener.edr -g md.log -ntomp 1

exit 0
