# PDF data and object types

This is the parser-facing inventory of PDF value types. It follows ISO 32000-2:2020 terminology with current resolved errata and keeps three different ideas separate:

1. the basic object types that actually occur in PDF syntax;
2. indirect-object/reference syntax, which changes how an object is stored or named but does not create a new underlying value type;
3. common semantic data types defined by the PDF standard in terms of the basic object types.

This separation should be preserved when the model is encoded in Edriç.

## 0. Source record

Manual: **ISO 32000-2:2020, _Document management — Portable document format — Part 2: PDF 2.0_.**

Locations used for this inventory:

- Clause 7, **§7.3 “Objects”** for the basic object syntax.
- **§7.3.2** Boolean objects.
- **§7.3.3** Numeric objects: integer and real.
- **§7.3.4** String objects.
- **§7.3.5** Name objects.
- **§7.3.6** Array objects.
- **§7.3.7** Dictionary objects.
- **§7.3.8** Stream objects.
- **§7.3.9** Null object.
- **§7.3.10** Indirect objects and references.
- **§7.9.1, Table 35 — “PDF data types” (informative)** for the broader standard data-type vocabulary.
- The individual Table 35 rows point onward to §§7.9.2–7.11 where the derived/common types are defined.

Copy consulted: PDF Association rendering of the ISO 32000-2:2020 resolved errata for Clause 7:

`https://pdf-issues.pdfa.org/32000-2-2020/clause07.html`

**Date consulted: 2026-08-23.**

The errata page reported **“Page last modified: Jun 19 2026”** when consulted.

A shorter provenance-only copy is kept in `notes/pdf-type-source.md`.

## 1. Basic PDF object types

At the object-syntax level, a PDF parser needs to represent these nine basic types.

### Boolean

Manual: ISO 32000-2:2020 §7.3.2.

Syntax:

```pdf
true
false
```

Two values only.

### Integer

Manual: ISO 32000-2:2020 §7.3.3.

Examples:

```pdf
0
17
-42
+3
```

An integer numeric object.

### Real

Manual: ISO 32000-2:2020 §7.3.3.

Examples:

```pdf
3.14
-0.25
.5
12.
```

A non-integer numeric object. The standard also uses the broader term **number** for either an integer or a real.

### String

Manual: ISO 32000-2:2020 §7.3.4.

A sequence of bytes. It has two lexical representations, but these are two encodings of the same basic PDF object type.

Literal string:

```pdf
(hello)
```

Hexadecimal string:

```pdf
<68656C6C6F>
```

Strings may later be given a semantic subtype such as text string, ASCII string, byte string, or PDFDocEncoded string.

### Name

Manual: ISO 32000-2:2020 §7.3.5.

Examples:

```pdf
/Type
/Image
/FlateDecode
```

A name is an atomic identifier represented by a leading `/`. `#xx` hexadecimal escapes may occur inside a name.

### Array

Manual: ISO 32000-2:2020 §7.3.6.

Example:

```pdf
[1 2 3 /Image null]
```

An ordered sequence of PDF objects. Elements may have different types.

### Dictionary

Manual: ISO 32000-2:2020 §7.3.7.

Example:

```pdf
<<
  /Type /XObject
  /Subtype /Image
  /Width 640
  /Height 480
>>
```

A mapping from **name objects** to PDF objects. Dictionary values may be of any PDF object type allowed by the surrounding specification.

### Stream

Manual: ISO 32000-2:2020 §7.3.8.

Example shape:

```pdf
<< /Length 123 >>
stream
...123 bytes...
endstream
```

A stream consists of a stream dictionary plus a byte sequence. The bytes may be compressed, encrypted, image data, page-description instructions, font data, metadata, or essentially any other stream payload permitted by the surrounding PDF object definition.

For parsing, the important rule is that the stream body is binary data. Once `/Length` is known, consume the stream extent as bytes rather than searching inside it for PDF-looking keywords.

