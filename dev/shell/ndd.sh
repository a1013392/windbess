!/bin/bash
#./ndd.sh
# Shell script to filter daily Next Day Dispatch files on dispatch unit
# identifier (DUID).  It concatenates records (rows) filtered on DUID into
# files and drops unwanted fields (columns).  Output files retains six columns:
# SETTLEMENTDATE, DUID, DISPATCHINTERVAL, INTERVENTION, INITIALMW, TOTALCLEARED,  
# AVAILABILITY, SEMIDISPATCHCAP

DUID=SNOWTWN1
duid=snowtwn1
echo "Dispatch Unit IDentifier: $duid"
projdir=/Users/starca/projects/windbess
# Directory containing AMEO Next Day Dispatch files
ndddir=$projdir/dev/mysql/ndd
echo "Next Day Dispatch directory: $ndddir"
# Output of shell pre-processing of Next Day Dispatch files is input to MySQL database
outdir=$projdir/dev/mysql/in
echo "Shell output/ MySQL input directory: $outdir"
keep=\!d

cd $ndddir
# Unzip NDD files and delete unwanted rows
for file in *.zip; do unzip "$file"; done
rm *.zip
for file in *.CSV; do sed -i '' '/UNIT_SOLUTION/ !d' $file; done

# Delete rows for DUID other than designated duid. Variables $DUID and $keep in
# double quotes are expanded.  Defining variable $keep obviates history expansion (!)
for file in *.CSV; do sed -i '' "/$DUID/$keep" $file; done
# Delete unwanted columns and concatenate into single file
for file in *.CSV; do echo "$(wc -l $file)"; cut -d ',' -f5,7,9,10,14,15,37,60 $file >> $outdir/ndd_${duid}.csv; done