#!/usr/bin/perl
#*************************************************************************
#
#   Program:    
#   File:       
#   
#   Version:    
#   Date:       
#   Function:   
#   
#   Copyright:  (c) UCL / Dr. Andrew C. R. Martin 2005
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
my($fname, %sprot_tell, $indexfile, $key, $pos);

$fname = shift(@ARGV);
$indexfile = shift(@ARGV);

open(FILE,$fname) || die "Cannot open seq file $fname";
dbmopen %sprot_tell, $indexfile, 0666 || die "Can't dbopen $indexfile";

$pos = 0;
while(<FILE>) {
    if(/^>(\w+)\s\(([OPQ][0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9])\)/)
    {
        $key=$2;
        $sprot_tell{$key} = $pos;
    }
    $pos = tell(FILE);
}

dbmclose %sprot_tell;
close(FILE);
