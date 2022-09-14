# SAS Macro: %metacodaXMLEncode

## Purpose

This macro is used for consistent encoding of text so that it can be used in an XML file or stream,
such as those used with SAS PROC METADATA.

## Parameters

    %macro metacodaXMLEncode(text);

This macro accepts a single mandatory positional parameter to generate the encoded text.
The result is the generation of an htmlencode function call to encode the supplied text. 

***text***: _(MANDATORY)_
 
The text to be encoded.

## Examples

Used in a data step, encodes the displayName variable, within an XML attribute specification. 

    encoded = cats(' DisplayName="', %metacodaXMLEncode(displayName), '"/>');

For another example see [metacodaXMLEncodeSample.sas](https://github.com/Metacoda/idsync-utils/blob/master/samples/metacodaXMLEncodeSample.sas).

