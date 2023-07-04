package ACRMPerlVars;

# Where this file lives
$libdir = "/home/bsm/martin/scripts/lib";

# About the PDB
$pdbdir       = "/acrm/data/pdb";
$pdbprep      = "/acrm/data/pdb/pdb";
$pdbprepname  = "pdb";
$pdbext       = ".ent";

# Obsolete PDB
$obspdbdir = "/acrm/data/pdb_obsolete/uncompressed_files";
$obspdbprep = "pdb";
$obspdbext = ".ent";

# Other PDB-related files
$pdbdomdir = "/acrm/data/dompdb";
$domsstdir = "/acrm/data/domsst";
$sstdir    = "/acrm/data/sst";
$pdbseqdir = "/acrm/data/pdbseq";
$pisadir   = "/acrm/data/pisa";
$pisaext   = ".pisa";
$xmasdir   = "/acrm/data/xmas/pdb";
$xmasprep  = "${xmasdir}/pdb";
$xmasext   = ".xmas";

# My normal binaries directory
$bindir  = "/home/bsm/martin/bin";

# Other binaries directories
$ssapbindir = "/acrm/home/andrew/ssap/bin";
$mlsabindir = "/acrm/home/andrew/mlsa";
$sstrucbindir = "/acrm/home/andrew/sstruc/bin";

# CGI programs
$MailRecipient = "martin";  # Receives messages about who used progs
$NoMailHost    = "acrm1";  # Don't send messages if request was from
                            # this host
$toplib        = "/acrm/home/andrew/topscan/libstride/cathsn_e3h3.top-n-a-l-L";
                            # Library for topscan
$AdminEMail = "andrew\@bioinf.org.uk";

# Environment variables for Kabat related programs
$ENV{'KABATALIGN'} = "/acrm/home/andrew/kabat/data"; # Alignment matrices
$ENV{'KABATDIR'}   = "/acrm/data/kabat/kabatman";    # KabatMan data 
#$ENV{'KABATALIGN'} = "/home/bsm/martin/kabat/data"; # Alignment matrices
#$ENV{'KABATDIR'}   = "/home/bsm/martin/kabat/data";    # KabatMan data 



# My general data directory
$ENV{'DATADIR'}    = "/home/bsm/martin/data";


# BLAST related
$BlastAllExe       = "/acrm/usr/local/bin/blastall";
$BlastPGPExe       = "/acrm/usr/local/bin/blastpgp";
$BlastDBDir        = "/acrm/data/blastdb";
$BlastRCFile       = "/acrm/home/andrew/.ncbirc";

# FASTA related
$ssearch = "/acrm/usr/local/bin/ssearch33";
$fasta   = "/acrm/usr/local/bin/fasta33";
$ssearch_64 = "/acrm/usr64/local/bin/ssearch33";
$fasta_64   = "/acrm/usr64/local/bin/fasta33";

# PostgreSQL related
$pghost = "acrm8";
$psql   = "/acrm/usr/local/bin/psql";

$ENV{'PGHOST'} = $pghost;
$ENV{'PGLIB'} = "/usr/lib/pgsql";
$ENV{'LD_LIBRARY_PATH'} = "$ENV{'LD_LIBRARY_PATH'}:/usr/lib/pgsql";

# SAAP related
$saapServerBindir = "/home/bsm/martin/SAAP/server/";

1;
