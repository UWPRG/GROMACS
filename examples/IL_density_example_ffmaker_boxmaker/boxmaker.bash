#!/bin/bash

#boxmaker version 1.0
#Creates boxes of solute + solvent using the Amber force field.
#Vance Jaeger
#6 August, 2013
#vjaeger@uw.edu
source BMI_TF2.inp
source directory.inp
###Checks for the presence of the programs in the path.
echo ""
echo ""
echo Checking for the presence of the requisite programs in the path.

if [ $(echo $AMBERHOME | wc -l) -ne 1 ]; then
        echo ERROR: Ambertools is missing from the path. Exiting.
        return 0
else
        echo Tleap found.
fi

if [ $(which packmol | wc | awk {'print $2'}) -ne 1 ]; then
	echo ERROR: Packmol is missing from the path. Exiting.
	return 0
else
	echo Packmol found.
fi

if [ ! -f acpype.py ]; then
	echo Acpype.py was not found in this directory. This is needed for GROMACS output only.
else
	echo Acpype.py found.
fi

echo Assuming awk.
echo Assuming sed.
echo Assuming python.

echo Test Passed!!!
echo ""
echo ""

###Input parameter file

echo Starting boxmaker using the following inputs:
echo ""
cat $SANDBOX/${name}.inp
echo ""

###Setting an exit test variable to exit loops when errors are found.
EXIT_TEST=0

###Antoher file check
if [[ "${SOLVENT_TYPE}" == "DES" ]]; then
	echo Ionic deep eutectic solvent box requested.
	echo Checking for the presence of requisite files.
	if [ ! -f $IL_CAT.lib ]; then
		echo $IL_CAT.lib missing.
		EXIT_TEST=$EXIT_TEST+1
	fi
        if [ ! -f $IL_AN.lib ]; then
                echo $IL_AN.lib missing.
                EXIT_TEST=$EXIT_TEST+1
	fi
	if [ ! -f $IL_CAT.frcmod ]; then
                echo $IL_CAT.frcmod missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $IL_AN.frcmod ]; then
                echo $IL_AN.frcmod missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $IL_CAT.pdb ]; then
                echo $IL_CAT.pdb missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $IL_AN.pdb ]; then
                echo $IL_AN.pdb missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $ORG_MOL.frcmod ]; then
                echo $ORG_MOL.frcmod missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $ORG_MOL.pdb ]; then
                echo $ORG_MOL.pdb missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $ORG_MOL.lib ]; then
                echo $ORG_MOL.lib missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ $EXIT_TEST -gt 0 ]; then
		echo "ERROR: $EXIT_TEST file(s) missing. Exiting."
		return 0
	fi
	echo Files found. Continuing.
fi

if [[ ""$SOLVENT_TYPE"" == "IL" ]]; then
	echo Ionic liquid box requested.
	echo Checking for the presence of requisite files.
	if [ ! -f $IL_CAT.lib ]; then
		echo $IL_CAT.lib missing.
		EXIT_TEST=$EXIT_TEST+1
	fi
        if [ ! -f $IL_AN.lib ]; then
                echo $IL_AN.lib missing.
                EXIT_TEST=$EXIT_TEST+1
	fi
	if [ ! -f $IL_CAT.frcmod ]; then
                echo $IL_CAT.frcmod missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $IL_AN.frcmod ]; then
                echo $IL_AN.frcmod missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $IL_CAT.pdb ]; then
                echo $IL_CAT.pdb missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ ! -f $IL_AN.pdb ]; then
                echo $IL_AN.pdb missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
	if [ $EXIT_TEST -gt 0 ]; then
		echo "ERROR: $EXIT_TEST file(s) missing. Exiting."
		return 0
	fi
	echo Files found. Continuing.
fi

if [[ ""$SOLVENT_TYPE"" == "organic" ]]; then
        echo Organic box requested.
        echo Checking for the presence of requisite files.
        if [ ! -f $ORG_MOL.lib ]; then
                echo $ORG_MOL.lib missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
        if [ ! -f $ORG_MOL.frcmod ]; then
                echo $ORG_MOL.frcmod missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
        if [ ! -f $ORG_MOL.pdb ]; then
                echo $ORG_MOL.pdb missing.
                EXIT_TEST=$EXIT_TEST+1
        fi
        if [ $EXIT_TEST -gt 0 ]; then
                echo "ERROR: $EXIT_TEST file(s) missing. Exiting."
                return 0
        fi
