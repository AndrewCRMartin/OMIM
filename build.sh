#!/bin/bash
sprot=/acrm/data/swissprot/full/uniprot_sprot.dat
fasta=/acrm/data/swissprot/full/uniprot_sprot.fasta
idx=/tmp/sprot.idx
dbname=omim
dbhost=acrm8
validate=/home/bsm/martin/SAAP/omim/validate.pl
htmldir=/acrm/www/html/omim
cgidir=/acrm/www/cgi-bin/omim
omimdatadir=/acrm/data/omim
tmpdir=/acrm/data/tmp
omimfile=omim.txt.Z
omimurl=ftp://ftp.ncbi.nih.gov/repository/OMIM/$omimfile

# If called with "-get" then grab the file
param=$1
if [ -n "$param" ]; then
   if [ $param = "-get" ]; then
      # Grab the OMIM data
      omimdata=$tmpdir/$omimfile
      \rm -f $omimdata
      (cd $tmpdir; wget $omimurl)
   else
      echo "Usage: ./build.sh [-get]"
      echo "  -get - grab OMIM with wget and uses that"
      echo ""
      echo "Populates the OMIM database from the OMIM resource. Normally"
      echo "uses our mirror of those data, but can be forced to grab the"
      echo "datafile as part of this run by using -get"
      exit 0;
   fi
else
    omimdata=$omimdatadir/$omimfile
fi

# Block web access
echo "Blocking web access..."
./unavailable.sh $cgidir $htmldir
# Create the database
echo "Creating database tables..."
psql -h $dbhost $dbname < create.sql
# Grab the mutations from OMIM
echo "Parsing OMIM data..."
zcat $omimdata | ./parseomim.pl | psql -h $dbhost $dbname
# Cross-reference with SwissProt
echo "Parsing SwissProt data..."
./ProcessSProt.pl $sprot | psql -h $dbhost $dbname
# Index SwissProt FASTA file
echo "Indexing FASTA version of SwissProt..."
./indexfasta.pl $fasta $idx
# Now validate the residue number for the OMIM entries
echo "Validating OMIM entries..."
./wrapvalidate.pl -validate=$validate -dbname=$dbname -dbhost=$dbhost $fasta $idx | ./update_resnums.pl | psql -h $dbhost $dbname
# Now dump the mapping in plain text and XML
echo "Dumping mapping as a CSV file..."
./dump_mapping.pl -dbname=$dbname -dbhost=$dbhost > $htmldir/omim_sprot.csv.`date +%F`
echo "Dumping mapping as an XML file..."
./dump_mapping.pl -xml -dbname=$dbname -dbhost=$dbhost > $htmldir/omim_sprot.xml.`date +%F`
\cp -f $htmldir/omim_sprot.csv.`date +%F` $htmldir/omim_sprot.csv
\cp -f $htmldir/omim_sprot.xml.`date +%F` $htmldir/omim_sprot.xml
(cd $htmldir; gzip omim_sprot.csv.`date +%F`)
(cd $htmldir; gzip omim_sprot.xml.`date +%F`)
# Store the date of the update
./setdate.pl >$htmldir/datefile.txt
# Restore web access
echo "Restoring web access..."
./available.sh $cgidir $htmldir

