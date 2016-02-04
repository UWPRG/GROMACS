#!/bin/bash
# .
# There are four sections (lines 49-125) where you paste your chain into 
# the script. Obtain a literature value for your maximum packing density 
# defined as the inter-chain spacing and set this as variable m.
# .
#The surface is built on the xy plane and lattice type is R30 (equilateral
# triangles). Surface size is defined by the user in terms of repeating 4
# chain subunits. See adding residues in GROMACS page if you are building a 
# SAM from non-canonical residues or monomers

#units are in angstroms
#highest density packing is defined as R30 4.97 A (zheng et al. 2005)
echo;
echo "THIS SCRIPT BUILDS 7EG SAMs"
echo;
echo "CHOOSE YOUR PACKING DENSITY AS FRAC OF MAXIMUM"

read f

echo;
echo "HOW MANY UNIT CELLS LONG?"

read x1

echo;
echo "HOW MANY UNIT CELLS WIDE?"

read y1

echo;
m=4.711
x=`echo $x1 $m $f | awk '{printf "%2.3f\n", 2*$1*$2/$3}'`
y=`echo $y1 $m $f | awk '{printf "%2.3f\n", 2*$1*$2/$3}'`
n=`echo $x1 $y1 | awk '{printf "%4.0f\n", 4*$1*$2}'`

rm -f 7egsurf.pdb
echo "CRYST1   $x   $y  100.000  90.00  90.00  120.00 P 1           1" >> 7egsurf.pdb

### SURFACE

