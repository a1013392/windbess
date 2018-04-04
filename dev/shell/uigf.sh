#!/bin/bash
#./uigf.sh
# Shell script to preprocess wind farm data files containing unconstrained 
# intermittent generation forecasts (UIGF).

workdir=$PWD
datadir=/Users/starca/projects/windbess/dev/mysql/in
indir=$datadir
echo "Input data directory: $indir"
infile=uigf_snowtwn1.csv
#outdir=$datadir
#echo "Output data directory: $outdir"
#outfile=uigf_snowtwn1.csv
duid=SNOWTWN1
tab=$'\t'

cd $indir
#for file in *.csv
#do
	# Remove header (first) row from data file
	sed -i '' '1d' $infile
	# Delete columns to the right of column 4
	cut -f1,2,3,4  $infile | sponge $infile
	# Insert column with DUID (use double quotes to expand variable $duid)
	sed -i '' "s/^/$duid$tab/g" $infile
	# Count rows in file
	echo "$(wc -l $infile)"
#done
