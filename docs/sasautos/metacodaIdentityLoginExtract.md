# SAS Macro: %metacodaIdentityLoginExtract

## Purpose

This macro is used to extract basic attribute values for SAS metadata Login (account)
objects that are associated with Identity (user and/or group) objects.

## Parameters

    %macro metacodaIdentityLoginExtract(
       table=,
       identityType=,
       append=0,
       xmlDir=,
       debug=0
       );

This macro accepts several mandatory and optional named parameters and generates a SAS table
as output.

***table***: _(MANDATORY)_

The output table name (1 or 2 level) that will be overwritten (or appended to).

***identityType***: _(OPTIONAL)_

The SAS metadata model type for the type of identity whose Logins will be extracted.
The value must be either blank, Person, or IdentityGroup.
If the value is blank then Logins for both Person (user) and IdentityGroup (group) types will be
extracted. The default is blank.

***append***: _(OPTIONAL)_

A flag (0/1) indicating whether to overwrite or append to the specified table.
The default is zero to overwrite.
This parameter is ignored when the identityType parameter is blank (and the table will be
overwritten).

***xmlDir***: _(OPTIONAL)_
 
Path to a directory where PROC METADATA request, response, and map XML files will be written.
If unspecified the work directory path will be used by default.

***debug***: _(OPTIONAL)_

A flag (0/1) indicating whether to generate additional debug info for troubleshooting purposes.
The default is zero for no debug.

## Examples

Extract login metadata for all users and groups:
 
    %metacodaIdentityLoginExtract(table=work.identityLogins)

For more examples see [metacodaIdentityLoginExtractSample.sas](https://github.com/Metacoda/idsync-utils/blob/master/samples/metacodaIdentityLoginExtractSample.sas).