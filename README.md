# harvest-images-from-pdf

Edriç experiments for finding and extracting embedded image streams from PDF files.

The parser design borrows the small binary-parser lesson from *Real World Haskell* Chapter 10, but the implementation target is **Edriç**, not Haskell and not ordinary Idris source. See [`notes/real-world-haskell.md`](notes/real-world-haskell.md).

Project-owned Edriç identifiers use descriptive lower `snake_case` wherever the current dialect permits it. The parser note records the small remaining syntax exception for the generic parameterized parser wrapper.

Current code:

- `src/PDF/Parser.idric` — pure byte parser core;
- `src/PDF/Lexer.idric` — PDF whitespace/comments, names, numbers, header, and indirect-object header;
- `src/PDF/Types.idric` — Edriç `choice` declarations for PDF type categories, with note/manual provenance in comments;
- `tests/parser_test.idric` — small deterministic parser tests;
- `tests/real_pdf_test.idric` — reads a real PDF byte prefix and requires both a valid PDF header and an indirect-object header candidate.

The real-PDF test corpus currently covers two arXiv papers and the scanned Jahnke–Emde *Tables of Functions with Formulae and Curves* PDF from Internet Archive. The PDFs are downloaded during testing rather than stored in this repository.

PDF type provenance and the dated manual lookup are recorded in:

- `notes/pdf-data-types.md`;
- `notes/pdf-type-source.md`.

The next parser step is cross-reference/object parsing, then identification and exact-length extraction of `/Subtype /Image` streams.
