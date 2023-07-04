#!/usr/bin/perl

my($s,$m,$h,$d,$mon,$y,$wd,$yd,$isdst) = localtime(time);
my($themon) = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[$mon];
$y+=1900;
print "$d-$themon-$y\n";
