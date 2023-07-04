omimdata=/tmp/omim/omim.txt.Z
sprot=/acrm/data/swissprot/full/uniprot_sprot.dat
fasta=/acrm/data/swissprot/full/uniprot_sprot.fasta
idx=/tmp/sprot.idx
dbname=omim
dbhost=acrm1
validate=/home/bsm/martin/SAAP/omim/validate.pl

# Create the database
echo "Creating database tables..."
psql $dbname < create.sql
# Grab the mutations from OMIM
echo "Parsing OMIM data..."
zcat $omimdata | ./parseomim.pl | psql $dbname
# Cross-reference with SwissProt
echo "Parsing SwissProt data..."
./ProcessSProt.pl $sprot | psql $dbname
# Index SwissProt FASTA file
echo "Indexing FASTA version of SwissProt..."
./indexfasta.pl $fasta $idx
# Now validate the residue number for the OMIM entries
echo "Validating OMIM entries..."
./wrapvalidate.pl -validate=$validate -dbname=$dbname -dbhost=$dbhost $fasta $idx | ./update_resnums.pl | psql $dbname
# Now dump the mapping in plain text and XML
echo "Dumping mapping as a CSV file..."
./dump_mapping.pl -dbname=$dbname -dbhost=$dbhost > omim_sprot.csv
echo "Dumping mapping as an XML file..."
./dump_mapping.pl -xml -dbname=$dbname -dbhost=$dbhost > omim_sprot.xml
