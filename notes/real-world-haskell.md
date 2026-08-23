# Real World Haskell parser lessons for this Edriç project

The useful reference is **Real World Haskell, Chapter 10: “Code case study: parsing a binary data format.”** Chapter 16 introduces Parsec, but the smaller Chapter 10 parser is the better design reference for this PDF work.

This project is **not a Haskell implementation**. The Haskell chapter supplies a parser-design lesson that we are translating into Edriç source under `src/PDF/*.idric`.

The chapter starts with nested case expressions over a binary format, then factors the repeated plumbing into a parser whose shape is essentially:

```text
state → Either error (value, state)
```

That state/error shape is the model used in `PDF.Parser`; the source language here is Edriç.

## Edriç spelling

The translation includes naming style, not just semantics or a `.idric` extension. Project-owned identifiers should use descriptive lower `snake_case` names whenever current Edriç syntax permits it. Examples in the parser core include:

- `parser_state_remaining_bytes`
- `parser_state_byte_offset`
- `parse_with_remaining_bytes_at_offset`
- `peek_next_byte`
- `read_next_byte`
- `read_exactly_bytes`
- `skip_pdf_whitespace_and_comments`
- `parse_indirect_object_header`

`ByteParser` and `MkByteParser` are the remaining capitalized project-owned names because the current Edriç `choice ... one_of` feature supports non-parameterized choices only. The generic parser wrapper therefore still uses an ordinary Idris-derived parameterized data declaration rather than inventing unsupported Edriç syntax.

## What carries over directly

- Parser state contains unread bytes and the current byte offset.
- Failure is a value, not an exception.
- Tiny parsers (`read_next_byte`, `read_byte_satisfying`, `require_bytes`) are composed into larger parsers.
- The caller does not manually thread the remaining input or offset through every function.
- Errors report the byte offset. This matters especially in PDF because cross-reference data is explicitly offset-based.

## What Edriç can improve

`read_exactly_bytes byte_count` returns `Vect byte_count Bits8`. A successful fixed-length read therefore has exactly the requested length in its type. A short input is a parse failure rather than a shorter successful value.

The parser core stays pure. File I/O should read only the slices needed at known PDF offsets and pass those slices to the pure parser. `parse_at_byte_offset` lets a slice keep its absolute file offset for useful errors. The current `List Bits8` input is intentionally a simple representation for such slices; it should not become the final whole-PDF storage strategy.

Edriç's storage-neutral `choice ... one_of` syntax is also a natural fit for closed PDF classifications. `src/PDF/Types.idric` uses it for the PDF type inventory rather than translating Haskell algebraic-data-type syntax mechanically. The parser core also uses it for non-parameterized `parse_error` and `parser_state`.

## PDF-specific consequence

Do not search blindly for strings such as `/Subtype /Image`, `stream`, or `endstream` across the whole file. Stream bodies are arbitrary binary data and may contain those byte sequences by accident. The parser should learn enough PDF object structure to know when bytes are syntax and when they are opaque stream payload.

The next useful layer is:

1. parse the PDF header;
2. locate `startxref` and parse either a classic cross-reference table or a cross-reference stream;
3. seek to indirect objects by byte offset;
4. parse dictionaries far enough to identify `/Subtype /Image` and `/Length`;
5. consume exactly the declared stream length;
6. hand the extracted stream plus `/Filter`, `/Width`, `/Height`, `/ColorSpace`, and `/BitsPerComponent` metadata to the image-decoding/output layer.

That preserves the useful RWH lesson without preserving Haskell as the implementation language: make state, failure, and byte consumption explicit once, then describe the PDF format by composing small Edriç parsers.