fi

echo ""

###Make a generic water molecule.
if [[ "$SOLVENT_TYPE" != "none" ]]; then

echo Making a generic water moleucle.
cat << HEREWAT >| wat.pdb
ATOM      1  O   WAT X   1      -0.239  -0.309  -0.000  1.00  0.00 
ATOM      2  H1  WAT X   1       0.718  -0.309  -0.000  1.00  0.00 
ATOM      3  H2  WAT X   1      -0.479   0.618  -0.000  1.00  0.00
HEREWAT

fi

###If there is no solute, it makes our job easier. Take this shortcut.
if [ "$SOLVENT_BOX" == "yes" ]; then

	echo "Solvent box without solute requested. Calculating the number of molecules needed to occupy a box of dimensions $BOX_X $BOX_Y $BOX_Z."

###Stop people from doing something dumb.	
	if [ "$SOLVENT_TYPE" == "none" ]; then
		echo SOLVENT_TYPE none cannot be used with SOLVENT_BOX yes. Exiting.
		return 0
	fi

###Make sure there is a recognized type.

if [[ "$SOLVENT_TYPE" != "DES" ]] && [[ "$SOLVENT_TYPE" != "IL" ]] && [[ "$SOLVENT_TYPE" != "organic" ]] && [[ "$SOLVENT_TYPE" != "water" ]]; then

echo ERROR: No recognized SOLVENT_TYPE. "$SOLVENT_TYPE" is not a valid option. Exiting.
return 0
fi

###Calculate the number of molecules you need of each.
BOX_VOLUME=`echo "scale=3; $BOX_X*$BOX_Y*$BOX_Z" | bc`

###Density of water in amu per cubic angstrom is about 0.6. Or 30 cubic angstroms per molecule. The following equation is good for solvents that are about as dense as water.
BOX_MASS=`echo "scale=3; $BOX_VOLUME*0.6" | bc`
NUM_WAT=`echo $BOX_VOLUME | awk '{print int($1/30+0.5)}'`
###Water solventbox
if [ "$SOLVENT_TYPE" == "water" ]; then
cat << HERESOLVWAT >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure wat.pdb
  resnumbers 2
  number $NUM_WAT
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLVWAT
fi

###DES solventbox
###Calculate the number of waters and the number of organics need
if [[ "$SOLVENT_TYPE" == "DES" ]]; then
BOX_MASS=`echo "scale=3; $BOX_VOLUME*$DENS" | bc`
NUM_HBND=`echo $BOX_VOLUME | awk '{print int($1/30+0.5)}'`
echo "DES solvent box selected. Beginning molecule counts"
if [ "$PERC_TYPE" == "mass" ]; then
	echo "Mass percentage calculations assume no partial molar volume (Ideal mixture)."
	NUM_IL=`echo "scale=3; $BOX_MASS * $PERCENT * 0.01 / $MOLM" | bc`
	NUM_HBND=`echo "scale=3; $NUM_HBND * (100-$PERCENT) * 0.01" | bc`
	TOTAL_MASS=`echo "scale=3; $NUM_IL * $MOLM + $NUM_HBND * $MOLM_HBND" | bc`
	NEW_DENS=`echo "scale=3; $TOTAL_MASS / ($NUM_IL * $MOLM/ $DENS + $NUM_HBND * $MOLM_HBND / 1)" | bc`
	NUM_IL=`echo "scale=3; $NUM_IL * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
	NUM_HBND=`echo "scale=3; $NUM_HBND * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_IL.
	echo Number of water molecules is $NUM_HBND.
fi

if [ "$PERC_TYPE" == "mole" ]; then
	NUM_IL=`echo "scale=3; $NUM_HBND * $PERCENT * 0.01" | bc`
	NUM_HBND=`echo "scale=3; $NUM_HBND * (100-$PERCENT) * 0.01" | bc`
	TOTAL_MASS=`echo "scale=3; $NUM_IL * $MOLM + $NUM_HBND * $MOLM_HBND" | bc`
	NEW_DENS=` echo "scale=3; $TOTAL_MASS / ( $NUM_IL * $MOLM / $DENS + $NUM_HBND * $MOLM_HBND / 1)" | bc`
	NEW_MASS=`echo "scale=3; $NEW_DENS * $BOX_VOLUME" | bc`
	NUM_IL=`echo "scale=3; $NUM_IL * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
	NUM_HBND=`echo "scale=3; $NUM_HBND * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_IL.
        echo Number of water molecules is $NUM_HBND.
