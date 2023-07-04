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
   $fasta_seq, $resnum_p, $offset, $ok, $nmatch, $maxmatch,
   $record_p);

UsageDie() if(defined($::h));

%::throne = ();
$fasta_file = shift @ARGV;

InitThrone();
$fasta_seq = ReadFASTA($fasta_file);
@fullseq = split(//, $fasta_seq);
($origseq_p, $mutseq_p, $keyseq_p, $resnum_p, $record_p) = ReadMutations();

($offset, $ok, $nmatch, $maxmatch) = Slide(\@fullseq, $keyseq_p, $resnum_p);
if($ok)
{
    print "# Perfect match at offset: $offset\n";
    PrintResults($origseq_p, $mutseq_p, $resnum_p, $record_p, \@fullseq, $offset);
}
else
{
    if((($offset == 0) && ($nmatch >= 2)) ||
       (($nmatch >= 5) && ($nmatch/$maxmatch > 0.5)))
    {
        print "# Partial match at offset: $offset\n";
        PrintResults($origseq_p, $mutseq_p, $resnum_p, $record_p, \@fullseq, $offset);
    }
    else
    {
        print "# No match... Best offset was $offset with $nmatch/$maxmatch matches\n";
    }
}

#*************************************************************************
sub PrintResults
{
    my($origseq_p, $mutseq_p, $resnum_p, $record_p, $fullseq_p, $offset) = @_;
    my($i, $ok);

    for($i=0; $i<scalar(@$resnum_p); $i++)
    {
        $ok = (($$resnum_p[$i]+$offset-1 >= 0) &&
               ($::throne{$$origseq_p[$i]} eq 
                $$fullseq_p[$$resnum_p[$i]+$offset-1]))?"OK\n":"NO";
        printf "%s %d %s %d %s %s", $$record_p[$i], $$resnum_p[$i],
                                $$origseq_p[$i],
                                $$resnum_p[$i] + $offset,
                                $$mutseq_p[$i],
                                $ok;
        if($ok eq "NO")
        {
            if($::throne{$$origseq_p[$i]} eq
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
    my($maxslide, $i, $j, $nmut, $bestoffset, $bestnmatch, $nmatch,
       $outofrange);
    $bestnmatch = $bestoffset = $outofrange = 0;
    
    $maxslide = scalar(@$full_p);
    $nmut = scalar(@$resnum_p);

    # Count how many of the mutations are out of range when we apply
    # no slide
    for($j=0; $j<$nmut; $j++)
    {
        $outofrange++ if(!defined($$full_p[$$resnum_p[$j]-1]));
    }

    if($outofrange == $nmut)
    {
        return(0,0,0,$nmut);
    }

    for($i=0; $i<$maxslide; $i++)
    {
        $nmatch = 0;
        for($j=0; $j<$nmut; $j++)
        {
            $nmatch++ if(($$resnum_p[$j]+$i-1 >= 0) &&
                         defined($$full_p[$$resnum_p[$j]+$i-1]) &&
                         ($$full_p[$$resnum_p[$j]+$i-1] eq
                          $$key_p[$j]));
        }

        if(($nmatch >= $nmut - $outofrange) && ($nmut > $outofrange))
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
            $nmatch++ if(($$resnum_p[$j]+$i-1 >= 0) &&
                         defined($$full_p[$$resnum_p[$j]+$i-1]) &&
                         ($$full_p[$$resnum_p[$j]+$i-1] eq
                          $$key_p[$j]));
        }

        if(($nmatch >= $nmut - $outofrange) && ($nmut > $outofrange))
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
    my($resnum, $aa_orig, $aa_mut, @seq_orig, @seq_mut, @seq_key, $i);
    my(@records, @resnums, $record);
    while(<>)
    {
        chomp;
        s/^\s+//;
        if(length)
        {
            ($record, $aa_orig, $resnum, $aa_mut) = split;
            $aa_orig = "\U$aa_orig";
            $aa_mut  = "\U$aa_mut";
            push @seq_key, $::throne{$aa_orig};
            push @seq_orig, $aa_orig;
            push @resnums, $resnum;
            push @records, $record;
            push @seq_mut, $aa_mut;
        }
    }

    return(\@seq_orig, \@seq_mut, \@seq_key, \@resnums, \@records);
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

Usage: validate.pl sequence.faa mutations_list

The mutations list is in the format:
   ID orig_aa orig_resnum mutant_aa
where orig_aa and mutant_aa are 3-letter code

Output is in the format:
   ID orig_resnum orig_aa corrected_resnum mutant_aa flag [message]
where flag is either 'OK' (indicating that the corrected_resnum is
correct with high confidence) or 'NO'
If 'NO' and there is no message, then the residue could not be
found. If there is a message, then it will be in the form 'Matches nnn'
This indicates that after applying an offset, there was no match,
but that a match was found with an offset of zero and nnn will
then match the orig_resnum. The format allows for future expension
where a second offset might be allowed.

__EOF

   exit 0;
}
