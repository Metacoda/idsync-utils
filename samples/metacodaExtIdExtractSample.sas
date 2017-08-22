/*
--------------------------------------------------------------------------------

Sample: metacodaExtIdExtractSample.sas

Purpose:
   Demonstrates the use of the metacodaExtIdExtract macro.

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
%include '../sasautos/metacodaextidextract.sas';

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

* Sample 1: extract basic attributes for ALL ExternalIdentity objects;

%metacodaExtIdExtract(table=work.allExtIds)

title1 "ALL ExternalIdentity objects";

proc contents data=work.allExtIds;
run;

proc print data=work.allExtIds label width=min;
run;

* -----------------------------------------------------------------------------;

* Sample 2: extract basic attributes for ExternalIdentity objects created through
  identity synchronisation of users (Person objects) when using the tag
  'Active Directory Import'
  ;

%metacodaExtIdExtract(
    table=work.adUserExtIds,
    context=Active Directory Import,
    associatedModelType=Person
    )

title1 "ExternalIdentity objects for AD Users";

proc contents data=work.adUserExtIds;
run;

proc print data=work.adUserExtIds label width=min;
run;

* -----------------------------------------------------------------------------;

* Sample 3: extract basic attributes for ExternalIdentity objects created through
  identity synchronisation of groups (IdentityGroup objects) when using the tag
  'Active Directory Import'
  Additionally generate debug info and capture the XML files in /tmp
  ;

%metacodaExtIdExtract(
    table=work.adGroupExtIds,
    context=Active Directory Import,
    associatedModelType=IdentityGroup,
    xmlDir=/tmp,
    debug=1
    )

title1 "ExternalIdentity objects for AD Groups";

proc contents data=work.adGroupExtIds;
run;

proc print data=work.adGroupExtIds label width=min;
run;

* -----------------------------------------------------------------------------;