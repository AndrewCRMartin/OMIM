omimdatadir=/acrm/data/tmp/
omimdata=$omimdatadir/omim.txt.Z
omimurl=ftp://ftp.ncbi.nih.gov/repository/OMIM/omim.txt.Z
sprot=/acrm/data/swissprot/full/uniprot_sprot.dat
fasta=/acrm/data/swissprot/full/uniprot_sprot.fasta
idx=/tmp/sprot.idx
dbname=omim2
dbhost=acrm8
validate=/home/bsm/martin/SAAP/omim/validate.pl
htmldir=/acrm/www/html/omim
cgidir=/acrm/www/cgi-bin/omim


# Grab the OMIM data
\rm -f $omimdata
(cd $omimdatadir; wget $omimurl)
# Block web access
#echo "Blocking web access..."
#./unavailable.sh $cgidir $htmldir
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
#echo "Restoring web access..."
#./available.sh $cgidir $htmldir

