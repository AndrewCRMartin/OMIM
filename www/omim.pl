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
#   23.12.10
#   11.07.11 Updates to external links
#
#*************************************************************************
require ACRMPerlVars;
$::dbname      = "omim";
$::dbhost      = $ACRMPerlVars::pghost;
$::psql        = "/acrm/usr/local/bin/psql -h $::dbhost -tqc";
$::unavailable = "/acrm/www/cgi-bin/omim/unavailable";
#$::omimlink    = "http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=";
$::omimlink    = "http://omim.org/entry/";
#$::sprotlink   = "http://us.expasy.org/uniprot/";
$::sprotlink   = "http://www.uniprot.org/uniprot/";
$::pdbswslink  = "/cgi-bin/pdbsws/query.pl?qtype=ac&id=";
$::lookupomim  = "/cgi-bin/omim/omim.pl?sortby=omim&omim=";
$::lookupsprot = "/cgi-bin/omim/omim.pl?sortby=omim&ac=";
$::colour_ok   = "#FFFFFF";
$::colour_warn = "#FFFFAA";
$::colour_bad  = "#FFAAAA";
$::colour_sep  = "#666666";
use CGI;
use strict;

my($ac, $pheno, $omim, $sql, $results, $sortby);

my $cgi = new CGI;
$ac     = $cgi->param('ac');
$pheno  = $cgi->param('pheno');
$omim   = $cgi->param('omim');
$sortby = $cgi->param('sortby');

print $cgi->header();

