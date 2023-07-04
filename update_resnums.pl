#!/acrm/usr/local/bin/perl
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

my ($record, $resnum_orig, $native, $resnum, $mutant, $ok, $ac, $omim);
my ($matches, $newres);

while(<>)
{
    chomp;
    if(/^>\s([OPQ][0-9][A-Z0-9][A-Z0-9][A-Z0-9][0-9])\s:\s(.*)/)
    {
        $ac = $1;
        $omim = $2;
    }
    elsif(!/^\#/)
    {
        s/^\s+//;
        if(length)
        {
            ($record, $resnum_orig, $native, $resnum, $mutant, $ok, $matches, $newres) = split;
            if($ok eq "OK")
            {
                print "UPDATE omim_mutant SET resnum = $resnum, valid = 't'
                       WHERE omim = '$omim' AND 
                             record = '$record' AND 
                             native = '$native' AND
                             mutant = '$mutant' AND
                             resnum_orig = $resnum_orig;\n";
            }
            else
            {
                if($matches eq "Matches")
                {
                    print "UPDATE omim_mutant SET resnum = $newres, valid = '?'
                           WHERE omim = '$omim' AND 
                                 record = '$record' AND 
                                 native = '$native' AND
                                 mutant = '$mutant' AND
                                 resnum_orig = $resnum_orig;\n";
                }
            }
        }
    }
}
