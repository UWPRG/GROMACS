#!/bin/bash

#ffmaker version 1.0
#Vance Jaeger
#5 August, 2013
#vjaeger@uw.edu

###Checks for the presence of the programs in the path.
echo ""
echo ""
echo Checking for the presence of the requisite programs in the path.

if [ $(echo $g09root | wc -l) -ne 1 ]; then
	echo ERROR: G09 is missing from the path. Exiting.
	return 0
else
	echo G09 found.
fi

if [ $(echo $AMBERHOME | wc -l) -ne 1 ]; then
	echo ERROR: Ambertools is missing from the path. Exiting.
        return 0
else 
        echo Antechamber found.
	echo Tleap found.
	echo Parmchk found.
fi

echo Assuming awk present.
echo Assuming sed present.

if [ $(echo $AMBERHOME | grep 12 | wc -l) -ne 1 ]; then
	echo Old version of ambertools detected. This still works, but the Gaussian calculation will be restricted to 1 core and 512MB of memory.
fi
echo Test Passed!!!
echo ""
echo ""

###Input parameter file
source ffmaker.inp

echo Starting ffmaker using the following inputs:
echo ""
cat ffmaker.inp
echo ""

###Creates a .com file with HF/6-31G* and other Gaussian options needed for RESP calculations
echo ""
echo ======== PREPARATION ========
echo ""
###Check for input files first
echo Checking for input file...

if [ -f $RESIDUE_NAME.$INPUT_TYPE ]; then
	echo File found. Continuing as planned...
else
	echo File not found! Check ffmaker.inp for proper variable names. Must have a file named $RESIDUE_NAME.$INPUT_TYPE in this folder. Exiting.
	return 0
fi 

#Initiate the calculation
echo Initiating antechamber converstion of .$INPUT_TYPE to .com with proper headers.
if [ $(echo $AMBERHOME | grep 12 | wc -l) -eq 1 ]; then
	if [ $INPUT_TYPE == "com" ]; then
		antechamber -fi gcrt -i $RESIDUE_NAME.com -fo gcrt -o $RESIDUE_NAME\2.com -rn $RESIDUE_NAME -nc $CHARGE -gm $G09_MEM -gn $G09_PROC -gv 1 -ge g09.gesp -s 2 -pf y
	else
		antechamber -fi $INPUT_TYPE -i $RESIDUE_NAME.$INPUT_TYPE -fo gcrt -o $RESIDUE_NAME\2.com -rn $RESIDUE_NAME -nc $CHARGE -gm $G09_MEM -gn $G09_PROC -gv 1 -ge g09.gesp -s 2 -pf y
	fi
else
	if [ $INPUT_TYPE == "com" ]; then
		antechamber -fi gcrt -i $RESIDUE_NAME.com -fo gcrt -o $RESIDUE_NAME\2.com -rn $RESIDUE_NAME -nc $CHARGE
        else                
		antechamber -fi $INPUT_TYPE -i $RESIDUE_NAME.$INPUT_TYPE -fo gcrt -o $RESIDUE_NAME\2.com -rn $RESIDUE_NAME -nc $CHARGE
	fi
fi

###Check for correct output and move file names around

if [ ! -f $RESIDUE_NAME\2.com ]; then
	echo ERROR: Antechamber preparation failed to output .com file. Manually check your files for strange formation. Exiting.
	return 0
fi	

if [ -f $RESIDUE_NAME.com ]; then
	mv $RESIDUE_NAME.com $RESIDUE_NAME.backup.com
fi

mv $RESIDUE_NAME\2.com $RESIDUE_NAME.com

###Insert NoSymm which is needed for the bugfix
sed -i.bak "s/=2)/=2) NoSymm/g" "$RESIDUE_NAME.com"

###Changes method and basis set if requested by user.

if [ $REPLACE_HF != "no" ]; then
	sed -i.bak "s/HF/$REPLACE_HF/g" "$RESIDUE_NAME.com"
fi

#if [ $REPLACE_631 != "no" ]; then
#	sed -i.bak "s/'6-31G*'/$REPLACE_631/g" "$RESIDUE_name.com"
#fi

