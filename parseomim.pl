#!/usr/bin/perl
#*************************************************************************
#
#   Program:    
#   File:       
#   
#   Version:    V1.1
#   Date:       10.12.09
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
#   V1.0  06.12.06   Original   By: ACRM
#   V1.1  10.12.09   Changed to INSERT each record rather than use COPY
#                    to deal with OMIM entry 120120 which has two .0041
#                    subrecords and broke the primary key. Using INSERT
#                    will just reject the second entry...
#*************************************************************************
use strict;

@::descriptions = ();
my($description, %record, $mode, $junk);

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
            $record{$mode} .= $_;
        }
    }
}
ProcessRecord(%record) if($record{'NO'});

foreach $description (@::descriptions)
{
    $description =~ s/\'/\'\'/g;
    $description =~ s/\s+$//g;
    my @fields = split(/\t/, $description);
    printf "INSERT INTO omim_description VALUES('%s','%s','%s');\n",
           $fields[0], $fields[1], $fields[2];
}


sub ProcessRecord
{
    my(%record) = @_;
    my(@words, $word, %mutations, $subrecord, $line, @lines);
    my($newsub, $indata, $info, $key, $from, $res, $to);

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
            push @::descriptions, "$record{'NO'}\t$subrecord\t$info";
                printf "INSERT INTO omim_mutant VALUES('%s', '%s', '%s', %d, %d, '%s', 'f');\n",
                       $record{'NO'}, $subrecord, $from, $res, $res, $to;
            }
            $subrecord = $newsub;
            %mutations = ();
            $indata = 1;
            $info = "";
        }
        elsif($indata)
        {            
            if(length($line) == 0)
            {
                $indata = 0;
            }
            else
            {
                $info .= $line . " ";
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
    }

    # Print the last one...
    push @::descriptions, "$record{'NO'}\t$subrecord\t$info";
    foreach $key (keys %mutations)
    {
        ($from, $res, $to) = split(/:/, $key);
        printf "INSERT INTO omim_mutant VALUES('%s', '%s', '%s', %d, %d, '%s', 'f');\n",
                $record{'NO'}, $subrecord, $from, $res, $res, $to;
    }
}
