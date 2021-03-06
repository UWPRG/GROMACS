# Force Field Maker (ffmaker)

Current version of ffmaker produces force field files using [gaussian](http://gaussian.com) and [antechamber](http://ambermd.org). Subsequently, this script should be run on Hyak. An ffmaker version using opensource tools may be in the future. for now the following must be in the path:

`g09root=/gscratch/pfaendtner/codes/G09`

`AMBERHOME=/gscratch/pfaendtner/vjaeger/software/amber11b`

# Quick Start Guide

you will need to edit ffmaker.inp to reflect the molecule you are parameterizing (and make any additional changes suited for your needs):

```
###ALL COMMANDS ARE CASE SENSITIVE. SEE EXAMPLES###

###STANDARD INPUTS###
RESIDUE_NAME=TF2    #three characters, letters should be caps. example: BMI, 1EM, P00
INPUT_TYPE=pdb      #com (recommended), pdb (also a good choice), mol2
CHARGE=-1            #1,-1, or 0 usually
SCALED=yes           #Do you want to scale the charges? (yes, no)
FACTOR=0.8            #Scaling factor.

###CONDITIONAL INPUTS###
REPLACE_HF=no       #You can replace hartee fock with a different method. no (default), b3lyp, mp2
#REPLACE_631=no     #You can replace 6-31G* with a different basis set. no (default), 3-21G, 6-311G*. not currently working.
METHOD=resp         #resp (recommended), esp, bcc
G09_MEM="%mem=1000MB"   #Gaussian memory
G09_PROC="%nproc=16"   #Gaussian processors
REPLACE_FF=no       #Change force field to something other than amber99sb-ildn. no (default), ff99sb
```

As stated in `INPUT_TYPE` you will need to provide a pdb or com file of your molecule. 

guassian/antechamber typically run fine on an interactive node (do not run on the login nodes):

`source ffmaker.bash`
