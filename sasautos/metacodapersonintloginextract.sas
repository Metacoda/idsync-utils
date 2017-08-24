/*
--------------------------------------------------------------------------------

SAS Macro: metacodaPersonIntLoginExtract

Purpose:
   Extracts a table of basic attribute values for SAS metadata InternalLogin (account)
   objects that are associated with Person (user) objects.

Documentation:
    https://metacoda.github.io/idsync-utils/sasautos/metacodaPersonIntLoginExtract

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

%macro metacodaPersonIntLoginExtract(
   table=,
   xmlDir=,
   debug=0
   );

%* validate the table parameter as mandatory/non-blank;
%if %sysevalf(%superq(table)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory table parameter was not specified.;
   %return;
%end;

%if %sysevalf(&SYSVER<=9.2,boolean) %then %do;
   %put %str(ERR)OR: This macro can only be used with SAS 9.3 and above.;
   %return;
%end;

%local xmlDirPath;
%if %sysevalf(%superq(xmlDir)=,boolean) %then %let xmlDirPath=%sysfunc(pathname(work));
%else %let xmlDirPath=&xmlDir;
%put NOTE: Using PROC METADATA XML request/response/map dir: &xmlDirPath;

filename _omireq "&xmlDirPath/metacodaPersonIntLoginExtract-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacodaPersonIntLoginExtract-response.xml" lrecl=32767 encoding="utf-8";
filename _omimap "&xmlDirPath/metacodaPersonIntLoginExtract-map.xml" lrecl=1024 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>InternalLogin</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
put '  <Flags>67109252</Flags>'; %* OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_XMLSELECT(128) + OMI_TEMPLATE(4);
put '  <Options>';
put '    <Templates>';
put '      <InternalLogin Id="" Name="" Desc="" MetadataCreated="" MetadataUpdated=""';
put '          AccountExpirationDate="" BypassHistory="" BypassInactivitySuspension=""';
put '          BypassLockout="" BypassStrength="" ExpirationDays="" FailureCount="" IsDisabled=""';
put '          LockoutTimestamp="" LoginTimestamp="" PasswordTimestamp="" UseStdExpirationDays=""';
put '          >';
put '        <ForIdentity/>';
put '      </InternalLogin>';
put '      <Person Id="" Name=""/>';
put '    </Templates>';
put '    <XMLSELECT search="InternalLogin[ForIdentity/Person]"/>';
put '  </Options>';
put '</GetMetadataObjects>';
run;

%if &debug ne 0 %then %do;
   %put DEBUG: START PROC METADATA REQUEST >>>;
   data _null_;
   infile _omireq truncover;
   length line $32767;
   input line $char.;
   l=length(line);
   put line $varying. l;
   run;
   %put DEBUG: <<< END PROC METADATA REQUEST;
%end;

proc metadata in=_omireq out=_omires header=full
    %if &debug ne 0 %then %do; verbose %end;
;
run;

%if (&syserr ne 0 and &syserr ne 4) %then %do;
    %put %str(ERR)OR: Metadata Identity Login extract failed.;
    %goto CLEANUP;
%end;

%if &debug ne 0 %then %do;
   %put DEBUG: START PROC METADATA RESPONSE >>>;
   data _null_;
   infile _omires truncover;
   length line $32767;
   input line $char.;
   l=length(line);
   put line $varying. l;
   run;
   %put DEBUG: <<< END PROC METADATA RESPONSE;
%end;

data _null_;
file _omimap;
put '<?xml version="1.0" encoding="utf-8" ?>';
put '<SXLEMAP version="1.2" name="InternalLogins">';
put '  <TABLE name="InternalLogins">';
put '    <TABLE-PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin</TABLE-PATH>';
put '    <COLUMN name="objId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="name">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="desc">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@Desc</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>800</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="metadataCreatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@MetadataCreated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="metadataUpdatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@MetadataUpdated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="accountExpirationDateUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@AccountExpirationDate</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="bypassHistory">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@BypassHistory</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="bypassInactivitySuspension">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@BypassInactivitySuspension</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="bypassLockout">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@BypassLockout</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="bypassStrength">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@BypassStrength</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="expirationDays">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@ExpirationDays</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="failureCount">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@FailureCount</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="isDisabled">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@IsDisabled</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="lockoutTimestampUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@LockoutTimestamp</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="loginTimestampUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@LoginTimestamp</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="passwordTimestampUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@PasswordTimestamp</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="useStdExpirationDays">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/@UseStdExpirationDays</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="personObjId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/ForIdentity/Person/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="personName">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/InternalLogin/ForIdentity/Person/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '  </TABLE>';
put '</SXLEMAP>';
run;

libname _omilib xml xmlfileref=_omires xmlmap=_omimap access=readonly;

data &table;
set _omilib.InternalLogins;
%* The SAS Metadata Server seems to return 0 to indicate missing date/times;
if accountExpirationDateUTC=0 then accountExpirationDateUTC=.;
if lockoutTimestampUTC=0 then lockoutTimestampUTC=.;
if loginTimestampUTC=0 then loginTimestampUTC=.;
if passwordTimestampUTC=0 then passwordTimestampUTC=.;
%* derive the internal login userId from the person name and the fixed suffix @saspw; 
length userId $245;
userId=cats(personName,'@saspw');
run;

%CLEANUP:
libname _omilib;
filename _omimap;
filename _omires;
filename _omireq;

%mend;