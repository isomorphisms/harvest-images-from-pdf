# Real World Haskell parser lessons for this project

The useful reference is **Real World Haskell, Chapter 10: “Code case study: parsing a binary data format.”** Chapter 16 introduces Parsec, but the smaller Chapter 10 parser is a better starting point for PDF work.

The chapter starts with nested case expressions over a binary format, then factors the repeated plumbing into a parser whose shape is essentially:

```text
state -> Either error (value, state)
```

That is the model used in `PDF.Parser`.

## What carries over directly

- Parser state contains unread bytes and the current byte offset.
- Failure is a value, not an exception.
- Tiny parsers (`nextByte`, `satisfy`, `matchBytes`) are composed into larger parsers.
- The caller does not manually thread the remaining input or offset through every function.
- Errors report the byte offset. This matters even more in PDF than in the book's PGM example because PDF cross-reference data is explicitly offset-based.

## What Idris can improve

`takeBytes n` returns `Vect n Bits8`. A successful fixed-length read therefore has exactly the requested length in its type. A short input is a parse failure rather than a shorter successful value.

The parser core is pure. Idris `Data.Buffer` byte reads live in `IO`, so the file-reading layer should feed chunks into the pure parser rather than making every parser operation an I/O action. The current `List Bits8` input is intentionally the simple first representation; it should not become the final whole-PDF storage strategy.

## PDF-specific consequence

Do not search blindly for strings such as `/Subtype /Image`, `stream`, or `endstream` across the whole file. Stream bodies are arbitrary binary data and may contain those byte sequences by accident. The parser should learn enough PDF object structure to know when bytes are syntax and when they are opaque stream payload.

The next useful layer is:

1. parse the PDF header;
2. locate and parse `startxref` / cross-reference information;
3. seek to indirect objects by byte offset;
4. parse dictionaries far enough to identify `/Subtype /Image` and `/Length`;
5. consume exactly the declared stream length;
6. hand the extracted stream plus `/Filter`, `/Width`, `/Height`, `/ColorSpace`, and `/BitsPerComponent` metadata to the image-decoding/output layer.

That keeps the RWH lesson intact: make state, failure, and byte consumption explicit once, then describe the file format by composing small parsers.
