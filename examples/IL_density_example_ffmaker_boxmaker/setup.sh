#!/bin/bash
ROOT=$PWD
sed -i "2s~.*~ROOT=${ROOT}~" directory.inp
mkdir scripts
mkdir structures
mkdir inputs
mkdir systems
mv salt.sh inputs/
mv *.pdb structures/
mv *.inp inputs/
mv *.mdp inputs/
mv *.py scripts/
mv *.bash scripts/
mv *.pbs scripts/
mv *.sh scripts/

