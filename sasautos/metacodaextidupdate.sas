/*
--------------------------------------------------------------------------------

SAS Macro: metacodaExtIdUpdate

WARNING: THIS MACRO UPDATES SAS METADATA.
   
    When provided with correct parameters, and running in an environment with
    valid SAS metadata options, this macro will update SAS metadata
    ExternalIdentity objects which may break any existing identity sync process
    you current have operating, and has the potential to DELETE users and group
    at the next sync operation unless you have delete-protection in your sync
    process.
       
    Do not modify and run this program unless it is your intention to update
    ExternalIdentity metadata, you are fully aware of the potential consequences,
    and are confident you have adequate SAS metadata backups so you can revert
    the process if required.
        
    If you are unsure please contact Metacoda Support <support@metacoda.com>
    to discuss further.

Purpose:
   Updates ExternalIdentity metadata object Identifier attribute values with new values
   obtained from a supplied SAS table.
   
   Can be used as a one-off exercise to change identity sync keyId values e.g.
   1) Migrating from sAMAccountName to objectGUID for users (metadata Person objects)
   2) Migrating from distinguishedName to objectGUID for groups (metadata IdentityGroup objects)

Parameters:
   table: [MANDATORY] The (1 or 2 level) name of an input table containing the ExternalIdentity
      Identifier values to update.
   extIdObjIdColName: [MANDATORY] The name of the column in the supplied table that contains the
      metadata object id values for the ExternalIdentity objects to be updated.
   extIdNewIdentifierColName: [MANDATORY] The name of the column in the supplied table that
      contains the new ExternalIdentity Identifier values.
   xmlDir: [OPTIONAL] Path to a directory where PROC METADATA request and response XML files
      will be written. If unspecified the work directory path will be used by default.
   debug: [OPTIONAL] A flag (0/1) indicating whether to generate additional debug info for
      troubleshooting purposes. The default is zero for no debug.

Authors:
   Paul Homes <paul.homes@metacoda.com>

--------------------------------------------------------------------------------

Copyright 2017 Metacoda Pty Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--------------------------------------------------------------------------------
*/

%macro metacodaExtIdUpdate(
   table=,
   extIdObjIdColName=,
   extIdNewIdentifierColName=,
   xmlDir=,
   debug=0
   );

%* validate the table parameter as mandatory/non-blank;
%if %sysevalf(%superq(table)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory table parameter was not specified.;
   %return;
%end;

%* validate the table parameter contains an existing table;
%if not(%eval(%sysfunc(exist(&table)))) %then %do;
   %put %str(ERR)OR: The mandatory ExternalIdentity update data table "&TABLE" was not found.;
   %return;
%end;

%* validate the extIdObjIdColName parameter as mandatory/non-blank;
%if %sysevalf(%superq(extIdObjIdColName)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory extIdObjIdColName parameter was not specified.;
   %return;
%end;

%* validate the extIdNewIdentifierColName parameter as as mandatory/non-blank;
%if %sysevalf(%superq(extIdNewIdentifierColName)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory extIdNewIdentifierColName parameter was not specified.;
   %return;
%end;

%local xmlDirPath;
%if %sysevalf(%superq(xmlDir)=,boolean) %then %let xmlDirPath=%sysfunc(pathname(work));
%else %let xmlDirPath=&xmlDir;
%put NOTE: Using PROC METADATA XML request/response/map dir: &xmlDirPath;

filename _omireq "&xmlDirPath/metacodaExtIdUpdate-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacodaExtIdUpdate-response.xml" lrecl=32767 encoding="utf-8";

data _null_;
file _omireq;
put '<UpdateMetadata>';
put '  <Metadata>';
run;

data _null_;
length line $32767;
set &table;
file _omireq mod;
line = '<ExternalIdentity Id="' || trim(left(%metacodaXMLEncode(&extIdObjIdColName))) || '"'
   || ' Identifier="' || trim(left(%metacodaXMLEncode(&extIdNewIdentifierColName))) || '"'
   || '/>';
put '    ' line;
run;

data _null_;
file _omireq mod;
put '  </Metadata>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <NS>SAS</NS>';
put '  <Flags>268435456</Flags>'; * OMI_TRUSTED_CLIENT(268435456);
put '  <Options/>';
put '</UpdateMetadata>';
run;

%if &debug ne 0 %then %do;
   %put DEBUG: START PROC METADATA REQUEST >>>;
   data _null_;
   infile _omireq missover;
   input;
   put _infile_;
   run;
   %put DEBUG: <<< END PROC METADATA REQUEST;
%end;

proc metadata in=_omireq out=_omires header=full
    %if &debug ne 0 %then %do; verbose %end;
;
run;

%if (&syserr ne 0 and &syserr ne 4) %then %do;
    %put %str(ERR)OR: Metadata ExternalIdentity update failed.;
    %goto CLEANUP;
%end;

%if &debug ne 0 %then %do;
   %put DEBUG: START PROC METADATA RESPONSE >>>;
   data _null_;
   infile _omires missover;
   input;
   put _infile_;
   run;
   %put DEBUG: <<< END PROC METADATA RESPONSE;
%end;

%CLEANUP:
filename _omires;
filename _omireq;

%mend;