rm *.bak
###Gausian Calculations
echo ""
echo ======== PREPARATION COMPLETE ========
echo ""
echo ======== GAUSSIAN ========

###Check for other Gaussian jobs that may have been spawned by previous failed runs of the script
echo ""
echo Checking for previously running Gaussian jobs...

if [ $(ps aux | grep g09 | wc -l) -gt 1 ]; then
	echo WARNING: Other Gaussian jobs may be running. They may interfere with this calculation and slow performance. Script will continue.
	sleep 5
else
	echo No Gaussian jobs found. Continuing as planned...
fi

echo ""
###Information for user 
echo Initiating Gaussian calculation...
echo This step may take several minutes depending on the size of your molecule.
echo TIP: If you ctrl+c this script, g09 will continue to run in the background.
echo To kill the background job try this command:
echo "kill -9 \`ps aux | grep g09 | grep $RESIDUE_NAME | awk {'print \$2'}\`"
echo ""
echo ""

###Move any old .log files
if [ -f $RESIDUE_NAME.log ]; then
	mv $RESIDUE_NAME.log $RESIDUE_NAME.backup.log
fi

###Initiate the calculation
g09 $RESIDUE_NAME.com &

###Counter for the user's entertainment
TIME_ELAPSED=0
echo Time elapsed: $TIME_ELAPSED seconds

###Informs user of unusual behavior
if [ $(ps aux | grep g09 | wc -l) -lt 2 ]; then
	echo WARNING: Gaussian job may have failed to start or was unusually short. Script will continue.
fi

###Counts elapsed time for the user and reports ever 30 seconds
while [ $(ps aux | grep g09 | wc -l) -gt 1 ]; do
	sleep 1
	TIME_ELAPSED=$[$TIME_ELAPSED + 1]
	if [ $[$TIME_ELAPSED % 30] -eq 0 ]; then
		echo Time elapsed: $TIME_ELAPSED seconds
	fi
done

###Checks for proper completion of the Gaussian calculation
if [[ $(tail -1 $RESIDUE_NAME.log) == *Normal* ]]; then
	echo Normal termination of Gaussian job detected.
else
	echo WARNING: Normal termination of Gaussian job NOT detected. Exiting.
	return 0
fi

###Checks version to see if bugfix is needed.
if [ $(grep "Revision B" $RESIDUE_NAME.log | wc -l) -gt 0 ]; then
	echo WARNING: G09 Revision B detected. Bugfix is needed. Bugfix is often flawed but it will still output "working" files will high charges. Revisions A and C are suggested.
	echo Initiating bugfix... 
	./fixreadinesp.sh $RESIDUE_NAME.log > readincenters.com
	g09 readincenters.com
	./fixreadinesp.sh readincenters.log > fixed.log
	mv fixed.log $RESIDUE_NAME.log
	echo Bugfix complete.
	rm readincenters.com
	rm readincenters.log
fi

rm molecule.chk
###Information
echo ""
echo ======== GAUSSIAN COMPLETE ========
echo ""
echo ======== ANTECHAMBER CALCULATIONS ========
echo ""
echo Initiating $METHOD calculation for $RESIDUE_NAME using antechamber.
echo TIP: Check the .mol2 output manually if there are warnings immediately below this line. 
echo ""
antechamber -fi gout -i $RESIDUE_NAME.log -fo mol2 -o $RESIDUE_NAME.mol2 -rn $RESIDUE_NAME -nc $CHARGE -c $METHOD -s 2 -pf y

###Error check for antechamber completion.
if [ -f $RESIDUE_NAME.mol2 ]; then
	echo $RESIDUE_NAME.mol2 found. This does not ensure that antechamber was successful in assigning charges.
else
	echo ERROR: $RESIDUE_NAME.mol2 not found. Antechamber was unable to complete this task. Exiting.
	return 0
fi

###Make a pdb for tleap later.
echo Using antechamber to build a .pdb. If a pdb was the input file, it will be saved as $RESIDUE_NAME.backup.pdb.

if [ $INPUT_TYPE == pdb ]; then
        mv $RESIDUE_NAME.pdb $RESIDUE_NAME.backup.pdb
fi

