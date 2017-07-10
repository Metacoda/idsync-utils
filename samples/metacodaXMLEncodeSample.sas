/*
--------------------------------------------------------------------------------

Sample: metacodaXMLEncode

Purpose:
   Demonstrates the use of the metacodaXMLEncode macro.

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
%include '../sasautos/metacodaxmlencode.sas';

data _null_;
text = '** text with chars needing XML encoding: <&''"> α β γ δ ε ζ η θ **';
put text=;
xmlText = %metacodaXMLEncode(text);
put xmlText=;
run;

* -----------------------------------------------------------------------------;
