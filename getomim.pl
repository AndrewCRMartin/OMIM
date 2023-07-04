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
use strict;
use DBI;
use ACRMPerlVars;

my($fname, $ac, %sprot_tell, $indexfile, $entry, @acs, $tmp_fasta);
my(@omims, $omim, $tmp_mutant, $i, $results);
my($native_p, $resnum_p, $mutant_p, $record_p);
my($native, $resnum, $mutant, $record);

UsageDie() if(defined($::h));

# Default variables
$::dbname    = "omim" if(!defined($::dbname));
$::dbhost    = $ENV{'PGHOST'} if(!defined($::dbhost));

# Grab data from command line
$ac = shift(@ARGV);
$omim = shift(@ARGV);

# Connect to the database
$::dbh = DBI->connect("dbi:Pg:dbname=$::dbname;host=$::dbhost");
die "Could not connect to database: $DNI::errstr" if(!$::dbh);

# Extract the mutant list for this OMIM entry
($native_p, $resnum_p, $mutant_p, $record_p) = GetMutantList($ac, $omim);
for($i=0; $i<scalar(@$native_p); $i++)
{
    $record = $$record_p[$i];
    $native = $$native_p[$i];
    $resnum = $$resnum_p[$i];
    $mutant = $$mutant_p[$i];
    print "$record $native $resnum $mutant\n";
}

# Tidy up

#*************************************************************************
sub GetMutantList
{
    my($ac, $omim) = @_;
    my(@native, @resnum, @mutant, @record);
    my($sql, $sth, @results);

    $sql = "SELECT record, native, resnum_orig, mutant FROM sws_mutant WHERE ac = '$ac' AND omim = '$omim'";
    $sth=$::dbh->prepare($sql);
    if($sth && $sth->execute)
    {
        while(@results = $sth->fetchrow_array)
        {
            push @record, $results[0];
            push @native, $results[1];
            push @resnum, $results[2];
            push @mutant, $results[3];
        }
    }

    return(\@native, \@resnum, \@mutant, \@record);
}



#*************************************************************************
sub UsageDie
{
    print <<__EOF;

Usage: getomim.pl sprot_ac omim_id

__EOF

    exit 0;
}
