# SAS Macros: Overview

All SAS macros in this repository are named with a metacoda prefix to avoid name clashes with any
of your existing SAS macros.

Additionally, although the example usages show mixed case macro names, the macro source file names
are always maintained in lower case to support their use as part of the SAS autocall macro facility,
which transforms macro names to lower case file names before searching for them in the SASAUTOS file
system search path.
For more info see *Guidelines for Naming Macro Files* in the
[Using Autocall Libraries in UNIX Environments](https://support.sas.com/documentation/cdl/en/hostunx/69602/HTML/default/viewer.htm#p08uk7awhtj5w6n1qaj3n3h0oa4s.htm)
section of the *SAS 9.4 Companion for UNIX Environments*.

The following SAS macros are provided in this repository.

* [%metacodaExtIdExtract](metacodaExtIdExtract.md): Extract ExternalIdentity objects from SAS metadata. 
* [%metacodaExtIdUpdate](metacodaExtIdUpdate.md): Update ExternalIdentity objects in SAS metadata.
* [%metacodaIdentityGroupExtract](metacodaIdentityGroupExtract.md): Extract IdentityGroup (group and role) objects from SAS metadata. 
* [%metacodaPersonExtract](metacodaPersonExtract.md): Extract Person (user) objects from SAS metadata. 
* [%metacodaXMLEncode](metacodaXMLEncode.md): Encode text for use in XML files or streams.