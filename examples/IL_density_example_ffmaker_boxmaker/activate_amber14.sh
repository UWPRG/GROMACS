module load icc_15.0.3-impi_5.0.3

export AMBERHOME=/suppscr/pfaendtner/vanouk/software/amber14
export PATH="${PATH}:${AMBERHOME}/bin"

if [ -z "${LD_LIBRARY_PATH}" ]; then
   export LD_LIBRARY_PATH="${AMBERHOME}/lib"
else
   export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${AMBERHOME}/lib"
fi
