# SAS Macro: %metacodaIdGroupMembersExtract

## Purpose

This macro is used to extract member information for SAS IdentityGroup (group and role)
objects. It can be used to extract Person (user) members, nested IdentityGroup (group and role)
members, or both combined.

If you have any role contributions in your SAS environment then you will also see these as roles
being members of other roles.

## Parameters

    %macro metacodaIdGroupMembersExtract(
       table=,
       memberType=,
       append=0,
       xmlDir=,
       debug=0
       );

This macro accepts several mandatory and optional named parameters and generates a SAS table
as output.

***table***: _(MANDATORY)_

The output table name (1 or 2 level) that will be overwritten (or appended to).

***memberType***: _(OPTIONAL)_

The SAS metadata model type for the type of member identities that will be extracted.
The value must be either blank, Person, or IdentityGroup.
If the value is blank then both Person (user) and IdentityGroup (group and role) members
will be extracted. The default is blank.

***append***: _(OPTIONAL)_

A flag (0/1) indicating whether to overwrite or append to the specified table.
The default is zero to overwrite.
This parameter is ignored when the memberType parameter is blank (and the table will be
overwritten).

***xmlDir***: _(OPTIONAL)_
 
Path to a directory where PROC METADATA request, response, and map XML files will be written.
If unspecified the work directory path will be used by default.

***debug***: _(OPTIONAL)_

A flag (0/1) indicating whether to generate additional debug info for troubleshooting purposes.
The default is zero for no debug.

## Examples

Extract all member metadata for all groups and roles:
 
    %metacodaIdGroupMembersExtract(table=work.idGroupMembers)

For more examples see [metacodaIdGroupMembersExtractSample.sas](https://github.com/Metacoda/idsync-utils/blob/master/samples/metacodaIdGroupMembersExtractSample.sas).