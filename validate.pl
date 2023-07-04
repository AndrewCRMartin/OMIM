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
#   Takes a FASTA file and a list of mutation sites with native residues.
#   Builds that list into a sequence and then matches the sequence against
#   the FASTA file. Finally reprints the mutation list with any reqiured
#   offset applied to the residue numbers.
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

my($keyseq_p, $mutseq_p, $origseq_p, $fasta_file, @fullseq,
   $fasta_seq, $resnum_p, $offset, $ok, $nmatch, $maxmatch);

UsageDie() if(defined($::h));

%::throne = ();
$fasta_file = shift @ARGV;

InitThrone();
$fasta_seq = ReadFASTA($fasta_file);
@fullseq = split(//, $fasta_seq);
($origseq_p, $mutseq_p, $keyseq_p, $resnum_p) = ReadMutations();

($offset, $ok, $nmatch, $maxmatch) = Slide(\@fullseq, $keyseq_p, $resnum_p);
if($ok)
{
    print "# Perfect match at offset: $offset\n";
    PrintResults($origseq_p, $mutseq_p, $resnum_p, \@fullseq, $offset);
}
else
{
    if(($nmatch >= 5) && ($nmatch/$maxmatch > 0.5))
    {
        print "# Partial match at offset: $offset\n";
        PrintResults($origseq_p, $mutseq_p, $resnum_p, \@fullseq, $offset);
    }
    else
    {
        print "# No match... Best offset was $offset with $nmatch/$maxmatch matches\n";
    }
}

#*************************************************************************
sub PrintResults
{
    my($origseq_p, $mutseq_p, $resnum_p, $fullseq_p, $offset) = @_;
    my($i, $ok);

    for($i=0; $i<scalar(@$resnum_p); $i++)
    {
        $ok = ($::throne{$$origseq_p[$$resnum_p[$i]]} eq 
               $$fullseq_p[$$resnum_p[$i]+$offset-1])?"OK\n":"NO";
        printf "%d %s %d %s %s", $$resnum_p[$i],
                                $$origseq_p[$$resnum_p[$i]],
                                $$resnum_p[$i] + $offset,
                                $$mutseq_p[$$resnum_p[$i]],
                                $ok;
        if($ok eq "NO")
        {
            if($::throne{$$origseq_p[$$resnum_p[$i]]} eq
               $$fullseq_p[$$resnum_p[$i]-1])
            {
                print " Matches $$resnum_p[$i]";
            }
            print "\n";
        }

    }
}
#*************************************************************************
sub Slide
{
    my($full_p, $key_p, $resnum_p) = @_;
    my($maxslide, $i, $j, $nmut, $bestoffset, $bestnmatch, $nmatch);
    $bestnmatch = $bestoffset = 0;
    
    $maxslide = scalar(@$full_p);
    $nmut = scalar(@$resnum_p);
    for($i=0; $i<$maxslide; $i++)
    {
        $nmatch = 0;
        for($j=0; $j<$nmut; $j++)
        {
            $nmatch++ if($$full_p[$$resnum_p[$j]+$i-1] eq
                         $$key_p[$$resnum_p[$j]]);
        }

        if($nmatch == $nmut)
        {
            if((($i>=(-1)) && ($i<=1)) || ($nmatch > 1))
            {
                return($i, 1, $bestnmatch,$nmut);
            }
        }
        else
        {
            if($nmatch > $bestnmatch)
            {
                $bestnmatch = $nmatch;
                $bestoffset = $i;
            }
        }
    }
    for($i=0; $i>(0-$maxslide); $i--)
    {
        $nmatch = 0;
        for($j=0; $j<$nmut; $j++)
        {
            $nmatch++ if($$full_p[$$resnum_p[$j]+$i-1] eq
                         $$key_p[$$resnum_p[$j]]);
        }

        if($nmatch == $nmut)
        {
            if((($i>=(-1)) && ($i<=1)) || ($nmatch > 1))
            {
                return($i, 1, $bestnmatch,$nmut);
            }
        }
        else
        {
            if($nmatch > $bestnmatch)
            {
                $bestnmatch = $nmatch;
                $bestoffset = $i;
            }
        }
    }
    return($bestoffset,0,$bestnmatch,$nmut);
}

#*************************************************************************
sub InitThrone
{
    %::throne = ( 'ALA' => 'A',
                  'CYS' => 'C',
                  'ASP' => 'D',
                  'GLU' => 'E',
                  'PHE' => 'F',
                  'GLY' => 'G',
                  'HIS' => 'H',
                  'ILE' => 'I',
                  'LYS' => 'K',
                  'LEU' => 'L',
                  'MET' => 'M',
                  'ASN' => 'N',
                  'PRO' => 'P',
                  'GLN' => 'Q',
                  'ARG' => 'R',
                  'SER' => 'S',
                  'THR' => 'T',
                  'VAL' => 'V',
                  'TRP' => 'W',
                  'TYR' => 'Y');
}

#*************************************************************************
sub ReadMutations
{
    my($resnum, $aa_orig, $aa_mut, @seq_orig, @seq_mut, @seq_key, $i, @resnums);
    while(<>)
    {
        chomp;
        s/^\s+//;
        if(length)
        {
            ($aa_orig, $resnum, $aa_mut) = split;
            $aa_orig = "\U$aa_orig";
            $aa_mut  = "\U$aa_mut";
            $seq_orig[$resnum] = $aa_orig;
            $seq_mut[$resnum]  = $aa_mut;
            $seq_key[$resnum]  = $::throne{$aa_orig};
            push @resnums, $resnum;
        }
    }
    for($i=0; $i<@seq_key; $i++)
    {
        $seq_key[$i] = 'X' if(!defined($seq_key[$i]));
    }

    return(\@seq_orig, \@seq_mut, \@seq_key, \@resnums);
}


#*************************************************************************
sub ReadFASTA
{
    my($file) = @_;
    my($id, $sequence, $gotSequence);

    open(FILE, $file) || die "Can't read $file";
    $gotSequence = 0;
    $sequence = "";
    while(<FILE>)
    {
        s/\r//g;
        chomp;
        if(/^>/)
        {
            if($gotSequence)
            {
                last;
            }
            else
            {
                $id = substr($_,1);
            }
        }
        else
        {
            $sequence = $sequence . $_;
            $gotSequence = 1;
        }
    }
    close(FILE);
    $sequence =~ s/\s//g;
    return($id, $sequence);
}

#*************************************************************************
sub UsageDie
{
    print <<__EOF;

validate.pl sequence.faa mutations_list

__EOF

   exit 0;
}
