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
# Packages to use
#require ACRMPerlVars;
use Template;
use CGI;
use DBI;

use strict;

$|=1;

# Default variables
$::dbname    = "omim" if(!defined($::dbname));
$::datefile  = "./datefile.txt" if(!defined($::datefile));
$::dbhost    = "db" if(!defined($::dbhost));

# Connect to the database
$::dbh  = DBI->connect("dbi:Pg:dbname=$::dbname;host=$::dbhost");
die "Could not connect to database: $DBI::errstr" if(!$::dbh);

GetDate();
GetStats();
ProcessTemplate();

#*************************************************************************
sub GetDate
{
    $::vars{'date'} = `cat $::datefile`;
}

#*************************************************************************
sub GetStats
{
    my($sql, $n_omim_total, $n_omim, $n_omim_error);
    my($n_omim_class_a, $n_omim_class_b, $n_omim_class_c);
    my($n_mutant_total, $n_mutant);
    my($n_class_a, $n_class_b, $n_class_c);
    my($n_offset, $n_omim_offset);

    $sql = "SELECT count(distinct omim) FROM omim_mutant";
    ($n_omim_total) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(distinct omim) FROM sws_mutant";
    ($n_omim) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(distinct omim) FROM sws_mutant WHERE valid = 't'";
    ($n_omim_class_a) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(distinct omim) FROM sws_mutant WHERE valid = '?'";
    ($n_omim_class_b) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(distinct omim) FROM sws_mutant WHERE valid = 'f'";
    ($n_omim_class_c) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(distinct omim) FROM sws_mutant WHERE valid = 'f' or valid = '?'";
    ($n_omim_error) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(*) FROM omim_mutant";
    ($n_mutant_total) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(*) FROM sws_omim_mutant";
    ($n_mutant) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(*) FROM sws_mutant where valid = 't'";
    ($n_class_a) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(*) FROM sws_mutant where valid = '?'";
    ($n_class_b) = $::dbh->selectrow_array($sql);

    $sql = "SELECT count(*) FROM sws_mutant where valid = 'f'";
    ($n_class_c) = $::dbh->selectrow_array($sql);

    $sql = "select count(*) from sws_mutant where resnum != resnum_orig and valid = 't'";
    ($n_offset) = $::dbh->selectrow_array($sql);

    $sql = "select count(distinct omim) from sws_mutant where resnum != resnum_orig and valid = 't'";
    ($n_omim_offset) = $::dbh->selectrow_array($sql);

    $::vars{'n_omim_total'} = $n_omim_total;
    $::vars{'n_mutant_total'} = $n_mutant_total;
    $::vars{'n_omim'} = $n_omim;
    $::vars{'n_omim_perc'} = sprintf("%.1f",100*$n_omim/$n_omim_total);
    $::vars{'n_mutant'} = $n_mutant;
    $::vars{'n_mutant_perc'} =            sprintf("%.1f",100*$n_mutant/$n_mutant_total);
    $::vars{'n_class_a'} = $n_class_a;
    $::vars{'n_class_b'} = $n_class_b;
    $::vars{'n_class_c'} = $n_class_c;
    $::vars{'n_class_a_perc'} =            sprintf("%.1f",100*$n_class_a/$n_mutant);
    $::vars{'n_class_b_perc'} =            sprintf("%.1f",100*$n_class_b/$n_mutant);
    $::vars{'n_class_c_perc'} =            sprintf("%.1f",100*$n_class_c/$n_mutant);
    $::vars{'n_omim_class_a'} = $n_omim_class_a;
    $::vars{'n_omim_class_b'} = $n_omim_class_b;
    $::vars{'n_omim_class_c'} = $n_omim_class_c;
    $::vars{'n_omim_class_a_perc'} =       sprintf("%.1f",100*$n_omim_class_a/$n_omim);
    $::vars{'n_omim_class_b_perc'} =       sprintf("%.1f",100*$n_omim_class_b/$n_omim);
    $::vars{'n_omim_class_c_perc'} =       sprintf("%.1f",100*$n_omim_class_c/$n_omim);
    $::vars{'n_omim_error'} = $n_omim_error;
    $::vars{'n_omim_error_perc'} =            sprintf("%.1f",100*$n_omim_error/$n_omim);
    $::vars{'n_offset'} = $n_offset;
    $::vars{'n_offset_perc'} = sprintf("%.1f",100*$n_offset/$n_mutant);
    $::vars{'n_omim_offset'} = $n_omim_offset;
    $::vars{'n_omim_offset_perc'} = sprintf("%.1f",100*$n_omim_offset/$n_omim);
}

