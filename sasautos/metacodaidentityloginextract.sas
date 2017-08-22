/*
--------------------------------------------------------------------------------

SAS Macro: metacodaIdentityLoginExtract

Purpose:
   Extracts a table of basic attribute values for SAS metadata Login (account)
   objects that are associated with Identity (user and group) objects.

Documentation:
    https://metacoda.github.io/idsync-utils/sasautos/metacodaIdentityLoginExtract

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

%macro metacodaIdentityLoginExtract(
   table=,
   identityType=,
   append=0,
   xmlDir=,
   debug=0
   );

%* validate the table parameter as mandatory/non-blank;
%if %sysevalf(%superq(table)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory table parameter was not specified.;
   %return;
%end;

%* A blank identityType indicates both Person and IdentityGroup logins are required;
%if %sysevalf(%superq(identityType)=,boolean) %then %do;
   %metacodaIdentityLoginExtract(table=&table, identityType=Person, append=0, xmlDir=&xmlDir, debug=&debug)
   %metacodaIdentityLoginExtract(table=&table, identityType=IdentityGroup, append=1, xmlDir=&xmlDir, debug=&debug)
   %return;
%end;

%if &identityType ne Person and &identityType ne IdentityGroup %then %do;
   %put %str(ERR)OR: The identityType parameter must be Person or IdentityGroup;
   %return;
%end;

%local xmlDirPath;
%if %sysevalf(%superq(xmlDir)=,boolean) %then %let xmlDirPath=%sysfunc(pathname(work));
%else %let xmlDirPath=&xmlDir;
%put NOTE: Using PROC METADATA XML request/response/map dir: &xmlDirPath;

filename _omireq "&xmlDirPath/metacoda&identityType.LoginExtract-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacoda&identityType.LoginExtract-response.xml" lrecl=32767 encoding="utf-8";
filename _omimap "&xmlDirPath/metacoda&identityType.LoginExtract-map.xml" lrecl=1024 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>Login</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
put '  <Flags>67109252</Flags>'; * OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_XMLSELECT(128) + OMI_TEMPLATE(4);
put '  <Options>';
put '    <Templates>';
* Login changed parent to PrimaryType in SAS 9.3 and so gained PublicType attribute - ignored for now; 
put '      <Login Id="" Name="" Desc="" MetadataCreated="" MetadataUpdated="" UserId="" Password="">';
put '        <Domain/>';
put '        <AssociatedIdentity/>';
put '      </Login>';
put "      <&identityType Id="""" PublicType="""" Name=""""/>";
put '      <AuthenticationDomain Id="" Name=""/>';
put '    </Templates>';
put "    <XMLSELECT search=""Login[AssociatedIdentity/&identityType]""/>";
put '  </Options>';
put '</GetMetadataObjects>';
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
    %put %str(ERR)OR: Metadata Identity Login extract failed.;
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

data _null_;
file _omimap;
put '<?xml version="1.0" encoding="utf-8" ?>';
put '<SXLEMAP version="1.2" name="IdentityLogins">';
put '  <TABLE name="IdentityLogins">';
put '    <TABLE-PATH syntax="XPath">/GetMetadataObjects/Objects/Login</TABLE-PATH>';
put '    <COLUMN name="objId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="name">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="desc">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@Desc</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>800</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="metadataCreatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@MetadataCreated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="metadataUpdatedUTC">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@MetadataUpdated</PATH>';
put '      <TYPE>numeric</TYPE>';
put '      <DATATYPE>double</DATATYPE>';
put '      <LENGTH>8</LENGTH>';
put '      <INFORMAT width="32" ndec="2">best</INFORMAT>';
put '      <FORMAT>e8601dt</FORMAT>';
put '    </COLUMN>';
put '    <COLUMN name="userId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@UserID</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>512</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="password">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/@Password</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>512</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="authDomainObjId">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/Domain/AuthenticationDomain/@Id</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="authDomainName">';
put '      <PATH syntax="XPath">/GetMetadataObjects/Objects/Login/Domain/AuthenticationDomain/@Name</PATH>';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="identityObjId">';
put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/Login/AssociatedIdentity/&identityType/@Id</PATH>";
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="identityType">';
put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/Login/AssociatedIdentity/&identityType/@ConstantPlaceHolder</PATH>";
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put "      <DEFAULT>&identityType</DEFAULT>";
put '      <LENGTH>13</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="identityPublicType">';
put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/Login/AssociatedIdentity/&identityType/@PublicType</PATH>";
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '    <COLUMN name="identityName">';
put "      <PATH syntax=""XPath"">/GetMetadataObjects/Objects/Login/AssociatedIdentity/&identityType/@Name</PATH>";
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '    </COLUMN>';
put '  </TABLE>';
put '</SXLEMAP>';
run;

libname _omilib xml xmlfileref=_omires xmlmap=_omimap access=readonly;

%if &append eq 0 %then %do;
    data &table;
    set _omilib.IdentityLogins;
    attrib identityType length=$13;
    retain identityType "&identityType";
    run;
%end;
%else %do;
    proc append base=&table data=_omilib.IdentityLogins;
    run;
%end;


%CLEANUP:
libname _omilib;
filename _omimap;
filename _omires;
filename _omireq;

%mend;