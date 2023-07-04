sprot=/path/to/uniprot_sprot.dat
fasta=/path/to/uniprot_sprot.fasta
idx=/var/tmp/sprot.idx
dbname=omim
dbhost=your_database_hostname
here=`pwd`
validate=$here/validate.pl
omimdatadir=/path/to/omim/data
tmpdir=/path/to/large/temp/directory/

# The archived version of OMIM. If you want a later version,
# you need to register for downloads at https://www.omim.org/downloads
omimfile=omim.txt.Z
omimurl=ftp://ftp.ncbi.nih.gov/repository/OMIM/ARCHIVE/$omimfile

# If creating a web site
# NOTE! THIS MUST BE FOR INTERNAL USE ONLY AS, SINCE 2011,
# OMIM NO LONGER ALLOWS REDISTRIBUTION WITHOUT A LICENCE
htmldir=/path/to/your/html/web/directory/omim
cgidir=/path/to/your/cgi/web/directory/omim