for (( i=1 ; i<=$n ; i++ )); do

   a=`echo $i | awk '{printf "%4.0f\n", $1}'`
   b=`echo $i | awk '{printf "%4.0f\n", $1+1}'`
   c=`echo $i | awk '{printf "%4.0f\n", $1+2}'`
   d=`echo $i | awk '{printf "%4.0f\n", $1+3}'`

   echo "ATOM      1  CC1 7EG A$a      -0.858  -1.069  -9.089" >> 7egsurf.pdb
   echo "ATOM      2  CC2 7EG A$a       0.355  -1.077  -8.157" >> 7egsurf.pdb
   echo "ATOM      3  OC1 7EG A$a       0.238  -0.010  -7.213" >> 7egsurf.pdb
   echo "ATOM      4  C1  7EG A$a       1.395  -0.070  -6.376" >> 7egsurf.pdb
   echo "ATOM      5  C2  7EG A$a       1.331   1.052  -5.338" >> 7egsurf.pdb
   echo "ATOM      6  O1  7EG A$a       0.221   0.831  -4.465" >> 7egsurf.pdb
   echo "ATOM      7  C3  7EG A$a       0.216   1.905  -3.523" >> 7egsurf.pdb
   echo "ATOM      8  C4  7EG A$a      -0.955   1.728  -2.554" >> 7egsurf.pdb
   echo "ATOM      9  O2  7EG A$a      -0.755   0.545  -1.777" >> 7egsurf.pdb
   echo "ATOM     10  C5  7EG A$a      -1.875   0.436  -0.896" >> 7egsurf.pdb
   echo "ATOM     11  C6  7EG A$a      -1.723  -0.817  -0.031" >> 7egsurf.pdb
   echo "ATOM     12  O3  7EG A$a      -0.585  -0.672   0.821" >> 7egsurf.pdb
   echo "ATOM     13  C7  7EG A$a      -0.497  -1.867   1.599" >> 7egsurf.pdb
   echo "ATOM     14  C8  7EG A$a       0.708  -1.777   2.538" >> 7egsurf.pdb
   echo "ATOM     15  O4  7EG A$a       0.498  -0.725   3.482" >> 7egsurf.pdb
   echo "ATOM     16  C9  7EG A$a       1.651  -0.692   4.326" >> 7egsurf.pdb
   echo "ATOM     17  C10 7EG A$a       1.490   0.419   5.366" >> 7egsurf.pdb
   echo "ATOM     18  O5  7EG A$a       0.397   0.106   6.232" >> 7egsurf.pdb
   echo "ATOM     19  CO1 7EG A$a       0.298   1.174   7.175" >> 7egsurf.pdb
   echo "ATOM     20  CO2 7EG A$a      -0.860   0.900   8.137" >> 7egsurf.pdb
   echo "ATOM     21  OO1 7EG A$a      -0.569  -0.264   8.913" >> 7egsurf.pdb
   echo "TER" >>7egsurf.pdb    
   echo "ATOM     22  CC1 7EG A$b      -0.858  -1.069  -9.089" >> 7egsurf.pdb
   echo "ATOM     23  CC2 7EG A$b       0.355  -1.077  -8.157" >> 7egsurf.pdb
   echo "ATOM     24  OC1 7EG A$b       0.238  -0.010  -7.213" >> 7egsurf.pdb
   echo "ATOM     25  C1  7EG A$b       1.395  -0.070  -6.376" >> 7egsurf.pdb
   echo "ATOM     26  C2  7EG A$b       1.331   1.052  -5.338" >> 7egsurf.pdb
   echo "ATOM     27  O1  7EG A$b       0.221   0.831  -4.465" >> 7egsurf.pdb
   echo "ATOM     28  C3  7EG A$b       0.216   1.905  -3.523" >> 7egsurf.pdb
   echo "ATOM     29  C4  7EG A$b      -0.955   1.728  -2.554" >> 7egsurf.pdb
   echo "ATOM     30  O2  7EG A$b      -0.755   0.545  -1.777" >> 7egsurf.pdb
   echo "ATOM     31  C5  7EG A$b      -1.875   0.436  -0.896" >> 7egsurf.pdb
   echo "ATOM     32  C6  7EG A$b      -1.723  -0.817  -0.031" >> 7egsurf.pdb
   echo "ATOM     33  O3  7EG A$b      -0.585  -0.672   0.821" >> 7egsurf.pdb
   echo "ATOM     34  C7  7EG A$b      -0.497  -1.867   1.599" >> 7egsurf.pdb
   echo "ATOM     35  C8  7EG A$b       0.708  -1.777   2.538" >> 7egsurf.pdb
   echo "ATOM     36  O4  7EG A$b       0.498  -0.725   3.482" >> 7egsurf.pdb
   echo "ATOM     37  C9  7EG A$b       1.651  -0.692   4.326" >> 7egsurf.pdb
   echo "ATOM     38  C10 7EG A$b       1.490   0.419   5.366" >> 7egsurf.pdb
   echo "ATOM     39  O5  7EG A$b       0.397   0.106   6.232" >> 7egsurf.pdb
   echo "ATOM     40  CO1 7EG A$b       0.298   1.174   7.175" >> 7egsurf.pdb
   echo "ATOM     41  CO2 7EG A$b      -0.860   0.900   8.137" >> 7egsurf.pdb
   echo "ATOM     42  OO1 7EG A$b      -0.569  -0.264   8.913" >> 7egsurf.pdb
   echo "TER" >>7egsurf.pdb    
   echo "ATOM     43  CC1 7EG A$c      -0.858  -1.069  -9.089" >> 7egsurf.pdb
   echo "ATOM     44  CC2 7EG A$c       0.355  -1.077  -8.157" >> 7egsurf.pdb
   echo "ATOM     45  OC1 7EG A$c       0.238  -0.010  -7.213" >> 7egsurf.pdb
   echo "ATOM     46  C1  7EG A$c       1.395  -0.070  -6.376" >> 7egsurf.pdb
   echo "ATOM     47  C2  7EG A$c       1.331   1.052  -5.338" >> 7egsurf.pdb
   echo "ATOM     48  O1  7EG A$c       0.221   0.831  -4.465" >> 7egsurf.pdb
   echo "ATOM     49  C3  7EG A$c       0.216   1.905  -3.523" >> 7egsurf.pdb
   echo "ATOM     50  C4  7EG A$c      -0.955   1.728  -2.554" >> 7egsurf.pdb
   echo "ATOM     51  O2  7EG A$c      -0.755   0.545  -1.777" >> 7egsurf.pdb
   echo "ATOM     52  C5  7EG A$c      -1.875   0.436  -0.896" >> 7egsurf.pdb
   echo "ATOM     53  C6  7EG A$c      -1.723  -0.817  -0.031" >> 7egsurf.pdb
   echo "ATOM     54  O3  7EG A$c      -0.585  -0.672   0.821" >> 7egsurf.pdb
   echo "ATOM     55  C7  7EG A$c      -0.497  -1.867   1.599" >> 7egsurf.pdb
   echo "ATOM     56  C8  7EG A$c       0.708  -1.777   2.538" >> 7egsurf.pdb
   echo "ATOM     57  O4  7EG A$c       0.498  -0.725   3.482" >> 7egsurf.pdb
   echo "ATOM     58  C9  7EG A$c       1.651  -0.692   4.326" >> 7egsurf.pdb
   echo "ATOM     59  C10 7EG A$c       1.490   0.419   5.366" >> 7egsurf.pdb
   echo "ATOM     60  O5  7EG A$c       0.397   0.106   6.232" >> 7egsurf.pdb
   echo "ATOM     61  CO1 7EG A$c       0.298   1.174   7.175" >> 7egsurf.pdb
   echo "ATOM     62  CO2 7EG A$c      -0.860   0.900   8.137" >> 7egsurf.pdb
   echo "ATOM     63  OO1 7EG A$c      -0.569  -0.264   8.913" >> 7egsurf.pdb
   echo "TER" >>7egsurf.pdb                            
   echo "ATOM     64  CC1 7EG A$d      -0.858  -1.069  -9.089" >> 7egsurf.pdb
   echo "ATOM     65  CC2 7EG A$d       0.355  -1.077  -8.157" >> 7egsurf.pdb
   echo "ATOM     66  OC1 7EG A$d       0.238  -0.010  -7.213" >> 7egsurf.pdb
   echo "ATOM     67  C1  7EG A$d       1.395  -0.070  -6.376" >> 7egsurf.pdb
   echo "ATOM     68  C2  7EG A$d       1.331   1.052  -5.338" >> 7egsurf.pdb
   echo "ATOM     69  O1  7EG A$d       0.221   0.831  -4.465" >> 7egsurf.pdb
   echo "ATOM     70  C3  7EG A$d       0.216   1.905  -3.523" >> 7egsurf.pdb
   echo "ATOM     71  C4  7EG A$d      -0.955   1.728  -2.554" >> 7egsurf.pdb
   echo "ATOM     72  O2  7EG A$d      -0.755   0.545  -1.777" >> 7egsurf.pdb
   echo "ATOM     73  C5  7EG A$d      -1.875   0.436  -0.896" >> 7egsurf.pdb
   echo "ATOM     74  C6  7EG A$d      -1.723  -0.817  -0.031" >> 7egsurf.pdb
   echo "ATOM     75  O3  7EG A$d      -0.585  -0.672   0.821" >> 7egsurf.pdb
   echo "ATOM     76  C7  7EG A$d      -0.497  -1.867   1.599" >> 7egsurf.pdb
   echo "ATOM     77  C8  7EG A$d       0.708  -1.777   2.538" >> 7egsurf.pdb
   echo "ATOM     78  O4  7EG A$d       0.498  -0.725   3.482" >> 7egsurf.pdb
   echo "ATOM     79  C9  7EG A$d       1.651  -0.692   4.326" >> 7egsurf.pdb
   echo "ATOM     80  C10 7EG A$d       1.490   0.419   5.366" >> 7egsurf.pdb
   echo "ATOM     81  O5  7EG A$d       0.397   0.106   6.232" >> 7egsurf.pdb
   echo "ATOM     82  CO1 7EG A$d       0.298   1.174   7.175" >> 7egsurf.pdb
   echo "ATOM     83  CO2 7EG A$d      -0.860   0.900   8.137" >> 7egsurf.pdb
   echo "ATOM     84  OO1 7EG A$d      -0.569  -0.264   8.913" >> 7egsurf.pdb
   echo "TER" >>7egsurf.pdb

   i=$[i+3]

