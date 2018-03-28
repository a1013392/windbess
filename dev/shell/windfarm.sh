#!/bin/bash
#./windfarm.sh
# Shell script to preprocess wind farm data files containing unconstrained 
# intermittent generation forecasts (UIGF) and measured wind power.

workdir=$PWD
datadir=/Users/starca/projects/windbess/dev/mysql/in
indir=$datadir
echo "Input data directory: $indir"
infile=uigf_snowtwn1_1711.csv
infile=meas_snowtwn1_1711.csv
outdir=$datadir
echo "Output data directory: $outdir"
outfile=uigf_snowtwn1.csv
outfile=meas_snowtwn1.csv
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

# Concatentate files into single output file
files=$(ls *.csv)
cat $files > $outdir/$outfile
echo "$(wc -l $files)"
echo "$(wc -l $outdir/$outfile)"