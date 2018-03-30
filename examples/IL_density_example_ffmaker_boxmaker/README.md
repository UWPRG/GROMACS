
<small>This notebook was put together by [wesley beckner](http://wesleybeckner.github.io)</small>

In the following I use force field maker and box maker to automate ionic liquid (ILs) property calculations in GROMACS

# Setup

You can copy the contents of this directory into your own new directory on hyak.

Running `source setup.sh` will result in the following directory structure for you:

```
$ tree
.
├── inputs
│   ├── boxmaker.inp
│   ├── directory.inp
│   ├── ffmaker.inp
│   ├── min.mdp
│   ├── npt.mdp
│   ├── packmol.inp
│   ├── salt.inp
│   └── salt.sh
├── scripts
│   ├── acpype.py
│   ├── activate_amber14.sh
│   ├── boxmaker.bash
│   ├── boxmaker.pbs
│   ├── environment.sh
│   ├── ffmaker.bash
│   ├── GROMACS.pbs
│   ├── master.sh
│   ├── nodeseaker.sh
│   ├── setup.sh
│   ├── spAnalysis.sh
│   ├── spFF.sh
│   └── spMD.sh
├── structures
│   ├── BMI.pdb
│   └── TF2.pdb
└── systems

```

within `salt.inp` you will find:

`BMI,TF2,1.456`

executing the following command within the inputs directory:

`source salt.sh salt.inp`

will produce an output like the following:

```
Cation: BMI Anion: TF2 Density: 1.456
419.355
carbons: 10
chlorines: 0
fluorines: 6
hydrogens: 15
nitrogens: 3
oxygens: 4
sulfurs: 2
```

what `salt.sh` is doing is reading the cation, anion, and estimated density from `salt.inp` to automatically fill our `boxmaker.inp` file with this information and the molecular weight of the cation-anion pair. This is very useful when creating a large amount of salt systems!

You will notice a new file has been added to your directory: `BMI_TF2.inp`

# Simulation & Analysis

In the scripts directory run:

`source master.sh BMI_TF2`

and ffmaker/boxmaker will execute for the BMI_TF2 system along with an energy minimization and npt equilibration step in GROMACS. Because we are only interested in analyzing the density for this demo, an automated analysis of the density is performed on the equilibration step--density resolves quickly in an IL simulation. 

running `source master <cation>_<anion>` when the simulation has already been completed will result in an output like the following:

```
checking for force field files

cation force field complete... moving forward
anion force field complete... moving forward

ffmaker complete

checking for setup files
boxmaker complete... moving forward

beginning energy minimization
minimization complete... moving forward

equilibrate files present...
equilibration complete... moving forward

production runs complete

starting Analysis
equilibrium analysis complete
job complete
```


