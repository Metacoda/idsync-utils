/*
--------------------------------------------------------------------------------

Sample: metacodaExtIdUpdateSample.sas

    WARNING: THIS SAMPLE PROGRAM UPDATES SAS METADATA.
   
        When provided with correct SAS metadata server details this program
        will update SAS metadata ExternalIdentity objects which may break
        any existing identity sync process you current have operating, and
        has the potential to DELETE users and group at the next sync operation
        unless you have delete-protection in your sync process.
       
        Do not modify and run this program unless it is your intention to
        update ExternalIdentity metadata, you are fully aware of the potential
        consequences, and are confident you have adequate SAS  metadata backups
        so you can revert the process if required.
        
        If you are unsure please contact Metacoda Support <support@metacoda.com>
        to discuss further.

Purpose:
    Demonstrates the use of the metacodaExtIdUpdate macro by recoding
    ExternalIdentity object Identifier values for existing Active Directory
    synced users and groups in SAS metadata.
    
    This sample can be used as part of a migration of SAS identity sync keyId
    from one attribute to another. In this sample we switch from a current
    keyId of sAMAccountName for users to a new keyId of objectGUID.
    We also switch the group keyId from distinguishedName to objectGUID.
    By switching to objectGUID we can take advantage of a better choice
    for an unchanging unique id for objects in Active Directory. 
     
    Remember that updating existing metadata is only one part of the keyId
    migration process. You will also need to update your regular synchronisation
    process to use the new keyId choices. If you use the Metacoda Identity Sync
    Plug-in then you will need to edit your Identity Sync Profile (.idsp file)
    either using the Metacoda Identity Sync Profile Wizard within SAS Management
    Console, or by directly editing the XML in the .idsp file.
    If you use custom SAS code for your regular synchronisation then you will
    need to update that code in the relevant places.
   
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

* These %includes are not required if you are using the SASAUTOS autocall facility;
%include '../sasautos/metacodaextidextract.sas';
%include '../sasautos/metacodaxmlencode.sas';
%include '../sasautos/metacodaextidupdate.sas';

*** These metadata options are only required when running the sample outside of a
    SAS metadata aware application.
    
    Because this program updates metadata these options are provided uncommented
    with invalid credentials to ensure it is not run accidentally. Please either
    comment these option out (if you are running this code in a SAS metadata
    aware app) or edit to provide correct values before proceeding
    ;
options
    metaserver=metadata-server-host-name
    metaport=8561
    metaprotocol=bridge
    metarepository="Foundation"
    metauser="metadata-server-user-id"
    metapass="{sas002}pwencodedpassword"
    ;

*** Site-specific settings for the keyId migration; 
%let CONTEXT=Active Directory Import;            * The extIdTag value used in the Identity Sync Profiles;
%let OLD_GROUP_KEY_ID_ATTR=distinguishedName;    * The current group keyId attribute (that we want to migrate from);
%let NEW_GROUP_KEY_ID_ATTR=objectGUID;           * The new group keyId attribute (that we want to migrate to);
%let OLD_USER_KEY_ID_ATTR=sAMAccountName;        * The current user keyId attribute (that we want to migrate from);
%let NEW_USER_KEY_ID_ATTR=objectGUID;            * The new user keyId attribute (that we want to migrate to);

*** External AD identities with new and old keyId attributes are in IDGRPS_X and PERSON_X tables in this ID_SRC
    library as populated by the Metacoda Identity Sync plug-in (see the preparation steps below).
    ;
libname ids_src 'Data/idsync/ids_src';

* -----------------------------------------------------------------------------;

/* Preparation:
    
    In order to capture tables containing the mapping from old keyId values to
    new keyId values add the serverBaseDir option to the Options tag in your
    Metacoda Identity Sync Profile (.idsp file) like so:

        <Options
            extIdTag="Active Directory Import"
            ...
            applyChanges="false"
            serverBaseDir="Data/idsync"
            />
          
    At the same time take note of the extIdTag value (as shown above) and 
    temporarily change the applyChanges value to false during this process.
    
    The serverBaseDir value specifies a directory on the SAS application
    server where ids_src, ids_trg, and ids_chg libraries and tables will
    be created. These are normally placed in the SAS work location, and
    deleted after use, so this change allows us to keep them for future use.
    A relative serverBaseDir path, as shown above, is relative to SAS
    application server directory e.g. /opt/sas/config/Lev1/SASApp
    You can use an absolute path if required.
    
    The applyChanges="false" value prevents the identity sync from applying
    any identity sync changes to SAS metadata. We want to avoid attempting
    any normal identity sync updates while we are making the keyId changes.
    When we are finished we will change applyChanges back to true.

    Now that we have configured a permanent location for the tables,
    we add groupOtherAttrs and userOtherAttrs attributes to the LDAPConfig
    tag in the same Metacoda Identity Sync Profile (.idsp file) like so:

        <LDAPConfig
            ...
            groupOtherAttrs="distinguishedName, objectGUID"
            userOtherAttrs="sAMAccountName, objectGUID"
            />
            
    Specify the AD attribute names for the old and new keyId attributes for
    groups and users. In this example, for groups, we are migrating keyId
    from distinguishedName to objectGUID so we specify both of those.
    Likewise, for users we are we are switching keyId from sAMAccountName to
    objectGUID.
       
    After making the changes above, save the changed .idsp file, then load
    it into the Metacoda Identity Sync Plug-in and do a normal upload & compare
    without attempting to apply any changes. You can also run a batch sync
    if you want (the applyChanges="false" setting above will block any changes).
    
    The result will be new tables in the Data/idsync/ids_src folder representing
    Active Directory identities including:
    
    Table IDS_SRC.IDGRPS_X including the following columns of interest:
        keyId: containing current pre-migration distinguishedName values
        X_DISTINGUISHEDNAME: containing the AD groups distinguishedName value
        X_OBJECTGUID: containing the AD groups objectGUID value

    Table IDS_SRC.PERSON_X including the following columns of interest:
        keyId: containing current pre-migration sAMAccountName values
        X_SAMACCOUNTNAME: containing the AD users sAMAccountName value
        X_OBJECTGUID: containing the AD users sAMAccountName value

    These 2 tables will be used below as lookup tables during the process
    of building the input table for the metacodaExtIdUpdate macro.
*/