### Null

Manual: ISO 32000-2:2020 §7.3.9.

Syntax:

```pdf
null
```

The distinguished null object.

## 2. Numeric supertype

Manual: ISO 32000-2:2020 §7.3.3 and Table 35 row `number`.

The specification commonly says **number** when either of these is accepted:

```text
number = integer | real
```

`number` is useful in an Edriç model as a choice or constraint, but it is not a tenth primitive serialized form.

## 3. Direct objects, indirect objects, and references

Manual: ISO 32000-2:2020 §7.3.10 for indirect objects and references.

These are structurally important to a parser, but they are not additional basic value types.

### Direct object

A value written directly where it is used:

```pdf
/Width 640
```

Here `640` is a direct integer object.

### Indirect object

A PDF object assigned an object number and generation number:

```pdf
12 0 obj
<< /Type /XObject /Subtype /Image >>
endobj
```

The wrapped value is still a dictionary, array, string, stream, etc.

### Indirect reference

A reference to an indirect object:

```pdf
12 0 R
```

This should have its own parser/AST constructor because it occurs in object syntax, even though the referenced object's eventual value has one of the basic types above.

A useful future Edriç distinction is roughly:

```text
PDF value
  = null
  | boolean
  | integer
  | real
  | string
  | name
  | array of PDF values/references
  | dictionary from names to PDF values/references
  | stream
  | indirect reference
```

with `indirect object` represented separately as storage/identity metadata around a value.

## 4. Common PDF data types defined by the standard

Source for the names in this section: **ISO 32000-2:2020 §7.9.1, Table 35 — “PDF data types” (informative)**, with the resolved errata current on 2026-08-23.

Table 35 contains 20 type names. Most are semantic refinements or standardized structures built from the basic object types rather than new primitive syntax.

### ASCII string

Manual subclauses: §§7.3.4, 7.9.2.

Underlying type: **string**.

A string whose bytes are encoded as ASCII characters.

### Array

Manual subclause: §7.3.6.

Underlying type: **array**.

### Boolean

Manual subclause: §7.3.2.

Underlying type: **boolean**.

### Byte string

Manual subclauses: §§7.3.4, 7.9.2, 7.9.2.4.

Underlying type: **string**.

A string used for arbitrary bytes. The bytes need not denote characters; if they do, their encoding is determined by context.

### Date

Manual subclauses: §§7.3.4, 7.9.2, 7.9.4.

Underlying type: **string**.

A string following PDF's date syntax, conventionally beginning with `D:`.

### Dictionary

Manual subclause: §7.3.7.

Underlying type: **dictionary**.

### File specification

Manual subclause: §7.11.

Underlying type: **string or dictionary**.

Represents a file or file location. Embedded-file data itself is stored in streams referenced through file-specification structures.

### Function

Manual subclause: §7.10.

Underlying type: **dictionary or stream**.

A PDF function object, such as sampled, exponential-interpolation, stitching, or PostScript-calculator functions.

### Integer

Manual subclause: §7.3.3.

Underlying type: **integer**.

### Name

Manual subclause: §7.3.5.

Underlying type: **name**.

### Name tree

Manual subclause: §7.9.6.

Underlying type: **dictionary structure**.

A tree mapping string keys to PDF objects. It is a standardized dictionary/array structure, not a primitive parser token.

### Null

Manual subclause: §7.3.9.

Underlying type: **null**.

### Number

Manual subclause: §7.3.3.

Underlying type: **integer or real**.

The numeric supertype. Table 35 deliberately uses this row rather than a separate `real` row.

### Number tree

Manual subclause: §7.9.7.

Underlying type: **dictionary structure**.

A tree mapping integer keys to PDF objects.

### PDFDocEncoded string

Manual subclauses: §§7.9.2, 7.9.2.3.

Underlying type: **text string**, hence ultimately **string**.

