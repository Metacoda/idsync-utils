# SAS Macro: %metacodaExtIdExtract

## Purpose

This macro is used to extract basic attribute values for ExternalIdentity objects from SAS metadata.
ExternalIdentity objects are created during identity synchronisation with external identity sources
such as Microsoft Active Directory. They contain the 3rd party keys for those external users and
groups that allow us to re-locate those external identities when a subsequent sync is done, ideally
even when the external users and groups are renamed or moved into another part of the directory.

## Parameters

    %macro metacodaExtIdExtract(
       table=,
       context=,
       associatedModelType=,
       xmlDir=,
       debug=0
       );

This macro accepts several mandatory and optional named parameters and generates a SAS table
as output.

***table***: _(MANDATORY)_

The output table name (1 or 2 level) that will be overwritten.

***context***: _(OPTIONAL)_
    
If specified, will limit the output to ExternalIdentity objects with the specified Context
attribute value. e.g. Active Directory Import

***associatedModelType***: _(OPTIONAL)_
    
If specified, will limit the output to ExternalIdentity objects that are associated with metadata
objects of the specified model type. e.g. Person or IdentityGroup

***xmlDir***: _(OPTIONAL)_
 
Path to a directory where PROC METADATA request, response, and map XML files will be written.
If unspecified the work directory path will be used by default.

***debug***: _(OPTIONAL)_

A flag (0/1) indicating whether to generate additional debug info for troubleshooting purposes.
The default is zero for no debug.

## Examples

Extract external identity metadata for all AD-synced users:
 
    %metacodaExtIdExtract(
        table=work.adUserExtIds,
        context=Active Directory Import,
        associatedModelType=Person
        )

Extract external identity metadata for all AD-synced groups:
 
    %metacodaExtIdExtract(
        table=work.adGroupExtIds,
        context=Active Directory Import,
        associatedModelType=IdentityGroup
        )

For more examples see [metacodaExtIdExtractSample.sas](https://github.com/Metacoda/idsync-utils/blob/master/samples/metacodaExtIdExtractSample.sas).