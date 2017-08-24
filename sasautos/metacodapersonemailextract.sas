/*
--------------------------------------------------------------------------------

SAS Macro: metacodaPersonEmailExtract

Purpose:
   Extracts a table of basic attribute values for SAS metadata Email (address)
   objects that are associated with Person (user) objects.

Documentation:
    https://metacoda.github.io/idsync-utils/sasautos/metacodaPersonEmailExtract

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

%macro metacodaPersonEmailExtract(
   table=,
   xmlDir=,
   debug=0
   );

%* validate the table parameter as mandatory/non-blank;
%if %sysevalf(%superq(table)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory table parameter was not specified.;
   %return;
%end;

%local xmlDirPath;
%if %sysevalf(%superq(xmlDir)=,boolean) %then %let xmlDirPath=%sysfunc(pathname(work));
%else %let xmlDirPath=&xmlDir;
%put NOTE: Using PROC METADATA XML request/response/map dir: &xmlDirPath;

filename _omireq "&xmlDirPath/metacodaPersonEmailExtract-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacodaPersonEmailExtract-response.xml" lrecl=32767 encoding="utf-8";
filename _omimap "&xmlDirPath/metacodaPersonEmailExtract-map.xml" lrecl=1024 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>Email</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
put '  <Flags>67109252</Flags>'; %* OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_XMLSELECT(128) + OMI_TEMPLATE(4);
put '  <Options>';
put '    <Templates>';
put '      <Email Id="" Name="" Desc="" MetadataCreated="" MetadataUpdated="" PublicType="" EmailType="" Address="">';
put '        <Persons/>';
put '      </Email>';
put '      <Person Id="" Name=""/>';
put '    </Templates>';
put '    <XMLSELECT search="Email[Persons/Person]"/>';
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
    %put %str(ERR)OR: Metadata Person Email extract failed.;
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
put '<SXLEMAP version="1.2" name="PersonEmails">';
put '  <TABLE name="personEmails">';
put '    <TABLE-PATH syntax="XPath">/GetMetadataObjects/Objects/Email</TABLE-PATH>';
put '    <COLUMN name="objId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="name">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="desc">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@Desc</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>800</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="metadataCreatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@MetadataCreated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="metadataUpdatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@MetadataUpdated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
%* Whilst Email is a PrimaryType, and so has PublicType, in practice it never seems to be populated; 
%*put '    <COLUMN name="publicType">';
%*put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@PublicType</PATH>';
%*put '      <TYPE>character</TYPE>';
%*put '      <DATATYPE>string</DATATYPE>';
%*put '      <LENGTH>240</LENGTH>';
%*put '    </COLUMN>';
put '    <COLUMN name="EmailType">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@EmailType</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>128</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="address">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/@Address</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>1024</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="personObjId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/Persons/Person/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="personName">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Email/Persons/Person/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '  </TABLE>';
put '</SXLEMAP>';
run;

libname _omilib xml xmlfileref=_omires xmlmap=_omimap access=readonly;

data &table;
set _omilib.personEmails;
run;

%CLEANUP:
libname _omilib;
filename _omimap;
filename _omires;
filename _omireq;

%mend;