A human-readable text string encoded using PDFDocEncoding.

### Rectangle

Manual subclause: §7.9.5.

Underlying type: **array**.

Exactly four numeric elements:

```pdf
[x1 y1 x2 y2]
```

### Stream

Manual subclause: §7.3.8.

Underlying type: **stream**.

The standard treats the stream together with its stream-extent dictionary as the stream object.

### String

Manual subclauses: §§7.3.4, 7.9.2.

Underlying type: **string**.

May be qualified as text string, ASCII string, or byte string.

### Text string

Manual subclauses: §§7.9.2, 7.9.2.2.

Underlying type: **string**.

Human-readable text. In PDF 2.0 the permitted encodings include PDFDocEncoding, UTF-16BE, and UTF-8 according to the string's form and markers required by the standard.

### Text stream

Manual subclause: §7.9.3.

Underlying type: **stream**.

A stream whose data is text under the rules of the context in which the standard calls for a text stream.

## 5. Lexical forms that are not distinct data types

Do not accidentally multiply the type system merely because PDF has multiple textual spellings.

- `(literal string)` and `<hexadecimal string>` are both **string objects**.
- `17`, `+17`, and `00017` are all **integer objects** if accepted by the relevant syntax rules.
- `/Name` and a name containing `#xx` escapes are both **name objects**.
- `<< ... >> stream ... endstream` is one **stream object** whose dictionary is part of that stream object.
- `12 0 obj ... endobj` gives identity/storage to an object; it does not change the wrapped object's type.

## 6. Semantic PDF objects are generally not new data types

PDF defines hundreds of named object kinds: page dictionaries, catalog dictionaries, font dictionaries, annotations, XObjects, image XObjects, form XObjects, cross-reference streams, object streams, ICC profiles, actions, destinations, structure elements, and so on.

Those are schemas or semantic roles built from the object types above. For example:

```text
image XObject          = stream with an image-XObject dictionary
page                   = dictionary with the page schema
font                   = usually dictionary plus related objects/streams
cross-reference stream = stream with the xref-stream schema
object stream          = stream with the object-stream schema
```

For this project that distinction is especially useful: `/Subtype /Image` does not introduce an `Image` primitive. It tells us that a particular **stream object** follows the image-XObject schema and that its stream bytes should be interpreted according to entries such as `/Filter`, `/Width`, `/Height`, `/ColorSpace`, and `/BitsPerComponent`.

## 7. Parser checklist

A complete low-level object parser should eventually recognize:

```text
null
boolean
integer
real
string: literal form
string: hexadecimal form
name
array
dictionary
stream
indirect reference
indirect-object wrapper
```

The first nine entries correspond to the basic PDF object model if integer and real are counted separately; indirect references and indirect-object wrappers are additional syntax/structure the parser must handle.

After that, semantic validation can refine generic values into things such as rectangle, text string, image XObject, page, or cross-reference stream without making the byte-level parser responsible for the entire PDF specification.

## Sources

Primary manual and exact locations:

- ISO 32000-2:2020, _Document management — Portable document format — Part 2: PDF 2.0_, Clause 7.
- §7.3, “Objects”, especially §§7.3.2–7.3.10.
- §7.9.1, Table 35, “PDF data types” (informative).
- §§7.9.2–7.11 for the common/derived data structures named by Table 35.

Copy consulted:

- PDF Association resolved-errata rendering for ISO 32000-2:2020 Clause 7: `https://pdf-issues.pdfa.org/32000-2-2020/clause07.html`
- Consulted: **2026-08-23**.
- Page reported last modified: **Jun 19 2026**.

Historical cross-check only:

- Adobe PDF Reference, sixth edition, version 1.7, Chapter 3 (Syntax), especially 3.2 (Objects) and 3.8 (Common data structures).

The important implementation distinction is intentional: the **basic parser types** are a small closed set; the hundreds of named PDF object kinds belong in later schema/semantic layers.
