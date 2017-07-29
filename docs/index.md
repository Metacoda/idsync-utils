# Metacoda Identity Sync Utilities (idsync-utils)

## Intro

This site provides documentation for the [Metacoda® Identity Sync Utilities (idsync-utils)
repository on github](https://github.com/Metacoda/idsync-utils) where you will find extra samples
and SAS macros that can be used with the
[Metacoda Identity Sync Plug-in](https://www.metacoda.com/en/products/security-plug-ins/identity-sync/).

Metacoda customers and partners, and potentially other SAS customers, may find these utilities
useful when setting up an identity synchronisation process between a [SAS®](https://www.sas.com/)
Metadata Server and an external identity provider, such as Microsoft Active Directory.

## Installation

Choose a suitable location in the file system on your SAS server (or workstation) and clone the
repository from github e.g.

    git clone git@github.com:Metacoda/idsync-utils.git
   
or:
   
    git clone https://github.com/Metacoda/idsync-utils.git

Alternatively you can download a ZIP file from https://github.com/Metacoda/idsync-utils/archive/master.zip and unpack
it into the desired location.

If you want to make the SAS macros available using the SAS autocall facility you can add the path
to the idsync-utils/sasautos directory into the SASAUTOS option by adding the following line into
the appropriate *sasv9_usermods.cfg* file for your SAS platform installation
e.g. /opt/sas94m4/config/Lev1/SASApp/sasv9_usermods.cfg
 
    -insert sasautos "/path/to/idsync-utils/sasautos"

## Repository Structure

| Folder     | Notes         |
| ---------- | ------------- |
| docs/      | This documentation. |
| samples/   | Contains example Metacoda Identity Sync Profiles (.idsp files) and SAS programs that relate to SAS metadata identity synchronisation. |
| sasautos/  | Contains utility SAS macros that may be of use in an identity sync process. This directory can be added to the SAS autocall macro search path if required. |