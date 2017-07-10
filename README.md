# Metacoda Identity Sync Utils (idsync-utils)

This repository contains extra samples and SAS macros that can be used with the
[Metacoda® Identity Sync Plug-in](https://www.metacoda.com/en/products/security-plug-ins/identity-sync/).
Metacoda customers and partners, and potentially other SAS customers, may find these utilities useful when setting
up an identity synchronization process between a [SAS®](http://www.sas.com/) Metadata Server and an external identity
provider, such as Microsoft Active Directory.

## License

The utilities contained in this repository are licensed under the terms of the
[Apache License 2.0](https://opensource.org/licenses/Apache-2.0). See [LICENSE.txt](LICENSE.txt) for more information.

The Metacoda Identity Sync Plug-in which these utilities are intended to support is a commercial product from
Metacoda Pty Ltd, and must be separately licensed from Metacoda if you want to use these utilities with it.

If you do not license the Metacoda Identity Sync Plug-in from Metacoda then some of these utilities may still be of
use to you with alternative SAS identity synchronization processes. The license referenced above permits such use.

## Trademarks

Metacoda and all other Metacoda product or service names are registered trademarks or trademarks of
[Metacoda Group Pty Ltd] (https://www.metacoda.com/) in the USA and other countries.

SAS and all other SAS Institute Inc. product or service names are registered trademarks or trademarks of
[SAS Institute Inc.](http://www.sas.com/) in the USA and other countries. ® indicates USA registration.

Other product and company names mentioned herein may be registered trademarks or trademarks of their respective owners.

## Repository Contents

| Folder     | Notes         |
| ---------- | ------------- |
| samples/   | Contains example Metacoda Identity Sync Profiles (.idsp files) and SAS programs that relate to SAS metadata identity synchronization. |
| sasautos/  | Contains utility SAS macros that may be of use in an identity sync process. This directory can be added to the SAS autocall macro search path if required. |


## Installation

Choose a suitable location in the file system on your SAS server (or workstation) and clone the repository from github
e.g.

    git clone git@github.com:Metacoda/idsync-utils.git
   
or:
   
    git clone https://github.com/Metacoda/idsync-utils.git

Alternatively you can download a ZIP file from https://github.com/Metacoda/idsync-utils/archive/master.zip and unpack
it into the desired location.

If you want to make the SAS macros available using the SAS autocall facility you can add the path to the
idsync-utils/sasautos directory into the SASAUTOS option by adding the following line into the appropriate
*sasv9_usermods.cfg* file for your SAS platform installation
e.g. /opt/sas94m4/config/Lev1/SASApp/sasv9_usermods.cfg
 
    -insert sasautos "/path/to/idsync-utils/sasautos"

## SAS Macros

All SAS macros in this repository are named with a metacoda prefix to avoid name clashes with any of your existing SAS
macros.

Additionally, although the example usages show mixed case macro names, the macro source file names are always
maintained in lower case to support their use as part of the SAS autocall macro facility, which transforms macro names
to lower case file names before searching for them in the SASAUTOS file system search path.
For more info see *Guidelines for Naming Macro Files* in the
[Using Autocall Libraries in UNIX Environments](https://support.sas.com/documentation/cdl/en/hostunx/69602/HTML/default/viewer.htm#p08uk7awhtj5w6n1qaj3n3h0oa4s.htm)
section of the *SAS 9.4 Companion for UNIX Environments*.

### metacodaXMLEncode

This macro is used for consistent encoding of text so that it can be used in an XML file or stream, such as those used with SAS PROC METACODA.

Example:

    encoded = cats(' DisplayName="', %metacodaXMLEncode(displayName), '"/>');

