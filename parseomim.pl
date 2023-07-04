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
print "COPY omim_mutant FROM STDIN;\n";
while(<>)
{
    if(/^\*RECORD\*/)
    {
        ProcessRecord(%record) if($record{'NO'});
        undef %record;
        $mode = '';
    }
    elsif(/^\*FIELD\*/)
    {
        ($junk,$mode) = split;
    }
    elsif(/^\*/)
    {
        $mode = '';
    }
    else
    {
        if($mode ne '')
        {
#            $record{$mode} .= ' ' if(defined($record{$mode}));
            $record{$mode} .= $_;
        }
    }
}
ProcessRecord(%record) if($record{'NO'});
print "\\.\n";

sub ProcessRecord
{
    my(%record) = @_;
    my(@words, $word, %mutations, $subrecord, $line, @lines, $newsub);

    chomp $record{'NO'};

    @lines = split(/\n/, $record{'AV'});
    foreach $line (@lines)
    {
        if($line =~ /^\.(\d\d\d\d)/)
        {
            $newsub = $1;
            foreach $key (keys %mutations)
            {
                ($from, $res, $to) = split(/:/, $key);
                print "$record{'NO'}\t$subrecord\t$from\t$res\t$res\t$to\tf\n";
            }
            $subrecord = $newsub;
            %mutations = ();
        }
        else
        {
            @words = split(/\s+/, $line);
            foreach $word(@words)
            {
                if($word =~ /([A-Z][A-Z][A-Z])(\d+)([A-Z][A-Z][A-Z])/)
                {
                    $from = $1;
                    $res  = $2;
                    $to   = $3;
                    if((($from eq 'ALA') || 
                        ($from eq 'CYS') || 
                        ($from eq 'ASP') || 
                        ($from eq 'GLU') || 
                        ($from eq 'PHE') || 
                        ($from eq 'GLY') || 
                        ($from eq 'HIS') || 
                        ($from eq 'ILE') || 
                        ($from eq 'LYS') || 
                        ($from eq 'LEU') || 
                        ($from eq 'MET') || 
                        ($from eq 'ASN') || 
                        ($from eq 'PRO') || 
                        ($from eq 'GLN') || 
                        ($from eq 'ARG') || 
                        ($from eq 'SER') || 
                        ($from eq 'THR') || 
                        ($from eq 'VAL') || 
                        ($from eq 'TRP') || 
                        ($from eq 'TYR')) &&
                       (($to   eq 'ALA') ||
                        ($to   eq 'CYS') ||
                        ($to   eq 'ASP') ||
                        ($to   eq 'GLU') ||
                        ($to   eq 'PHE') ||
                        ($to   eq 'GLY') ||
                        ($to   eq 'HIS') ||
                        ($to   eq 'ILE') ||
                        ($to   eq 'LYS') ||
                        ($to   eq 'LEU') ||
                        ($to   eq 'MET') ||
                        ($to   eq 'ASN') ||
                        ($to   eq 'PRO') ||
                        ($to   eq 'GLN') ||
                        ($to   eq 'ARG') ||
                        ($to   eq 'SER') ||
                        ($to   eq 'THR') ||
                        ($to   eq 'VAL') ||
                        ($to   eq 'TRP') ||
                        ($to   eq 'TYR')))
                    {
                        $key  = "$from:$res:$to";
                        $mutations{$key} = 1;
                    }
                }
            }
        }
    }

    foreach $key (keys %mutations)
    {
        ($from, $res, $to) = split(/:/, $key);
        print "$record{'NO'}\t$subrecord\t$from\t$res\t$res\t$to\tn\n";
    }
}