fi

if [ "$PERC_TYPE" == "volume" ]; then
	VOL_IL=`echo "scale=3; $PERCENT * $BOX_VOLUME *0.01" | bc`
	VOL_HBND=`echo "scale=3; (100-$PERCENT) * 0.01 * $BOX_VOLUME" | bc`
	NUM_HBND=`echo "scale=3; $VOL_HBND  * $DENS * 0.6 / $MOLM_HBND" | bc | awk '{print int($1+0.5)}'`
	NUM_IL=`echo "scale=3; $VOL_IL * $DENS * 0.6 / $MOLM" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_IL.
        echo Number of water molecules is $NUM_HBND.
fi
fi
###Organic or IL solventbox
###Calculate the number of waters and the number of organics need
if [[ "$SOLVENT_TYPE" == "organic" ]] || [[ "$SOLVENT_TYPE" == "IL" ]]; then
if [ "$PERC_TYPE" == "mass" ]; then
	echo "Mass percentage calculations assume no partial molar volume (Ideal mixture)."
	NUM_ORG=`echo "scale=3; $BOX_MASS * $PERCENT * 0.01 / $MOLM" | bc`
	NUM_WAT=`echo "scale=3; $NUM_WAT * (100-$PERCENT) * 0.01" | bc`
	TOTAL_MASS=`echo "scale=3; $NUM_ORG * $MOLM + $NUM_WAT * 18" | bc`
	NEW_DENS=`echo "scale=3; $TOTAL_MASS / ($NUM_ORG * $MOLM/ $DENS + $NUM_WAT * 18 / 1)" | bc`
	NUM_ORG=`echo "scale=3; $NUM_ORG * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
	NUM_WAT=`echo "scale=3; $NUM_WAT * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_ORG.
	echo Number of water molecules is $NUM_WAT.
fi

if [ "$PERC_TYPE" == "mole" ]; then
	NUM_ORG=`echo "scale=3; $NUM_WAT * $PERCENT * 0.01" | bc`
	NUM_WAT=`echo "scale=3; $NUM_WAT * (100-$PERCENT) * 0.01" | bc`
	TOTAL_MASS=`echo "scale=3; $NUM_ORG * $MOLM + $NUM_WAT * 18" | bc`
	NEW_DENS=` echo "scale=3; $TOTAL_MASS / ( $NUM_ORG * $MOLM / $DENS + $NUM_WAT * 18 / 1)" | bc`
	NEW_MASS=`echo "scale=3; $NEW_DENS * $BOX_VOLUME" | bc`
	NUM_ORG=`echo "scale=3; $NUM_ORG * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
	NUM_WAT=`echo "scale=3; $NUM_WAT * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_ORG.
        echo Number of water molecules is $NUM_WAT.
fi

if [ "$PERC_TYPE" == "volume" ]; then
	VOL_ORG=`echo "scale=3; $PERCENT * $BOX_VOLUME *0.01" | bc`
	VOL_WAT=`echo "scale=3; (100-$PERCENT) * 0.01 * $BOX_VOLUME" | bc`
	NUM_WAT=`echo "scale=3; $VOL_WAT / 30" | bc | awk '{print int($1+0.5)}'`
	NUM_ORG=`echo "scale=3; $VOL_ORG * $DENS * 0.6 / $MOLW" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_ORG.
        echo Number of water molecules is $NUM_WAT.
fi
fi

echo Calculation of box content complete.
###Build packmol inputs for ILs
echo Generating packmol input files.
if [ "$SOLVENT_TYPE" == "DES" ]; then

###DES
cat << HERESOLVDES >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $IL_CAT.pdb
  resnumbers 2
  number $NUM_IL
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $IL_AN.pdb
  resnumbers 2
  number $NUM_IL
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $ORG_MOL.pdb
  resnumbers 2
  number $NUM_HBND
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLVDES
fi

if [ "$SOLVENT_TYPE" == "IL" ]; then

