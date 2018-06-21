#!/bin/bash
#./windbess.sh
# Shell script to run MATLAB script windbess.m sequentially in batch mode.
# Simulation result files are concatentated into a single file for plotting.

MATLAB=/Applications/MATLAB_R2018a.app/bin/matlab
WINDBESS=/Users/starca/uofa/projects/windbess/dev/matlab/windbess.m
UIGFFILE=/Users/starca/uofa/projects/windbess/dev/data/in/uigf_meas.dat
SIMFILE=/Users/starca/uofa/projects/windbess/dev/data/out/windbess_sim_snowtwn1.dat

PUBASE=99.0
WINDCAP=$PUBASE
KMAX=20
SIMRUN1ST=1

for (( k = 0; k <= $KMAX; k++ ))
do
	BATTCAP=$k*$PUBASE/$KMAX
	#FILENUM=$(printf "%02d" $k)
	#RSLTFILE=/Users/starca/uofa/projects/windbess/dev/data/out/windbess_rslt_snowtwn1_${FILENUM}.dat
	RSLTFILE=/Users/starca/uofa/projects/windbess/dev/data/out/windbess_rslt_snowtwn1_curtbess20.dat
	$MATLAB -nodisplay -nodesktop -r "try pubase=$PUBASE; windcap=$WINDCAP; battcap=$BATTCAP; uigffile='$UIGFFILE'; simfile='$SIMFILE'; rsltfile='$RSLTFILE'; rslthdr=$SIMRUN1ST; run $WINDBESS; catch; end; quit"
	SIMRUN1ST=0;
done

# Concatenate simulation result files from terminal
#cat windbess_rslt_snowtwn1_??.dat > windbess_rslt_snowtwn1.dat
#rm windbess_rslt_snowtwn1_??.dat
