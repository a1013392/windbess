#!/bin/bash
#./windmeas.sh
# Shell script to preprocess wind farm data files containing SCADA
# measured wind power.

workdir=$PWD
datadir=/Users/starca/projects/windbess/dev/mysql/in
indir=$datadir
echo "Input data directory: $indir"
infile=meas_snowtwn1.csv
#outdir=$datadir
#echo "Output data directory: $outdir"
#outfile=meas_snowtwn1.csv
duid=SNOWTWN1
tab=$'\t'

cd $indir
#for file in *.csv
#do
	# Remove header (first) row from data file
	sed -i '' '1d' $infile
	# Insert column with DUID (use double quotes to expand variable $duid)
	sed -i '' "s/^/$duid$tab/g" $infile
	# Count rows in file
	echo "$(wc -l $infile)"
#done