antechamber -fi mol2 -i $RESIDUE_NAME.mol2 -o $RESIDUE_NAME.pdb -fo pdb -rn $RESIDUE_NAME -nc $CHARGE
echo PDB built.
echo ""
echo ======== ANTECHAMBER CALCULATIONS COMPLETE ========
echo ""
echo ======== PARMCHK ========
echo ""
echo Initiating parmchk to build a .frcmod file.

parmchk -i $RESIDUE_NAME.mol2 -o $RESIDUE_NAME.frcmod -f mol2 -a Y

###Error check for parmchk completion.
if [ ! -f $RESIDUE_NAME.frcmod ]; then
	echo ERROR: Parmchk was unable to create a frcmod file. Exiting.
	return 0
fi
echo ""
echo ======== PARMCHK COMPLETE ========
echo ""
echo ======== TLEAP ========
echo ""
echo Initiating tleap to build a .lib file.
echo ""
echo Building tleap input file.

###Here file for tleap with and without standard force field.
if [ $REPLACE_FF != "no" ]; then
cat << HERE >| leap.inp
source leaprc.$REPLACE_FF
source leaprc.gaff
loadamberparams $RESIDUE_NAME.frcmod
$RESIDUE_NAME = loadmol2 $RESIDUE_NAME.mol2
saveoff $RESIDUE_NAME $RESIDUE_NAME.lib
saveamberparm $RESIDUE_NAME $RESIDUE_NAME.partop $RESIDUE_NAME.inpcrd
quit

HERE

else 
cat << THERE >| leap.inp
source leaprc.ff99SBildn
source leaprc.gaff
loadamberparams $RESIDUE_NAME.frcmod
$RESIDUE_NAME = loadmol2 $RESIDUE_NAME.mol2
saveoff $RESIDUE_NAME $RESIDUE_NAME.lib
saveamberparm $RESIDUE_NAME $RESIDUE_NAME.partop $RESIDUE_NAME.inpcrd
quit

THERE
fi

###Actually running tleap.
echo Tleap input built. $RESIDUE_NAME.lib being generated.
echo ""
tleap -f leap.inp
rm leap.inp
echo ""

###Error checking.
if [ -f $RESIDUE_NAME.lib ]; then
	echo Tleap created .lib file.
else
	echo ERROR: Tleap did not create a .lib file. Check the HERE and THERE statements as well as leap.log to determine the source of this error. Exiting.
	return 0
fi

rm leap.log

echo ""
echo ======== TLEAP COMPLETE ========
echo ""
echo ======== CHARGE SCALING ========
echo ""

###Check for charge scaling request
if [ $SCALED == "yes" ]; then
	echo Charge scaling was requested by the input file. Charges will be scaled by $FACTOR.
	echo ""

	###Backup
	cp $RESIDUE_NAME.lib $RESIDUE_NAME.backup.lib

	###Awk oneliner to replace column 8 which contians charge info.
	awk -v SCA=$FACTOR {'if($8+0==$8) print " "$1,$2,$3,$4,$5,$6,$7,$8*SCA; else print $0'} $RESIDUE_NAME.lib > temp.lib
	mv temp.lib $RESIDUE_NAME.lib

	echo ""
	echo $RESIDUE_NAME.lib was backed up to $RESIDUE_NAME.backup.lib. The latter will have full charges.
	echo ""

	if [ -f $RESIDUE_NAME.lib ]; then
		echo Scaled .lib file was created. All files are now made.
		echo ""
		echo ======== SCALING COMPLETE ========
		echo ""
		echo SUCCESS!!! Force field built for $RESIDUE_NAME. We suggest that you manually check these files. Antechamber in unable to handle some bond types. Exiting.
		return 0
	else
		echo ""
		echo ERROR: Scaling failed. This may be due to problems with the awk oneliner. Check the script manually. Exiting.
		return 0
	fi
else
	echo ""
	echo Charge scaling was not requested. This completes the script.
	echo ""
	echo ======== SCALING COMPLETE ========
        echo ""        
	echo SUCCESS!!! Force field built for $RESIDUE_NAME. We suggest that you manually check these files. Antechamber in unable to handle some bond types. Exiting.
	return 0
fi

