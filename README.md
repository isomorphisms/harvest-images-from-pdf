# harvest-images-from-pdf

Edriç experiments for finding and extracting embedded image streams from PDF files, including associated figure captions when they can be identified from page layout.

The parser design borrows the small binary-parser lesson from *Real World Haskell* Chapter 10, but the implementation target is **Edriç**, not Haskell and not ordinary Idris source. See [`notes/real-world-haskell.md`](notes/real-world-haskell.md).

Project-owned Edriç identifiers use descriptive lower `snake_case` wherever the current dialect permits it. The parser note records the small remaining syntax exception for the generic parameterized parser wrapper.

Current code:

- `src/PDF/Parser.idric` — pure byte parser core;
- `src/PDF/Lexer.idric` — PDF whitespace/comments, names, numbers, header, and indirect-object header;
- `src/PDF/Types.idric` — Edriç `choice` declarations for PDF type categories, with note/manual provenance in comments;
- `src/PDF/Figure.idric` — page-layout types and a conservative figure/caption association rule;
- `tests/parser_test.idric` — small deterministic parser tests;
- `tests/figure_caption_test.idric` — deterministic caption-label and layout-association tests.

PDF type provenance and the dated manual lookup are recorded in:

- `notes/pdf-data-types.md`;
- `notes/pdf-type-source.md`.

The figure/caption split and first association heuristic are recorded in [`notes/figure-captions.md`](notes/figure-captions.md). Raw image extraction remains independent: captions are normally separate positioned page text, so caption association happens after image-stream extraction and page placement/text interpretation.

The next parser step is cross-reference/object parsing, then identification and exact-length extraction of `/Subtype /Image` streams. After that, page-content interpretation can supply image placements and positioned text fragments to `associate_figure_captions`.
