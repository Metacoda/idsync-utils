# SAS Macro: %metacodaExtIdUpdate

## WARNING

WARNING: THIS MACRO UPDATES SAS METADATA.
   
When provided with correct parameters, and running in an environment with valid SAS metadata
options, this macro will update SAS metadata ExternalIdentity objects which may break any existing
identity sync process you current have operating, and has the potential to DELETE users and group
at the next sync operation unless you have delete-protection in your sync process.
   
Do not modify and run this program unless it is your intention to update ExternalIdentity metadata,
you are fully aware of the potential consequences, and are confident you have adequate SAS metadata
backups so you can revert the process if required.
    
If you are unsure please contact Metacoda Support [support@metacoda.com](mailto:support@metacoda.com)
to discuss further.

## Purpose

This macro is used to update basic attribute values for existing ExternalIdentity objects from SAS
metadata.

ExternalIdentity objects are used to maintain unique identifiers in metadata that link SAS
identities to external identities (such as Microsoft Active Directory users & groups).

The metacodaExtIdUpdate macro can be used as part of a process to perform a bulk update of keyId
values if you want to migrate the type of unique identifier you are using for identity sync.
For example you might want to switch from using sAMAccountName to objectGUID for users, and switch
from using distinguishedName to objectGUID. By switching to objectGUID we can take advantage of a
better choice for an unchanging unique id for objects in Active Directory.

The macro takes a table of ExternalIdentity metadata object ids and new identifier (keyId) values
and applies those new values to SAS metadata.

## Parameters

    %macro metacodaExtIdUpdate(
       table=,
       extIdObjIdColName=,
       extIdNewIdentifierColName=,
       xmlDir=,
       debug=0
       );

This macro accepts several mandatory and optional named parameters to identify a SAS table and
columns as input and used SAS PROC METADATA to update metadata according to the table contents. 

***table***: _(MANDATORY)_
 
The (1 or 2 level) name of an input table containing the ExternalIdentity Identifier values to
update.

***extIdObjIdColName***: _(MANDATORY)_

The name of the column in the supplied table that contains the metadata object id values for the
ExternalIdentity objects to be updated.

***extIdNewIdentifierColName***: _(MANDATORY)_

The name of the column in the supplied table that contains the new ExternalIdentity Identifier
values.

***xmlDir***: _(OPTIONAL)_

Path to a directory where PROC METADATA request and response XML files will be written. If
unspecified the work directory path will be used by default.

***debug***: _(OPTIONAL)_
 
A flag (0/1) indicating whether to generate additional debug info for troubleshooting purposes.
The default is zero for no debug.

## Examples

Update ExternalIdentity Identifier (keyId) values for AD-synced users:

    %metacodaExtIdUpdate(
        table=work.userExtIdUpdate,
        extIdObjIdColName=extIdObjId,
        extIdNewIdentifierColName=extIdNewIdentifier
        );

Update ExternalIdentity Identifier (keyId) values for AD-synced groups:

    %metacodaExtIdUpdate(
        table=groupExtIdUpdate,
        extIdObjIdColName=extIdObjId,
        extIdNewIdentifierColName=extIdNewIdentifier
        );

See the sample [metacodaExtIdUpdateSample.sas](https://github.com/Metacoda/idsync-utils/blob/master/samples/metacodaExtIdUpdateSample.sas) for a more
in-depth example of how a keyId migration can be done with the help of the Metacoda Identity Sync
Plug-in.