###IL+water
if [ $NUM_WAT -gt 0 ]; then
cat << HERESOLVIL >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $IL_CAT.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $IL_AN.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure wat.pdb
  resnumbers 2
  number $NUM_WAT
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLVIL

else

###PURE IL

cat << HERESOLVPUREIL >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter
seed 192555
nloop 1000

structure $IL_CAT.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $IL_AN.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLVPUREIL

fi
fi

###Build packmol inputs for organic
if [ "$SOLVENT_TYPE" == "organic" ]; then

###organic+water
if [ $NUM_WAT -gt 0 ]; then
cat << HERESOLVORG >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $ORG_MOL.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure wat.pdb
  resnumbers 2
  number $NUM_WAT
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLVORG

else

###PURE ORG

cat << HERESOLVPUREORG >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $ORG_MOL.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLVPUREORG

fi
fi

###Now we have our packmol file for anything we want.

echo Packmol input file generated. 

###Put it into packmol and let's see what we get out.

echo Packmol calculation will begin now.
packmol < packmol.inp
echo Packmol calculation complete.

###With the output (packed.pdb), we can get into tleap. First we need to make tleap input files for each case though.

echo Building tleap input file.
if [ "$SOLVENT_TYPE" == "water" ]; then
cat << HERETLEAP >| leap.in
source leaprc.$AMBER_FF
BMR = loadpdb packed.pdb
saveamberparm BMR system.prmtop system.inpcrd
savepdb BMR system.pdb
quit
HERETLEAP
fi

if [ "$SOLVENT_TYPE" == "DES" ]; then
cat << HERETLEAPDES >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadamberparams $ORG_MOL.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
loadoff $ORG_MOL.lib
BMR = loadpdb packed.pdb
saveamberparm BMR system.prmtop system.inpcrd
savepdb BMR system.pdb
quit
HERETLEAPDES
fi

if [ "$SOLVENT_TYPE" == "IL" ]; then
cat << HERETLEAPIL >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
BMR = loadpdb packed.pdb
saveamberparm BMR system.prmtop system.inpcrd
savepdb BMR system.pdb
quit
HERETLEAPIL
fi

if [ "$SOLVENT_TYPE" == "organic" ]; then
cat << HERETLEAPORG >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $ORG_MOL.frcmod
loadoff $ORG_MOL.lib
saveamberparm BMR system.prmtop system.inpcrd
savepdb BMR system.pdb
quit
HERETLEAPORG
fi

echo Tleap input file generated.

###Do the tleap build
echo Beginning tleap calculations.
tleap -f leap.in
echo Tleap calculatiopns complete

###Build a .gro and .top file

if [ $GROMACS == "yes" ]; then
	echo Using acpype to generate a .gro and .top file for GROMACS input.
	./acpype.py -p system.prmtop -x system.inpcrd -r
	mv system_GMX.gro conf.gro
	mv system_GMX.top topol.top
	echo GROMACS files built.
fi

echo SUCCESS: Exiting.
return 0

fi 




###End of portion for solvent-only boxes.

###Check for solute files.
echo Simple solvent box not requested. Solute will be assumed.
echo Checking for the presence of the requisite solute files.

if [ ! -f $SOLUTE.pdb ]; then
        echo $SOLUTE.pdb missing.
        EXIT_TEST=$EXIT_TEST+1
fi
if [ ! -f $SOLUTE.frcmod ]; then
        echo $SOLUTE.frcmod not found. This is normal for a protein. It may be a problem for other solutes.
fi
if [ ! -f $SOLUTE.lib ]; then
        echo $SOLUTE.lib not found. This is normal for a protein. It may be a problem for other solutes.
fi
if [ $EXIT_TEST -gt 0 ]; then
        echo "ERROR: File missing. Exiting."
        return 0
fi

###Now we can continue with the normal solvent-solute systems.

###Tleap often has problems with OXT. We can remove it, and it will be put back in by leap.
grep -v OXT $SOLUTE.pdb > $SOLUTE.2.pdb

###Backup your old pdb.
mv $SOLUTE.pdb $SOLUTE.backup.pdb
mv $SOLUTE.2.pdb $SOLUTE.pdb

###Make the file for the case with no solvent.

if [ "$SOLVENT_TYPE" == "none" ]; then
cat << GENERICNONE >| leap.in
source leaprc.$AMBER_FF
BMR = loadpdb $SOLUTE.pdb
savepdb BMR solvated.pdb
saveamberparm BMR solvated.prmtop solvated.inpcrd
quit
GENERICNONE
fi