#*************************************************************************
sub ProcessTemplate
{
    my $cgi = new CGI;
    print $cgi->header();

    my $tt = Template->new({
        INCLUDE_PATH => '.:/serv/www/html_bioinf'
        });
    $tt->process(\*DATA, \%::vars) || die $tt->error();
}

__DATA__
[% INCLUDE "header.tt"
   serversactive="active"
 %]
[% INCLUDE "main_menu.tt" 
   mutations = " id='mcurrent'"
%]

<section id="inner-headline">
  <div class="container">
    <div class="row">
      <div class="span12">
        <div class="inner-heading">
          <ul class="breadcrumb">
            <li><a href="[%root%]/">Home</a> <i class="icon-angle-right"></i></li>
            <li><a href="[%root%]/servers/">Other servers</a> <i class="icon-angle-right"></i></li>
            <li><a href="[%root%]/servers/omim/">OMIM</a> <i class="icon-angle-right"></i></li>
            <li class="active">Statistics</li>
          </ul>
          <h2>OMIM Statistics</h2>
        </div>
      </div>
    </div>
  </div>
</section>


<section id="content">
<div class="container">

<p class='text-info'>OMIM database last updated <b>[%date%]</b></p>

<h3>Overall OMIM data</h3>
<p>Total number of OMIM entries with allelic variant records: [% n_omim_total %]</p>
<p>Total number of mutations listed in OMIM: [% n_mutant_total %]</p>
<p>Number of OMIM entries cross-linked from SwissProt: [% n_omim %] ([% n_omim_perc %]%)<br />
This represents [% n_mutant %] mutations ([% n_mutant_perc %]%)</p>

<h3>Of the OMIM entries linked to SwissProt:</h3>
<table class='table table-striped'>
<tr>
   <td>Validated (Class A) mutations:</td>
   <td>[% n_class_a %] ([% n_class_a_perc %]%)</td>
   <td>from [% n_omim_class_a %] ([% n_omim_class_a_perc %]%) OMIM entries</td>
</tr>
<tr>
   <td>Probable (Class B) mutations:</td>
   <td>[% n_class_b %] ([% n_class_b_perc %]%)</td>
   <td>from [% n_omim_class_b %] ([% n_omim_class_b_perc %]%) OMIM entries</td>
</tr>
<tr>
   <td>Unidentified (Class C) mutations:</td>
   <td>[% n_class_c %] ([% n_class_c_perc %]%)</td>
   <td>from [% n_omim_class_c %] ([% n_omim_class_c_perc %]%) OMIM entries</td>
</tr>
</table>

<p>[% n_offset %] mutations ([% n_offset_perc %]%) required an offset to be applied.<br /> 
These came from [% n_omim_offset %] OMIM entries ([% n_omim_offset_perc %]%).</p>

<p>In total, [% n_omim_error %] OMIM entries linked to SwissProt ([% n_omim_error_perc %]%) 
contain errors or inconsistencies.</p>

    <p>
      <a href='./' class='btn btn-large
         btn-info'><i class='icon-reply'></i> Back
      </a>
    </p>

    <div class='row'>
      <div class='blankline20'></div>
    </div>

</div>
</section>

[% INCLUDE "footer.tt" %]