done

echo "END" >> 7egsurf.pdb

### TCL SCRIPT

echo "mol new 7egsurf.pdb" >> 7EG.tcl

i=1

for (( j=1 ; j<=$x1 ; j++ )); do
   for (( k=1 ; k<=$y1 ; k++ )); do

      dyb=`echo $m $f | awk '{print sqrt(($1/$2)^2-(0.5*($1/$2))^2)}'`
      dxb=`echo $m $f | awk '{print -0.5*($1/$2)}'`
      dyc=`echo $m $f | awk '{print 0}'`
      dxc=`echo $m $f | awk '{print ($1/$2)}'`
      dyd=`echo $m $f | awk '{print sqrt(($1/$2)^2-(0.5*($1/$2))^2)}'`
      dxd=`echo $m $f | awk '{print 0.5*($1/$2)}'`
     
      a=$i
      b=$[i+1]  
      c=$[i+2]
      d=$[i+3]

      echo "set a [atomselect top "'"'"resid $b"'"'"]" >> 7EG.tcl
      echo ""'$a'" moveby {$dxb $dyb 0}" >> 7EG.tcl
      
      echo "set a [atomselect top "'"'"resid $c"'"'"]" >> 7EG.tcl
      echo ""'$a'" moveby {$dxc $dyc 0}" >> 7EG.tcl
    
      echo "set a [atomselect top "'"'"resid $d"'"'"]" >> 7EG.tcl
      echo ""'$a'" moveby {$dxd $dyd 0}" >> 7EG.tcl
    
      i=$[d+1]
   
   done

done

i=1

for (( j=1 ; j<=$x1 ; j++ )); do
   for (( k=1 ; k<=$y1 ; k++ )); do

      dx=`echo $j $k $m $f | awk '{print 2*(($1-1)*($3/$4) - ($2-1)*0.5*($3/$4))}'`
      dy=`echo $k $m $f | awk '{print 2*(($1-1)*sqrt(($2/$3)^2-(0.5*($2/$3))^2))}'`
      
      a=$i
      b=$[i+1]  
      c=$[i+2]
      d=$[i+3]

      echo "set a [atomselect top "'"'"resid $a $b $c $d"'"'"]" >> 7EG.tcl
      echo ""'$a'" moveby {$dx $dy 0}" >> 7EG.tcl
      
      i=$[d+1]
   
   done

done

echo "set a [atomselect top all]" >> 7EG.tcl
echo ""'$a'" writepdb 7egsurf.pdb" >> 7EG.tcl
echo "quit" >> 7EG.tcl

vmd -dispdev text -e 7EG.tcl
rm -f 7EG.tcl
