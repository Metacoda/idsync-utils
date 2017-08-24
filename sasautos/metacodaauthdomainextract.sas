/*
--------------------------------------------------------------------------------

SAS Macro: metacodaAuthDomainExtract

Purpose:
   Extracts a table of basic attribute values for SAS metadata AuthenticationDomain
   objects.

Documentation:
    https://metacoda.github.io/idsync-utils/sasautos/metacodaAuthDomainExtract

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

%macro metacodaAuthDomainExtract(
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

filename _omireq "&xmlDirPath/metacodaAuthDomainExtract-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacodaAuthDomainExtract-response.xml" lrecl=32767 encoding="utf-8";
filename _omimap "&xmlDirPath/metacodaAuthDomainExtract-map.xml" lrecl=1024 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>AuthenticationDomain</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
%* SAS Management Console 9.4 lets you create an AuthenticationDomain object in a custom repository
   (albeit with a warning), but will not let you create one in a project repository. We therefore
   look for AuthenticationDomain objects in both foundation and custom repositories.
   OMI_NOFORMAT (67108864) + OMI_DEPENDENCY_USES (8192) + OMI_GET_METADATA(256) + OMI_TEMPLATE(4)
   ;
put '  <Flags>67117316</Flags>';
put '  <Options>';
put '    <Templates>';
put '      <AuthenticationDomain Id="" Name="" Desc="" MetadataCreated="" MetadataUpdated="" PublicType=""';
%* OutboundOnly and TrustedOnly were added in 9.4M2. This template will also work with earlier
   versions such as SAS 9.2, 9.3, 9.4 M0, and 9.4 M1, we just wont get values back and the columns
   will be missing;
put '         OutboundOnly="" TrustedOnly=""';
put '         />';
put '    </Templates>';
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
    %put %str(ERR)OR: Metadata AuthenticationDomain extract failed.;
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
put '<SXLEMAP version="1.2" name="AuthDomains">';
put '  <TABLE name="authDomains">';
put '    <TABLE-PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain</TABLE-PATH>';
put '    <COLUMN name="objId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="name">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="desc">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@Desc</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>800</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="metadataCreatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@MetadataCreated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="metadataUpdatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@MetadataUpdated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="publicType">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@PublicType</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="outboundOnly">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@OutboundOnly</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="trustedOnly">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/AuthenticationDomain/@TrustedOnly</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>integer</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '    </COLUMN>';
put '  </TABLE>';
put '</SXLEMAP>';
run;

libname _omilib xml xmlfileref=_omires xmlmap=_omimap access=readonly;

data &table;
set _omilib.authDomains;
run;

%CLEANUP:
libname _omilib;
filename _omimap;
filename _omires;
filename _omireq;

%mend;