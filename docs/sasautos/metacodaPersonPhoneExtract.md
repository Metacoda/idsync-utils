# SAS Macro: %metacodaPersonPhoneExtract

## Purpose

This macro is used to extract basic attribute values for SAS metadata Phone (number)
objects that are associated with Person (user) objects.

## Parameters

    %macro metacodaPersonPhoneExtract(
       table=,
       xmlDir=,
       debug=0
       );

This macro accepts several mandatory and optional named parameters and generates a SAS table
as output.

***table***: _(MANDATORY)_

The output table name (1 or 2 level) that will be overwritten.

***xmlDir***: _(OPTIONAL)_
 
Path to a directory where PROC METADATA request, response, and map XML files will be written.
If unspecified the work directory path will be used by default.

***debug***: _(OPTIONAL)_

A flag (0/1) indicating whether to generate additional debug info for troubleshooting purposes.
The default is zero for no debug.

## Examples

Extract basic metadata attributes for all users:
 
    %metacodaPersonPhoneExtract(table=work.personPhones);

For more examples see [metacodaPersonPhoneExtractSample.sas](https://github.com/Metacoda/idsync-utils/blob/master/samples/metacodaPersonPhoneExtractSample.sas).