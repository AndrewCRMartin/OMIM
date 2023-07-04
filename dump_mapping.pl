#!/usr/bin/perl -s
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
# Packages to use
use ACRMPerlVars;
use DBI;

use strict;

$|=1;

# Default variables
$::dbname    = "omim" if(!defined($::dbname));
$::dbhost    = $ACRMPerlVars::pghost if(!defined($::dbhost));

# Connect to the database
$::dbh  = DBI->connect("dbi:Pg:dbname=$::dbname;host=$::dbhost");
die "Could not connect to database: $DBI::errstr" if(!$::dbh);

DoProcessing();

#*************************************************************************
sub DoProcessing
{
    my($sql, $sth, $rv, @results, $result, $omim);

    $sql = "SELECT omim, record, ac, native, resnum, mutant, valid, resnum_orig FROM sws_mutant ORDER BY omim, record";
    $sth = $::dbh->prepare($sql);
    $rv = $sth->execute;
    if($rv)
    {
        $omim = "";
        print "<omim_mutations>\n" if(defined($::xml));
        while(@results = $sth->fetchrow_array)
        {
            # remove spaces
            foreach my $result (@results)
            {
                $result =~ s/\s//g;
            }
            
            if(defined($::xml))
            {
                if($results[0] ne $omim)
                {
                    print "   </omim>\n" if($omim ne "");
                    $omim = $results[0];
                    print "   <omim id='$omim'>\n";
                }

                print  "      <record id='$results[1]'>\n";
                print  "         <sprot_ac>$results[2]</sprot_ac>\n";
                printf "         <omim_resnum correct='%s'>$results[7]</resnum>\n",
                       ((($results[4] == $results[7])&&
                         ($results[6] ne 'f'))?'t':'f');
                print  "         <resnum valid='$results[6]'>$results[4]</resnum>\n";
                print  "         <native>$results[3]</native>\n";
                print  "         <mutant>$results[5]</mutant>\n";
                print  "      </record>\n";
            }
            else
            {
                my($i) = 0;
                foreach my $result (@results)
                {
                    print "," if($i++ != 0);
                    print $result;
                }
                print "\n";
            }        
        }
        if(defined($::xml))
        {
            print "   </omim>\n" if($omim ne "");
            print "</omim_mutations>\n";
        }
    }
}

