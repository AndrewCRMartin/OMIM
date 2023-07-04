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
# Packages to use
use strict;

$|=1;

print "COPY swsomim FROM STDIN;\n";
ProcessSwissProt();
print "\\.\n";

#######################################################################
sub ProcessSwissProt
{
    my($id, $date, $seq, @acs, @fields, @pdbs, @omims);
    while(<>)
    {
        chomp;
        if(/^\/\//)            # End of entry
        {
            $seq =~ s/\s//g;
#            StoreEntry($id, $date, $seq, \@acs, \@pdbs, \@omims) if($id ne "");
            WriteEntry($acs[0], \@omims) if($id ne "");
            $id  = "";
            @acs  = ();
            @pdbs = ();
            @omims = ();
            $date = "";
            $seq  = "";
        }
        if(/^ID /)
        {
            @fields = split;
            $id = $fields[1];
        }
        elsif(/^AC /)
        {
            s/\;/ /g;           # Remove semi-colons
            s/\s+/ /g;          # Condense white-space
            @fields = split;    # Grab the accessions
            shift @fields;
            push @acs, @fields;
        }
        elsif(/^DT /)
        {
            @fields = split;    # Store the final date record
            $date = $fields[1];
        }
        elsif(/^DR /)
        {
            s/\;/ /g;           # Remove semi-colons
            s/\s+/ /g;          # Condense white-space
            tr/A-Z/a-z/;        # Down-case
            @fields = split;
            if($fields[1] eq "pdb")
            {
                push @pdbs, $fields[2];
            }
            elsif($fields[1] eq "mim")
            {
                push @omims, $fields[2];
            }
        }
        elsif(/^   /)
        {
            $seq .= $_;
        }
    }
}

#######################################################################
sub WriteEntry
{
    my($ac, $omims_p) = @_;
    my($omim);

    foreach $omim (@$omims_p)
    {
        print "$ac\t$omim\n";
    }
}