###First, let's calculate the size of the box we need. To do this, we make a generic box of water using tleap. Then, we use this information to calculate the other percentages. Also make shortcuts for the water case.

if [ "$SOLVENT_TYPE" != "none" ]; then #any solvated system

if [ "$SOLVENT_TYPE" == "water" ]; then #water in specific

cat << GENERICWAT >| leap.in
source leaprc.$AMBER_FF
BMR = loadpdb $SOLUTE.pdb
solvatebox BMR $WAT_TYPE $BUFFER $CUBIC
savepdb BMR solvated.pdb
saveamberparm BMR solvated.prmtop solvated.inpcrd
quit
GENERICWAT

###This is almost done for the water system, we need only deal with disulfide bonds. But let's not worry about that right now.

else #Water specific case: not warer ---> organic and IL case

###Generic water box. This will be used to find the size of the box amd other things.
cat << GENERIC >| leap.in
source leaprc.$AMBER_FF
BMR = loadpdb $SOLUTE.pdb
solvatebox BMR $WAT_TYPE $BUFFER $CUBIC
savepdb BMR solvated.pdb
quit
GENERIC

###Remove old files
if [ -f leap.log ]; then
rm leap.log
fi

###Run the leap.in file.
tleap -f leap.in

###Search the leap.log file for the size of the box created.
BOX_X=`grep "bounding box for atom" leap.log | awk {'print $7'}`
BOX_Y=`grep "bounding box for atom" leap.log | awk {'print $8'}`
BOX_Z=`grep "bounding box for atom" leap.log | awk {'print $9'}`

echo $BOX_X

###Find the number of waters in the leap system we will use this to compare to a box of pure water. It might be needed to determine percentages later.

if [ $PERCENT -lt 101 ]; then #Case where it is a mixture

LEAP_WAT=`grep WAT solvated.pdb | wc -l | awk {'print ($1/3)'}`
NUM_FULL=`echo "$BOX_X*$BOX_Y*$BOX_Z/30" | bc`
PERC_SOLUTE=`echo "scale=3; 1-$LEAP_WAT/$NUM_FULL" | bc`
BOX_MASS=`echo "scale=3; $LEAP_WAT*18" | bc`
NUM_WAT=$LEAP_WAT
BOX_VOLUME=`echo "scale=3; $BOX_X * $BOX_Y * $BOX_Z" | bc`

if [[ "$SOLVENT_TYPE" == "DES" ]]; then

if [ "$PERC_TYPE" == "mass" ]; then
	echo "Mass percentage calculations assume no partial molar volume (Ideal mixture)."
	NUM_IL=`echo "scale=3; $BOX_MASS * $PERCENT * 0.01 / $MOLM" | bc`
	NUM_HBND=`echo "scale=3; $NUM_HBND * (100-$PERCENT) * 0.01" | bc`
	TOTAL_MASS=`echo "scale=3; $NUM_IL * $MOLM + $NUM_HBND * $MOLM_HBND" | bc`
	NEW_DENS=`echo "scale=3; $TOTAL_MASS / ($NUM_IL * $MOLM/ $DENS + $NUM_HBND * $MOLM_HBND / 1)" | bc`
	NUM_IL=`echo "scale=3; $NUM_IL * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
	NUM_HBND=`echo "scale=3; $NUM_HBND * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_IL.
	echo Number of water molecules is $NUM_HBND.
fi

if [ "$PERC_TYPE" == "mole" ]; then
	NUM_IL=`echo "scale=3; $NUM_HBND * $PERCENT * 0.01" | bc`
	NUM_HBND=`echo "scale=3; $NUM_HBND * (100-$PERCENT) * 0.01" | bc`
	TOTAL_MASS=`echo "scale=3; $NUM_IL * $MOLM + $NUM_HBND * $MOLM_HBND" | bc`
	NEW_DENS=` echo "scale=3; $TOTAL_MASS / ( $NUM_IL * $MOLM / $DENS + $NUM_HBND * $MOLM_HBND / 1)" | bc`
	NEW_MASS=`echo "scale=3; $NEW_DENS * $BOX_VOLUME" | bc`
	NUM_IL=`echo "scale=3; $NUM_IL * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
	NUM_HBND=`echo "scale=3; $NUM_HBND * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_IL.
        echo Number of water molecules is $NUM_HBND.
