#!/bin/bash
#PBS -N leureo_mult.nvt	
#PBS -l nodes=1:ppn=16
#PBS -l feature=16core
#PBS -l mem=22gb
#PBS -l walltime=24:00:00
## Put the output from jobs into the below directory
## Put both the stderr and stdout into a single file
#PBS -j oe
## Sepcify the working directory for this job

### You shouldn't need to change anything in this section ###
###                                                       ###
# Total Number of processors (cores) to be used by the job
HYAK_NPE=$(wc -l < $PBS_NODEFILE)
# Number of nodes used by MPICH
HYAK_NNODES=$(uniq $PBS_NODEFILE | wc -l )

### You shouldn't need to change anything in this section ###
###                                                       ###
echo "**** CPU and Node Utilization Information ****"
echo "This job will run on $HYAK_NPE total CPUs on $HYAK_NNODES different nodes"
echo ""
echo "Node:CPUs Used"
uniq -c $PBS_NODEFILE | awk '{print $2 ":" $1}'
echo "**********************************************"

module unload icc_14.0.2-impi_4.1.3.049
module load icc_15.0.3-impi_5.0.3

export PATH=$PATH:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/bin
export INCLUDE=$INCLUDE:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/lib
source /gscratch/pfaendtner/codes/gromacs-5.1.2/inst/bin/GMXRC
EXEC=/gscratch/pfaendtner/codes/gromacs-5.1.2/inst/bin/gmx_mpi
cd $PBS_O_WORKDIR

mpiexec.hydra -rmk pbs $EXEC mdrun -cpi restart -cpo restart -append -cpt 1.0 


### include any post processing here                      ###
###                                                       ###
#

exit 0

