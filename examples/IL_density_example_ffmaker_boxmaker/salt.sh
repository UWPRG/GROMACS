#!/bin/bash
source directory.inp
while IFS=',' read xx yy zz ; do
  echo "Cation: $xx Anion: $yy Density: $zz"
  cp boxmaker.inp ${xx}_${yy}.inp
  sed -i "19s/.*/IL_CAT=${xx}           \#Resname of IL cation and all associated files/" ${xx}_${yy}.inp
  sed -i "20s/.*/IL_AN=${yy}            \#Resname of IL anion and all associated files/" ${xx}_${yy}.inp
  sed -i "24s/.*/DENS=${zz}             \#organic molecule, DES, or IL in g\/cm^3. Guess 1 if unknown/" ${xx}_${yy}.inp
if grep HETATM ../structures/${yy}.pdb; then
  ayy=(`grep HETATM ../structures/${yy}.pdb | awk '{print $3}' | sed "s/[[:digit:].-]//g" | 
  awk -vFS="" '{for(i=1;i<=NF;i++)w[tolower($i)]++}END \
    {for(i in w)print i,w[i] }'`)
else
  ayy=(`grep ATOM ../structures/${yy}.pdb | awk '{print $3}' | sed "s/[[:digit:].-]//g" | 
  awk -vFS="" '{for(i=1;i<=NF;i++)w[tolower($i)]++}END \
    {for(i in w)print i,w[i] }'`)
fi
if grep HETATM ../structures/${xx}.pdb; then
  axx=(`grep HETATM ../structures/${xx}.pdb | awk '{print $3}' | sed "s/[[:digit:].-]//g" | 
  awk -vFS="" '{for(i=1;i<=NF;i++)w[tolower($i)]++}END \
    {for(i in w)print i,w[i] }'`)
else
  axx=(`grep ATOM ../structures/${xx}.pdb | awk '{print $3}' | sed "s/[[:digit:].-]//g" | 
  awk -vFS="" '{for(i=1;i<=NF;i++)w[tolower($i)]++}END \
    {for(i in w)print i,w[i] }'`)
fi
b=0
n=0
h=0
f=0
s=0
o=0
l=0
c=0
for i in "${ayy[@]}"; do
  if [ "$i" == "n" ] ; then
    n=${ayy[$b+1]}
  elif [ "$i" == "h" ] ; then
    h=${ayy[$b+1]}
  elif [ "$i" == "f" ] ; then
    f=${ayy[$b+1]}
  elif [ "$i" == "s" ] ; then
    s=${ayy[$b+1]}
  elif [ "$i" == "o" ] ; then
    o=${ayy[$b+1]}
  elif [ "$i" == "l" ] ; then
    l=${ayy[$b+1]}
  elif [ "$i" == "c" ] ; then
    c=${ayy[$b+1]}
  fi
  b=$((b+1))
done
b=0
for i in "${axx[@]}"; do
  if [ "$i" == "n" ] ; then
    n=$((n+${axx[$b+1]}))
  elif [ "$i" == "h" ] ; then
    h=$((h+${axx[$b+1]}))
  elif [ "$i" == "f" ] ; then
    f=$((f+${axx[$b+1]}))
  elif [ "$i" == "s" ] ; then
    s=$((s+${axx[$b+1]}))
  elif [ "$i" == "o" ] ; then
    o=$((o+${axx[$b+1]}))
  elif [ "$i" == "l" ] ; then
    l=$((l+${axx[$b+1]}))
  elif [ "$i" == "c" ] ; then
    c=$((c+${axx[$b+1]}))
  fi
  b=$((b+1))
done
c=$((c-$l))
mw=`echo $c*12.011+$l*35.453+$f*18.998+$h*1.008+$n*14.007+$o*15.999+$s*32.06 | bc`
echo "${mw}"
    echo "carbons: $c"
    echo "chlorines: $l"
    echo "fluorines: $f"
    echo "hydrogens: $h"
    echo "nitrogens: $n"
    echo "oxygens: $o"
    echo "sulfurs: $s"
sed -i "22s/.*/MOLM=${mw}           #Molar mass of the organic molecule or IL pair in amu/" ${xx}_${yy}.inp
done < "$1"