fi

if [ "$PERC_TYPE" == "volume" ]; then
	VOL_IL=`echo "scale=3; $PERCENT * $BOX_VOLUME *0.01" | bc`
	VOL_HBND=`echo "scale=3; (100-$PERCENT) * 0.01 * $BOX_VOLUME" | bc`
	NUM_HBND=`echo "scale=3; $VOL_HBND  * $DENS * 0.6 / $MOLM_HBND" | bc | awk '{print int($1+0.5)}'`
	NUM_IL=`echo "scale=3; $VOL_IL * $DENS * 0.6 / $MOLM" | bc | awk '{print int($1+0.5)}'`
	echo Number of organic molecules or IL pairs is $NUM_IL.
        echo Number of water molecules is $NUM_HBND.
fi
fi

if [[ "$SOLVENT_TYPE" != "DES" ]]; then



if [ "$PERC_TYPE" == "mass" ]; then
        echo "Mass percentage calculations assume no partial molar volume (Ideal mixture)."
        NUM_ORG=`echo "scale=3; $BOX_MASS * $PERCENT * 0.01 / $MOLM" | bc`
        NUM_WAT=`echo "scale=3; $NUM_WAT * (100-$PERCENT) * 0.01" | bc`
        TOTAL_MASS=`echo "scale=3; $NUM_ORG * $MOLM + $NUM_WAT * 18" | bc`
        NEW_DENS=`echo "scale=3; $TOTAL_MASS / ($NUM_ORG * $MOLM/ $DENS + $NUM_WAT * 18 / 1)" | bc`
        NUM_ORG=`echo "scale=3; $NUM_ORG * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
        NUM_WAT=`echo "scale=3; $NUM_WAT * $NEW_DENS" | bc | awk '{print int($1+0.5)}'`
        echo Number of organic molecules or IL pairs is $NUM_ORG.
        echo Number of water molecules is $NUM_WAT.
fi

if [ "$PERC_TYPE" == "mole" ]; then
        NUM_ORG=`echo "scale=3; $NUM_WAT * $PERCENT * 0.01" | bc`
        NUM_WAT=`echo "scale=3; $NUM_WAT * (100-$PERCENT) * 0.01" | bc`
        TOTAL_MASS=`echo "scale=3; $NUM_ORG * $MOLM + $NUM_WAT * 18" | bc`
        NEW_DENS=` echo "scale=3; $TOTAL_MASS / ( $NUM_ORG * $MOLM / $DENS + $NUM_WAT * 18 / 1)" | bc`
        NEW_MASS=`echo "scale=3; $NEW_DENS * $BOX_VOLUME" | bc`
        NUM_ORG=`echo "scale=3; $NUM_ORG * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
        NUM_WAT=`echo "scale=3; $NUM_WAT * $NEW_MASS / $TOTAL_MASS" | bc | awk '{print int($1+0.5)}'`
        echo Number of organic molecules or IL pairs is $NUM_ORG.
        echo Number of water molecules is $NUM_WAT.
fi

if [ "$PERC_TYPE" == "volume" ]; then
        VOL_ORG=`echo "scale=3; $PERCENT * $BOX_VOLUME * 0.01 * (1-$PERC_SOLUTE)" | bc`
        VOL_WAT=`echo "scale=3; (100-$PERCENT) * 0.01 * $BOX_VOLUME * (1-$PERC_SOLUTE)" | bc`
        NUM_WAT=`echo "scale=3; $VOL_WAT / 30" | bc | awk '{print int($1+0.5)}'`
        NUM_ORG=`echo "scale=3; $VOL_ORG * $DENS * 0.6 / $MOLM" | bc | awk '{print int($1+0.5)}'`
        echo Number of organic molecules or IL pairs is $NUM_ORG.
	echo Percent solute is $PERC_SOLUTE
        echo Number of water molecules is $NUM_WAT.
	echo Volume of Water is $VOL_WAT
	echo Volume of organic is $VOL_ORG
	echo Volume of box is $BOX_VOLUME
fi
fi
###Make packmol files

