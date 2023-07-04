#!/acrm/usr/local/bin/perl
#*************************************************************************
#
#   Program:    indexfasta
#   File:       indexfasta.pl
#   
#   Version:    V1.1
#   Date:       06.12.06
#   Function:   Index the FASTA dump of SwissProt
#   
#   Copyright:  (c) UCL / Dr. Andrew C. R. Martin 2005-2006
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
#   13.06.05 V1.0  Original
#   06.12.06 V1.1  Format of the SwissProt FASTA dump has changed. Code
#                  now checks that some sequences were found and indexed
#
#*************************************************************************
use strict;
my($fname, %sprot_tell, $indexfile, $key, $pos, $count);

$fname = shift(@ARGV);
$indexfile = shift(@ARGV);

open(FILE,$fname) || die "Cannot open seq file $fname";
dbmopen %sprot_tell, $indexfile, 0666 || die "Can't dbopen $indexfile";

$pos = 0;
$count = 0;
while(<FILE>) {
# 06.12.06 The format of this line changed!!!!
#    if(/^>(\w+)\s\(([OPQ][0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9])\)/)
    if(/^>([OPQ][0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9])\|/)
    {
        $key=$1;
        $sprot_tell{$key} = $pos;
        $count++;
    }
    $pos = tell(FILE);
}

dbmclose %sprot_tell;
close(FILE);

if($count == 0)
{
    print STDERR <<__EOF;
FATAL ERROR (indexfasta.pl): No sequences were found to index
__EOF
    exit(1);
}

