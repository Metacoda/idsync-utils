/*
--------------------------------------------------------------------------------

SAS Macro: metacodaIdGroupMembersExtract

Purpose:
   Extracts a table of member information for SAS IdentityGroup (group and role)
   objects. It can be used to extract Person (user) members, nested IdentityGroup
   (group and role) members, or both combined.

Documentation:
    https://metacoda.github.io/idsync-utils/sasautos/metacodaIdGroupMembersExtract

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

%macro metacodaIdGroupMembersExtract(
   table=,
   memberType=,
   append=0,
   xmlDir=,
   debug=0
   );

%* validate the table parameter as mandatory/non-blank;
%if %sysevalf(%superq(table)=,boolean) %then %do;
   %put %str(ERR)OR: The mandatory table parameter was not specified.;
   %return;
%end;

%* A blank memberType indicates both Person and IdentityGroup members are required;
%if %sysevalf(%superq(memberType)=,boolean) %then %do;
   %metacodaIdGroupMembersExtract(table=&table, memberType=Person, append=0, xmlDir=&xmlDir, debug=&debug)
   %metacodaIdGroupMembersExtract(table=&table, memberType=IdentityGroup, append=1, xmlDir=&xmlDir, debug=&debug)
   %return;
%end;

%if &memberType ne Person and &memberType ne IdentityGroup %then %do;
   %put %str(ERR)OR: The memberType parameter must be Person or IdentityGroup;
   %return;
%end;

%local xmlDirPath;
%if %sysevalf(%superq(xmlDir)=,boolean) %then %let xmlDirPath=%sysfunc(pathname(work));
%else %let xmlDirPath=&xmlDir;
%put NOTE: Using PROC METADATA XML request/response/map dir: &xmlDirPath;

filename _omireq "&xmlDirPath/metacodaIdGroupMembersExtract-&memberType-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "&xmlDirPath/metacodaIdGroupMembersExtract-&memberType-response.xml" lrecl=32767 encoding="utf-8";
filename _omimap "&xmlDirPath/metacodaIdGroupMembersExtract-&memberType-map.xml" lrecl=1024 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>IdentityGroup</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
put '  <Flags>67109252</Flags>'; %* OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_XMLSELECT(128) + OMI_TEMPLATE(4);
put '  <Options>';
put '    <Templates>';
put '        <IdentityGroup Id="" PublicType="" Name="">';
put "          <MemberIdentities Search=""&memberType""/>";
put '        </IdentityGroup>';
%if &memberType=Person %then %do;
    put '        <Person Id="" PublicType="" Name=""/>';
%end;
put '    </Templates>';
put "    <XMLSELECT search=""IdentityGroup[MemberIdentities/&memberType]""/>";
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
put '<SXLEMAP version="1.2" name="IdentityGroupMembers">';
put '  <TABLE name="identityGroupMembers">';
put "    <TABLE-PATH syntax=""XPATH"">/GetMetadataObjects/Objects/IdentityGroup/MemberIdentities/&memberType</TABLE-PATH>";
put '    <COLUMN name="objId" retain="YES">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put '      <PATH syntax="XPATH">/GetMetadataObjects/Objects/IdentityGroup/@Id</PATH>';
put '    </COLUMN>';
put '    <COLUMN name="publicType" retain="YES">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put "      <PATH syntax=""XPATH"">/GetMetadataObjects/Objects/IdentityGroup/@PublicType</PATH>";
put '    </COLUMN>';
put '    <COLUMN name="name" retain="YES">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put '      <PATH syntax="XPATH">/GetMetadataObjects/Objects/IdentityGroup/@Name</PATH>';
put '    </COLUMN>';
put '    <COLUMN name="memberObjId">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>68</LENGTH>';
put "      <PATH syntax=""XPATH"">/GetMetadataObjects/Objects/IdentityGroup/MemberIdentities/&memberType/@Id</PATH>";
put '    </COLUMN>';
put '    <COLUMN name="memberType">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put "      <DEFAULT>&memberType</DEFAULT>";
put '      <LENGTH>13</LENGTH>';
put "      <PATH syntax=""XPATH"">/GetMetadataObjects/Objects/IdentityGroup/MemberIdentities/&memberType/@ConstantPlaceHolder</PATH>";
put '    </COLUMN>';
put '    <COLUMN name="memberPublicType">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put "      <PATH syntax=""XPATH"">/GetMetadataObjects/Objects/IdentityGroup/MemberIdentities/&memberType/@PublicType</PATH>";
put '    </COLUMN>';
put '    <COLUMN name="memberName">';
put '      <TYPE>character</TYPE>';
put '      <DATATYPE>string</DATATYPE>';
put '      <LENGTH>240</LENGTH>';
put "      <PATH syntax=""XPATH"">/GetMetadataObjects/Objects/IdentityGroup/MemberIdentities/&memberType/@Name</PATH>";
put '    </COLUMN>';
put '  </TABLE>';
put '</SXLEMAP>';
run;

libname _omilib xml xmlfileref=_omires xmlmap=_omimap access=readonly;

%if &append eq 0 %then %do;
    data &table;
    set _omilib.identityGroupMembers;
    run;
%end;
%else %do;
    proc append base=&table data=_omilib.identityGroupMembers;
    run;
%end;


%CLEANUP:
libname _omilib;
filename _omimap;
filename _omires;
filename _omireq;

%mend;