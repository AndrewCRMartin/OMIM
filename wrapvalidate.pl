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
my($native_p, $resnum_p, $mutant_p);
my($native, $resnum, $mutant);

UsageDie() if(defined($::h));

# Default variables
$::dbname    = "omim" if(!defined($::dbname));
$::dbhost    = $ACRMPerlVars::pghost if(!defined($::dbhost));
$::validate  = "./validate.pl" if(!defined($::validate));

# Connect to the database
$::dbh = DBI->connect("dbi:Pg:dbname=$::dbname;host=$::dbhost");
die "Could not connect to database: $DNI::errstr" if(!$::dbh);

# Set defaults
$tmp_fasta = "/tmp/omim_fasta_$$.faa";
$tmp_mutant = "/tmp/omim_mutant_$$.faa";

# Get the SwissProt FASTA index information and connect to it
$fname = shift(@ARGV);
$indexfile = shift(@ARGV);
open(FILE,$fname) || die "Cannot open seq file $fname";
dbmopen %sprot_tell, $indexfile, 0666 || die "Can't dbopen $indexfile";

# Get a list of SwissProt codes linking to OMIM
@acs = GetSprotList();

# Work through the sequences
foreach $ac (@acs)
{
    # Grab a FASTA format entry
    $entry = GetFASTA($ac, \%sprot_tell);
    # ...and put it in a file
    WriteFile($tmp_fasta, $entry);

    # Grab a list of OMIM entries which reference this FASTA file
    @omims = GetOMIMList($ac);
    # Work through the OMIM codes
    foreach $omim (@omims)
    {
        print "> $ac : $omim\n";
        # Extract the mutant list for this OMIM entry
        ($native_p, $resnum_p, $mutant_p) = GetMutantList($ac, $omim);
        open(MFILE, ">$tmp_mutant") || die "Can't write $tmp_mutant";
        for($i=0; $i<scalar(@$native_p); $i++)
        {
            $native = $$native_p[$i];
            $resnum = $$resnum_p[$i];
            $mutant = $$mutant_p[$i];
            print MFILE "$native $resnum $mutant\n";
        }
        close MFILE;
        $results = `$::validate $tmp_fasta $tmp_mutant`;

 print "$results\n\n\n";
    }
}

# Tidy up
dbmclose %sprot_tell;
close FILE;
unlink $tmp_fasta if(-e $tmp_fasta);

#*************************************************************************
sub GetMutantList
{
    my($ac, $omim) = @_;
    my(@native, @resnum, @mutant);
    my($sql, $sth, @results);

    $sql = "SELECT native, resnum, mutant FROM sws_mutant WHERE ac = '$ac' AND omim = '$omim'";
    $sth=$::dbh->prepare($sql);
    if($sth && $sth->execute)
    {
        while(@results = $sth->fetchrow_array)
        {
            push @native, $results[0];
            push @resnum, $results[1];
            push @mutant, $results[2];
        }
    }

    return(\@native, \@resnum, \@mutant);
}

#*************************************************************************
sub GetOMIMList
{
    my($ac) = @_;

    my($sql, $sth, @omims, @results);
    $sql = "SELECT DISTINCT omim FROM sws_mutant WHERE ac = '$ac'";
    $sth=$::dbh->prepare($sql);
    if($sth && $sth->execute)
    {
        while(@results = $sth->fetchrow_array)
        {
            push @omims, $results[0];
        }
    }
    return(@omims);
}

#*************************************************************************
sub GetSprotList
{
    my($sql, $sth, @acs, @results);
    $sql = "SELECT DISTINCT ac FROM sws_mutant";
    $sth=$::dbh->prepare($sql);
    if($sth && $sth->execute)
    {
        while(@results = $sth->fetchrow_array)
        {
            push @acs, $results[0];
        }
    }
    return(@acs);
}

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
sub WriteFile
{
    my($tmp_fasta, $entry) = @_;

    open(FASTA, ">$tmp_fasta") || die "Can't write $tmp_fasta";
    print FASTA $entry;
    close(FASTA);
}


#*************************************************************************
sub UsageDie
{
    print <<__EOF;

wrapvalidate.pl [-dbname=dbname] [-validate=validate] [-dbhost=dbhost] fasta_file index_file


__EOF

    exit 0;
}