* -----------------------------------------------------------------------------;

*** Extract current ExternalIdentity data (keyId) for AD-sourced SAS groups;
%metacodaExtIdExtract(table=work.adUserExtIds,
    context=&CONTEXT,
    associatedModelType=Person
    );

*** Extract current ExternalIdentity data (keyId) for AD-sourced SAS users;
%metacodaExtIdExtract(table=work.adGroupExtIds,
    context=&CONTEXT,
    associatedModelType=IdentityGroup
    );

*** Join the current SAS ExternalIdentity data with the AD data to build an update
    mapping of old KeyId to new keyId with ExternalIdentity object id
    ;
proc sql;
create table work.groupExtIdUpdate as
    select sas.objId as extIdObjId, sas.identifier as extIdOldIdentifier, ad.X_&NEW_GROUP_KEY_ID_ATTR as extIdNewIdentifier
    from ids_src.idgrps_x as ad, work.adGroupExtIds as sas
    where sas.identifier = ad.X_&OLD_GROUP_KEY_ID_ATTR
;
create table userExtIdUpdate as
    select sas.objId as extIdObjId, sas.identifier as extIdOldIdentifier, ad.X_&NEW_USER_KEY_ID_ATTR as extIdNewIdentifier
    from ids_src.person_x as ad, work.adUserExtIds as sas
    where sas.identifier = ad.X_&OLD_USER_KEY_ID_ATTR
;
quit;

*** Print the mapping tables for audit purposes;
title1 "ExternalIdentity (keyID) Update Mapping for Groups";
proc print data= work.groupExtIdUpdate;
run;
title1 "ExternalIdentity (keyID) Update Mapping for Users";
proc print data= userExtIdUpdate;
run;

*** Finally apply the updates to SAS metadata (so we can start using the new keyId attributes in Identity Sync Profiles);
%metacodaExtIdUpdate(
    table=groupExtIdUpdate,
    extIdObjIdColName=extIdObjId,
    extIdNewIdentifierColName=extIdNewIdentifier
    );
%metacodaExtIdUpdate(
    table=work.userExtIdUpdate,
    extIdObjIdColName=extIdObjId,
    extIdNewIdentifierColName=extIdNewIdentifier
    );

* -----------------------------------------------------------------------------;

/* Post Migration:
    
    There are a few post-migration steps after the metacodaExtIdUpdate macro
    has been used to migrate from old to new keyId.
    
    Modify the Metacoda Identity Sync Profile (.idsp file) to use the new keyId
    choices. This can be done by directly editing the .idsp XML file or by
    using the Metacoda Identity Sync Profile Wizard to edit an open .idsp file.
     
    To do the change in XML, update the existing LDAPConfig tags groupKeyIdAttr
    attribute value from distinguishedName to objectGUID. Also update the
    userKeyIdAttr attribute value from sAMAccountName to objectGUID.

        <LDAPConfig
            ...
            groupKeyIdAttr="distinguishedName"
            ...
            userKeyIdAttr="sAMAccountName"
            ...
            />

    Unless you intend to use the groupOtherAttrs and userOtherAttrs attributes
    for your own ongoing purposes, you can remove those attributes from the
    LDAPConfig tag.
    
    Moving on to the Options tag, change the applyChanges attribute back to true
    so that identity sync changes can then start to flow through again. As above,
    unless you are planning to use the identity sync intermediate tables for
    your own ongoing purposes, you can remove the serverBaseDir attribute so that
    the process goes back to using the SAS work location instead. You can also
    delete the ids_src, ids_tgt, and ids_chg folders and their contents from
    under the serverBaseDir location e.g. /opt/sas/config/Lev1/SASApp/Data/idsync
*/

* -----------------------------------------------------------------------------;