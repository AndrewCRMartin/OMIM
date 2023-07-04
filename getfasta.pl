#!/acrm/usr/local/bin/perl -s
#*************************************************************************
#
#   Program:    
#   File:       
#   
#   Version:    
#   Date:       
#   Function:   
#   
#   Copyright:  (c) UCL / Dr. Andrew C. R. Martin 2004
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   Phone:      +44 (0)171 679 7034
#   EMail:      andrew@bioinf.org.uk
#               martin@biochem.ucl.ac.uk
#   Web:        http://www.bioinf.org.uk/
#               
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#
#*************************************************************************
use strict;

my($fname, $ac, %sprot_tell, $indexfile, $entry, @acs, $tmp_fasta);
my(@omims, $omim, $tmp_mutant, $i, $results);
my($native_p, $resnum_p, $mutant_p);
my($native, $resnum, $mutant);

UsageDie() if(defined($::h));

# Get the SwissProt FASTA index information and connect to it
$fname = shift(@ARGV);
$indexfile = shift(@ARGV);
open(FILE,$fname) || die "Cannot open seq file $fname";
dbmopen %sprot_tell, $indexfile, 0666 || die "Can't dbopen $indexfile";

$ac = shift(@ARGV);

# Grab a FASTA format entry
$entry = GetFASTA($ac, \%sprot_tell);
print "$entry";

# Tidy up
dbmclose %sprot_tell;
close FILE;

#*************************************************************************
sub GetFASTA
{
    my($ac, $sprot_tell_p) = @_;
    my($pos, $entry);

    $pos = $$sprot_tell_p{$ac};

    seek(FILE, $pos, 0);
    $entry = "";
    while(<FILE>)
    {
        if((/^>/) && ($entry ne ""))
        {
            last;
        }
        $entry .= $_;
    }
    return $entry;
}

#*************************************************************************
sub UsageDie
{
    print <<__EOF;

Usage: getfasta.pl fasta_file index_file sprot_ac

__EOF

    exit 0;
}
