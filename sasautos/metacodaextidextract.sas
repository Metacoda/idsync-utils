/*
--------------------------------------------------------------------------------

SAS Macro: metacodaExtIdExtract

Purpose:
   Extracts a table of basic attribute values for SAS metadata ExternalIdentity objects.

Documentation:
    https://metacoda.github.io/idsync-utils/sasautos/metacodaExtIdExtract

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

%macro metacodaExtIdExtract(
   table=,
   context=,
   associatedModelType=,
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

filename _omireq "&xmlDirPath/metacodaExtIdExtract-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacodaExtIdExtract-response.xml" lrecl=32767 encoding="utf-8";
filename _omimap "&xmlDirPath/metacodaExtIdExtract-map.xml" lrecl=1024 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>ExternalIdentity</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
put '  <Flags>67109252</Flags>'; %* OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_XMLSELECT(128) + OMI_TEMPLATE(4);
put '  <Options>';
put '    <Templates>';
put '      <ExternalIdentity Id="" Name="" MetadataCreated="" MetadataUpdated="" Context="" Identifier="" ImportType="">';
put '        <OwningObject/>';
put '      </ExternalIdentity>';
put '      <Person Id="" PublicType="" Name=""/>';
put '      <IdentityGroup Id="" PublicType="" Name=""/>';
put '    </Templates>';
length xmlSelect $200;
xmlSelect = '';
%if %sysevalf(%superq(context) ne,boolean) %then %do;
   xmlSelect=cats(xmlSelect, "[@Context='&context']");
%end;
%if %sysevalf(%superq(associatedModelType) ne,boolean) %then %do;
   xmlSelect=cats(xmlSelect, "[OwningObject/&associatedModelType]");
%end;
if xmlSelect ne '' then do;
   xmlSelect=cats('<XMLSELECT search="ExternalIdentity', xmlSelect, '"/>');
   put '    ' xmlSelect;
end;
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
    %put %str(ERR)OR: Metadata ExternalIdentity extract failed.;
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
put '<SXLEMAP version="1.2" name="ExternalIdentities">';
put '  <TABLE name="externalIdentities">';
put '    <TABLE-PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity</TABLE-PATH>';
put '    <COLUMN name="objId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>17</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="name">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>60</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="metadataCreatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@MetadataCreated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="metadataUpdatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@MetadataUpdated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="context">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@Context</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>32</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="identifier">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@Identifier</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>128</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="importType">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/ExternalIdentity/@ImportType</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>32</LENGTH>';
put '    </COLUMN>';
%if %sysevalf(%superq(associatedModelType) ne ,boolean) %then %do;
    put '    <COLUMN name="ownerObjId">';
    put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/ExternalIdentity/OwningObject/&associatedModelType/@Id</PATH>";
    put '      <TYPE>character</TYPE>';
    put '      <DATATYPE>string</DATATYPE>';
    put '      <LENGTH>17</LENGTH>';
    put '    </COLUMN>';
    put '    <COLUMN name="ownerType">';
    put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/ExternalIdentity/OwningObject/&associatedModelType/@ConstantPlaceHolder</PATH>";
    put '      <TYPE>character</TYPE>';
    put '      <DATATYPE>string</DATATYPE>';
    put "      <DEFAULT>&associatedModelType</DEFAULT>";
    put '      <LENGTH>13</LENGTH>';
    put '    </COLUMN>';
    put '    <COLUMN name="ownerPublicType">';
    put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/ExternalIdentity/OwningObject/&associatedModelType/@PublicType</PATH>";
    put '      <TYPE>character</TYPE>';
    put '      <DATATYPE>string</DATATYPE>';
    put '      <LENGTH>60</LENGTH>';
    put '    </COLUMN>';
    put '    <COLUMN name="ownerName">';
    put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/ExternalIdentity/OwningObject/&associatedModelType/@Name</PATH>";
    put '      <TYPE>character</TYPE>';
    put '      <DATATYPE>string</DATATYPE>';
    put '      <LENGTH>60</LENGTH>';
    put '    </COLUMN>';
%end;
put '  </TABLE>';
put '</SXLEMAP>';
run;

libname _omilib xml xmlfileref=_omires xmlmap=_omimap access=readonly;

data &table;
set _omilib.externalIdentities;
run;

%CLEANUP:
libname _omilib;
filename _omimap;
filename _omires;
filename _omireq;

%mend;