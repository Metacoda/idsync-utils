# Sample Identity Sync Profiles

Identity Sync Profiles are usually created by using the Metacoda Identity Sync Profile Wizard
within SAS Management Console. This wizard only provides access to the most commonly used
configurable elements. To access to some of the more advanced features you will need to edit
the IDSP XML directly.
 
These sample Identity Sync Profiles show how those features can be added to an IDSP.

## idsync-ad-basic.idsp

A basic example for synchronising identities in a SAS metadata server with Microsoft Active
Directory. All of the other examples below can be compared with this basic example to review the
XML changes required.

See <https://github.com/Metacoda/idsync-utils/blob/master/samples/idsync-ad-basic.idsp>
   
## idsync-ad-capture-data-other-attrs.idsp

Demonstrates how to capture intermediate, otherwise temporary, working tables used in the identity
sync process so those tables can also be used for custom post-processing outside of the Metacoda
Identity Sync Plug-in. Also shows how to capture any additional AD object attributes required for
that custom post-processing e.g. sAMAccountName, distinguishedName and objectGUID.

See <https://github.com/Metacoda/idsync-utils/blob/master/samples/idsync-ad-capture-data-other-attrs.idsp>

## idsync-ad-hybrid.idsp

An example of a hybrid IDSP and it's corresponding child IDSPs (d1 and d2) for synchronising
identities in a SAS metadata server with multiple sources, in this case 2x Microsoft Active
Directory domain forests.

See:

* <https://github.com/Metacoda/idsync-utils/blob/master/samples/idsync-ad-hybrid.idsp>
* <https://github.com/Metacoda/idsync-utils/blob/master/samples/idsync-ad-hybrid-d1.idsp>
* <https://github.com/Metacoda/idsync-utils/blob/master/samples/idsync-ad-hybrid-d2.idsp>