if(-e $::unavailable)
{
    ErrorPage("Unavailable",
              "The OMIM mutations database is temporarily unavailable 
               during an update<br />Please try again in 5 minutes");
}
else
{
    $sql = BuildSQL($ac, $pheno, $omim, $sortby);
    if($sql eq "")
    {
        ErrorPage("Error","You must complete at least one field!");
    }
    else
    {
        $results = `$::psql "$sql" $::dbname`;
        PrintHTMLHeader();
        print "<h1>OMIM search results</h1>\n";
        PrintResults($results, $sortby);
        PrintHTMLFooter();
    }
}

#*************************************************************************
sub BuildSQL
{
    my($ac, $pheno, $omim, $sortby) = @_;
    my($from, $where, $gotsome);

    $from = "sws_mutant m, omim_description d";
    $gotsome = 0;
    $where = "m.omim = d.omim AND m.record = d.record";
    if($ac ne "")
    {
        $ac = "\U$ac";
        $where .= " AND m.ac='$ac'";
        $gotsome = 1;
    }
    if($omim ne "")
    {
        $omim = "\U$omim";
        $where .= " AND m.omim='$omim'";
        $gotsome = 1;
    }
    if($pheno ne "")
    {
        $pheno = "\U$pheno";
        $where .= " AND d.descrip LIKE '\%$pheno\%'";
        $gotsome = 1;
    }

    $sql = "";
    if($gotsome)
    {
        $sortby = FixSortBy($sortby);
        $sql = "SELECT m.omim, m.record, m.ac, m.native, m.resnum, m.mutant, m.valid, m.resnum_orig, d.descrip FROM $from WHERE $where ORDER BY $sortby";
    }

    return($sql);
}

#*************************************************************************
sub FixSortBy
{
    my($sortby) = @_;

    if($sortby eq "omim")
    {
        $sortby = "m.omim, m.record";
    }
    elsif($sortby eq "sprot")
    {
        $sortby = "m.ac, m.resnum, m.omim, m.record";
    }
    else
    {
        $sortby = "m.omim, m.record";
    }

    return($sortby);
}

#*************************************************************************
sub ErrorPage
{
    my($error, $msg) = @_;
    PrintHTMLHeader();
    print <<__EOF;
<h1>OMIM Mutations Search</h1>
<h2>$error</h2>
<p class='warning'>$msg</p>
__EOF
    PrintHTMLFooter();
}

#*************************************************************************
sub PrintHTMLHeader
{
   print <<__EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
<link rel='stylesheet' href='/bo.css' />
<title>OMIM mutation search</title>
</head>
<body>
__EOF
}

#*************************************************************************
sub PrintHTMLFooter
{
   print <<__EOF;
</body>
</html>
__EOF
}


#*************************************************************************
sub PrintResults
{
    my($results, $sortby) = @_;
    my(@tuples, $tuple, @fields, $key, $current);
    $current = "";

    if($sortby eq "omim")
    {
        $key = 0;
    }
    elsif($sortby eq "sprot")
    {
        $key = 2;
    }
    else
    {
        $key = 0;
    }

    PrintKey();

    print "<table class='mytable'>\n";

    PrintTableHeader();
    @tuples = split(/\n/, $results);
    foreach $tuple (@tuples)
    {
        @fields = split(/\|/, $tuple);
        $current = $fields[$key] if($current eq "");
        if($current ne $fields[$key])
        {
            $current = $fields[$key];
            PrintTableHeader();
        }
        $fields[4] = '?' if($fields[6] =~ 'f');
        StartRow($fields[6]);
        PrintField($fields[0], $::lookupomim, 
                   "[O]", $::omimlink);       # OMIM ID
        PrintField($fields[1], "");           # Variant ID
        PrintField($fields[2], $::lookupsprot, 
                   "[S]", $::sprotlink,
                   "[P]", $::pdbswslink,
                   $fields[4], "&res=");      # SwissProt AC
        PrintField($fields[3], "");           # Native residue
        PrintField($fields[4], "");           # Residue number
        PrintField($fields[5], "");           # Mutant residue
        PrintField($fields[7], "");           # Original residue number
        PrintField($fields[8], "");           # Description
        EndRow();
    }
    print "</table>\n";
}

#*************************************************************************
sub PrintTableHeader
{
    print <<__EOF;
<tr class='mytable'><th>OMIM ID</th>
    <th>Variant ID</th>
    <th>SwissProt AC</th>
    <th>Native residue</th>
    <th>Residue number</th>
    <th>Mutant residue</th>
    <th>Original residue number</th>
    <th>Description</th>
</tr>
__EOF
}
#*************************************************************************
sub PrintKey
{
    print <<__EOF;
<h3>Fields are colour coded as follows:
</h3>
<table border='1'>
    <tr><td bgcolor='$::colour_ok'>Validated residue number</td>
        <td bgcolor='$::colour_warn'>Probable residue number</td>
        <td bgcolor='$::colour_bad'>Invalid residue number</td>
    </tr>
    <tr><td colspan='3'><b>[O]</b> Jump to OMIM database entry</td></tr>
    <tr><td colspan='3'><b>[S]</b> Jump to UniProt database entry</td></tr>
    <tr><td colspan='3'><b>[P]</b> Jump to PDBSWS (PDB mapping) database entry</td></tr>
</table>
<p></p>
__EOF
}
#*************************************************************************
sub StartRow
{
    my($ok) = @_;

    $ok =~ s/\s//g;
    if($ok eq 't')
    {
        $ok = "bgcolor='$::colour_ok'";
    }
    elsif($ok eq 'f')
    {
        $ok = "bgcolor='$::colour_bad'";
    }
    elsif($ok eq '?')
    {
        $ok = "bgcolor='$::colour_warn'";
    }
    else
    {
        $ok = "";
    }

    print "<tr $ok>";
}

#*************************************************************************
sub EndRow
{
    print "</tr>\n";
}

#*************************************************************************
sub PrintField
{
    my($text, $link, $text2, $link2, $text3, $link3, $text4, $link4) = @_;
    my($endlink1) = "";
    my($endlink2) = "";
    my($endlink3) = "";

    if($link ne "")
    {
        $link     =~ s/\s//g;
        $text     =~ s/\s//g;
        $link     = "<a href='$link$text'>";
        $endlink1 = "</a>";

        if($link2 ne "")
        {
            $link2    =~ s/\s//g;
            $text2    =~ s/\s//g;
            $link2    = "<a href='$link2$text'>";
            $endlink2 = "</a>";

            if($link3 ne "")
            {
                $link3    =~ s/\s//g;
                $text3    =~ s/\s//g;
                $link3    = "<a href='$link3$text";
                if($link4 ne "")
                {
                    $text4 =~ s/\s//g;
                    $link3 .= $link4 . $text4;
                }
                $link3 .= "'>";
                $endlink3 = "</a>";
            }
        }
    }

    print "<td>$link$text$endlink1&nbsp;$link2$text2$endlink2&nbsp;$link3$text3$endlink3</td>";
}