###DES
if [ "$SOLVENT_TYPE" == "DES" ]; then
cat << HEREBOXDES >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $SOLUTE.pdb
  resnumbers 2
  number 1
  fixed `echo "scale=3; $BOX_X/2" | bc` `echo "scale=3; $BOX_Y/2" | bc` `echo "scale=3; $BOX_Z/2" | bc` 0. 0. 0.
  centerofmass
end structure

structure $IL_CAT.pdb
  resnumbers 2
  number $NUM_IL
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $IL_AN.pdb
  resnumbers 2
  number $NUM_IL
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $ORG_MOL.pdb
  resnumbers 2
  number $NUM_HBDN
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HEREBOXDES

fi

###IL+water
if [ "$SOLVENT_TYPE" == "IL" ]; then
cat << HEREBOXIL >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $SOLUTE.pdb
  resnumbers 2
  number 1
  fixed `echo "scale=3; $BOX_X/2" | bc` `echo "scale=3; $BOX_Y/2" | bc` `echo "scale=3; $BOX_Z/2" | bc` 0. 0. 0.
  centerofmass
end structure

structure $IL_CAT.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $IL_AN.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure wat.pdb
  resnumbers 2
  number $NUM_WAT
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HEREBOXIL

fi

###Organic+water
if [ "$SOLVENT_TYPE" == "organic" ]; then
cat << HEREBOXORG >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $SOLUTE.pdb
  resnumbers 2
  number 1
  fixed `echo "scale=3; $BOX_X/2" | bc` `echo "scale=3; $BOX_Y/2" | bc` `echo "scale=3; $BOX_Z/2" | bc` 0
. 0. 0.
  centerofmass
end structure

structure $ORG_MOL.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure wat.pdb
  resnumbers 2
  number $NUM_WAT
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HEREBOXORG

fi

else #Mixture case: not a mixture ---> Pure IL or pure organic.

###Find the number of waters in test case.
LEAP_WAT=`grep WAT solvated.pdb | wc -l | awk {'print ($1/3)'}`

###Use this number of waters to decide the number of organic molecules to use.
NUM_ORG=`echo "scale=3; $LEAP_WAT*$DENS*18/$MOLM" | bc`

###Make the packmol input.

###Pure Organic
if [ "$SOLVENT_TYPE" == "organic" ]; then
cat << HERESOLUORG >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $SOLUTE.pdb
  resnumbers 2
  number 1
  fixed `echo "scale=3; $BOX_X/2" | bc` `echo "scale=3; $BOX_Y/2" | bc` `echo "scale=3; $BOX_Z/2" | bc` 0. 0. 0.  
  centerofmass
end structure

structure $ORG_MOL.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLUORG

fi

if [ "$SOLVENT_TYPE" == "IL" ]; then
cat << HERESOLUIL >| packmol.inp
tolerance 2.0
output packed.pdb
filetype pdb
add_amber_ter

structure $SOLUTE.pdb
  resnumbers 2
  number 1
  fixed `echo "scale=3; $BOX_X/2" | bc` `echo "scale=3; $BOX_Y/2" | bc` `echo "scale=3; $BOX_Z/2" | bc` 0. 0. 0.
  centerofmass
end structure

structure $IL_CAT.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure

structure $IL_AN.pdb
  resnumbers 2
  number $NUM_ORG
  inside box 0. 0. 0. $BOX_X $BOX_Y $BOX_Z
end structure
HERESOLUIL

fi

fi #End mixture specific if statement.

###Use Packmol to make your box
packmol < packmol.inp

###Use tleap to build your prmtop and stuff.
if [ "$SOLVENT_TYPE" == "DES" ]; then
cat << HERETLEAPDES >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadamberparams $ORG_MOL.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
loadoff $ORG_MOL.lib
BMR = loadpdb packed.pdb
loadoff $SOLUTE.lib
loadamberparams $SOLUTE.frcmod
saveamberparm BMR solvated.prmtop solvated.inpcrd
savepdb BMR solvated.pdb
quit
HERETLEAPDES
fi

if [ "$SOLVENT_TYPE" == "IL" ]; then
cat << LEAPINPIL >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
BMR = loadpdb packed.pdb
loadoff $SOLUTE.lib
loadamberparams $SOLUTE.frcmod
saveamberparm BMR solvated.prmtop solvated.inpcrd
savepdb BMR solvated.pdb
quit
LEAPINPIL
fi

