#!/bin/bash

function CheckFile
{
    if [ ! -f $1 ]; then
        echo "You must download and provide file: $1";
        export error=TRUE
    fi

    if [ "X$2" == "Xdie" ] && [ "X$error" == "XTRUE" ]; then
        echo "Program exiting"
        exit
    fi
}

function MakeDir
{
    if [ ! -d $1 ]; then
        mkdir $1
    fi

    if [ ! -d $1 ]; then
        echo "Could not create directory: $1"
        echo "You must create this directory with root priviledges"
        exit
    fi
}

CheckFile ./config.sh die
. ./config.sh

MakeDir $omimdatadir
MakeDir $tmpdir

#createdb -h$dbhost $dbname

if [ "X$makeweb" == "XTRUE" ]; then
    MakeDir $htmldir
    MakeDir $cgidir
fi


CheckFile $sprot
CheckFile $fasta


