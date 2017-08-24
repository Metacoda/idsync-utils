/*
--------------------------------------------------------------------------------

Sample: metacodaIdGroupMembersExtractSample.sas

Purpose:
   Demonstrates the use of the metacodaIdGroupMembersExtract macro.

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

* This %include is not required if you are using the SASAUTOS autocall facility;
%include '../sasautos/metacodaidgroupmembersextract.sas';

* These metadata options are only required when running the sample outside of a
  SAS metadata aware application
  ;
* options
  metaserver=localhost
  metaport=8561
  metaprotocol=bridge
  metarepository="Foundation"
  metauser="userid"
  metapass="{sas002}pwencodedpassword"
  ;

options ls=max ps=max;

* -----------------------------------------------------------------------------;

* Sample 1: extract IdentityGroup (group and role) member information, first for
  Person (user) members and then nested IdentityGroup (group and role) members
  ;

%metacodaIdGroupMembersExtract(table=work.idGroupMembersPersons, memberType=Person)
%metacodaIdGroupMembersExtract(table=work.idGroupMembersGroups, memberType=IdentityGroup)

* -----------------------------------------------------------------------------;

* Sample 2: extract IdentityGroup (group and role) member information for both
  Person (user) and nested IdentityGroup (group and role) members
  ;

%metacodaIdGroupMembersExtract(table=work.idGroupMembers)

* -----------------------------------------------------------------------------;

* Sample 3: extract IdentityGroup (group and role) member information for both
  Person (user) and nested IdentityGroup (group and role) members as above
  but also generate debug info and capture the XML files in /tmp
  ;

%metacodaIdGroupMembersExtract(
    table=work.idGroupMembers,
    xmlDir=/tmp,
    debug=1
    )

proc sort data=work.idGroupMembers;
by name memberName;
run;
    
title1 "IdentityGroup (group and role) members";

proc contents data=work.idGroupMembers;
run;

proc print data=work.idGroupMembers label width=min;
run;

* -----------------------------------------------------------------------------;