if [ "$SOLVENT_TYPE" == "organic" ]; then
cat << LEAPINPORG >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
BMR = loadpdb packed.pdb
saveamberparm BMR solvated.prmtop solvated.inpcrd
savepdb BMR solvated.pdb
quit
LEAPINPORG
fi

tleap -f leap.in

fi #End of water specific if statement.

else #Solvated case: Not solvated with anything.

###We can skip right to the tleap portion.

cat << LEAPINNONE >| leap.in
source leaprc.$AMBER_FF
BMR = loadpdb $SOLUTE.pdb
saveamberparm BMR solvated.prmtop solvated.inpcrd
savepdb BMR solvated.pdb
quit
LEAPINNONE

tleap -f leap.in

fi #End of solvated system if statement.

###We now have a system where we have the solvent and the solute in a box. We need to take care of neutralization and SS-bonds.

#if [ $DISULFIDE == "yes" ]; then
NUM_SS=0

for x in {1..100}; do
if [[ `echo $[SSBOND_A_$x]` -gt 0 ]]; then
NUM_SS=$[$NUM_SS+1]
echo $NUM_SS
fi
done

if [ "$SOLVENT_TYPE" == "water" ]; then

cat << SSNEUTWAT >| leap.in
source leaprc.$AMBER_FF
BMR = loadpdb solvated.pdb
SSNEUTWAT

for y in $(eval echo "{1..$NUM_SS}"); do
VAR1=`echo "$[SSBOND_A_$y]"`
VAR2=`echo "$[SSBOND_B_$y]"`
echo "bond BMR.$VAR1.SG BMR.$VAR2.SG" >> leap.in
done

fi

if [ "$SOLVENT_TYPE" == "DES" ]; then
cat << HERETLEAPDES >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadamberparams $ORG_MOL.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
loadoff $ORG_MOL.lib
BMR = loadpdb packed.pdb
HERETLEAPDES

for y in $(eval echo "{1..$NUM_SS}"); do
VAR1=`echo "$[SSBOND_A_$y]" | bc`
VAR2=`echo "$[SSBOND_B_$y]" | bc`
echo "bond BMR.$VAR1.SG BMR.$VAR2.SG" >> leap.in
done

fi


if [ "$SOLVENT_TYPE" == "IL" ]; then

cat << SSNEUTIL >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $IL_AN.frcmod
loadamberparams $IL_CAT.frcmod
loadoff $IL_AN.lib
loadoff $IL_CAT.lib
BMR = loadpdb solvated.pdb
SSNEUTIL

for y in $(eval echo "{1..$NUM_SS}"); do
VAR1=`echo "$[SSBOND_A_$y]" | bc`
VAR2=`echo "$[SSBOND_B_$y]" | bc`
echo "bond BMR.$VAR1.SG BMR.$VAR2.SG" >> leap.in
done

fi

if [ "$SOLVENT_TYPE" == "organic" ]; then

cat << SSNEUTORG >| leap.in
source leaprc.$AMBER_FF
source leaprc.gaff
loadamberparams $ORG_MOL.frcmod
loadoff $ORG_MOL.lib
BMR = loadpdb solvated.pdb
SSNEUTORG

for y in $(eval echo "{1..$NUM_SS}"); do
VAR1=`echo "$[SSBOND_A_$y]" | bc`
VAR2=`echo "$[SSBOND_B_$y]" | bc`
echo "bond BMR.$VAR1.SG BMR.$VAR2.SG" >> leap.in
done

fi

if [ $NEUTRALIZE == "yes" ]; then

echo "addions BMR Na+ 0" >> leap.in
echo "addions BMR Cl- 0" >> leap.in

fi

echo "saveamberparm BMR system.prmtop system.inpcrd" >> leap.in
echo "savepdb BMR system.pdb" >> leap.in
echo "quit" >> leap.in

#fi

if [[ $NEUTRALIZE == "yes" ]] || [[ $SSBOND == "yes" ]]; then

tleap -f leap.in

else

cp solvated.pdb system.pdb
cp solvated.inpcrd system.inpcrd
cp solvated.prmtop system.prmtop

fi

if [ $GROMACS == "yes" ]; then
        echo Using acpype to generate a .gro and .top file for GROMACS input.
        ./acpype.py -p system.prmtop -x system.inpcrd -r
        mv system_GMX.gro conf.gro
        mv system_GMX.top topol.top
        echo GROMACS files built.
fi

return 0
