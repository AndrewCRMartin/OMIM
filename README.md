OMIM
====

(c) UCL, Prof Andrew C.R. Martin, 2004-2023
-------------------------------------------

A series of programs to parse the old OMIM dump file, create a
relational database containing the data and then perform a mapping
of mutation residue numbers in OMIM to residue numbers in the
associated SwissProt entries.

Note that the OMIM data have not been distributed in this format since
2011 and downloading of the newer data requires reguistration at
https://www.omim.org/downloads/
To share the data you then need to purchase a licence.

All you should have to run to build and populate the database is:

1. Create a `config.sh` file based on the contents of `config.sh.tpl`
2. Run `./setup.sh` if this is the first time of use
3. Run the `build.sh` script.


```
build.sh - main shell script to run the required programs:
   parseomim.pl      - Grab mutations from OMIM into the database
   ProcessSProt.pl   - Grab OMIM links from SwissProt
   indexfasta.pl     - Index FASTA for rapid lookup
   wrapvalidate.pl   - Validate each entry in the database by calling:
      validate.pl    - Validates the residue numbers of an entry
   update_resnums.pl - Updates the residue numbers in the database
   setdate.pl        - Puts the date in a file
getfasta.pl - Utility to grab a FASTA entry from the indexed file
getomim.pl  - Utility to grab a mutation set from the database
```

There is also a `www` directory containing HTML and CGI scripts to
access the database via a web page. **See note above about
restrictions on doing this with new data**

```
ACRMPerlVars.pm - config file which you will need to update
omim.pl         - CGI script to access database
stats.pl        - CGI script to access stats from database
```


The programs work as follows:


### parseomim.pl

`*RECORD*` marks the start of each record which is split into `*FIELD*`s
The `*FIELD*` keyword is followed by a type. These data are stored
for a record at a time. The accession is extracted from the NO `*FIELD*`
and the mutation data are extracted from the AV `*FIELD*`s

The mutation data are validated (i.e. mutated from a valid AA to a 
valid AA - not DEL, INS, etc.) and written as tab-delimited data for 
loading into the `omim_mutant` d/b table

At the same time, the descriptions are stored into a separate hash.
After the omim_mutant data have been written, the `omim_descriptions`
table is also written as tab-delimited data.


### ProcessSProt.pl

This runs through the SwissProt file. For each record, the ID, set
of ACs, the date (DT), sequence and DR (database crosslinks) fields
are extracted. From DR, the PDB and OMIM cross references are stored.
The results are simply dumped as a tab-delimited data table in the
form of AC/OMIM tuples which are loaded into the `swsomim` table.

Currently this is done only for the primary accession. It might be
a good idea to do it for all accessions?

N.B. Since `sws_mutant` and `sws_omim_mutant` are VIEWs on `swsomim` 
and `omim_mutant`, they will be populated at this stage.

### indexfasta.pl  

This simply creates a DBM hash with offsets to each entry in the
FASTA version of SwissProt using the accession as the key.
You can then obtain a given FASTA entry using getfasta.pl

### wrapvalidate.pl

### validate.pl    

### update_resnums.pl

### setdate.pl     

### getfasta.pl

### getomim.pl 

