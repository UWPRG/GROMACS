#!/bin/bash

module load icc_15.0.3-impi_5.0.3
export PATH=$PATH:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/bin
export INCLUDE=$INCLUDE:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/lib
source /gscratch/pfaendtner/codes/gromacs-5.1.2/inst/bin/GMXRC
