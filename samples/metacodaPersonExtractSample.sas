﻿/*
--------------------------------------------------------------------------------

Sample: metacodaPersonExtractSample.sas

Purpose:
   Demonstrates the use of the metacodaPersonExtract macro.

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
%include '../sasautos/metacodapersonextract.sas';

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

* Sample 1: extract basic attributes for all Person objects;

%metacodaPersonExtract(table=work.persons)

* -----------------------------------------------------------------------------;

* Sample 2: extract basic attributes for all Person objects as above
  but also generate debug info and capture the XML files in /tmp
  ;

%metacodaPersonExtract(
    table=work.persons,
    xmlDir=/tmp,
    debug=1
    )

title1 "Person objects";

proc contents data=work.persons;
run;

proc print data=work.persons label width=min;
run;

* -----------------------------------------------------------------------------;