# harvest-images-from-pdf

Edriç experiments for finding and extracting embedded image streams from PDF files.

The parser design borrows the small binary-parser lesson from *Real World Haskell* Chapter 10, but the implementation target is **Edriç**, not Haskell and not ordinary Idris source. See [`notes/real-world-haskell.md`](notes/real-world-haskell.md).

Current code:

- `src/PDF/Parser.idric` — pure byte parser core;
- `src/PDF/Lexer.idric` — PDF whitespace/comments, names, numbers, header, and indirect-object header;
- `src/PDF/Types.idric` — Edriç `choice` declarations for PDF type categories, with note/manual provenance in comments;
- `tests/ParserTest.idric` — small deterministic parser tests.

PDF type provenance and the dated manual lookup are recorded in:

- `notes/pdf-data-types.md`;
- `notes/pdf-type-source.md`.

The next parser step is cross-reference/object parsing, then identification and exact-length extraction of `/Subtype /Image` streams.
