# harvest-images-from-pdf

Idris experiments for finding and extracting embedded image streams from PDF files.

The first parser layer follows the small binary parser developed in *Real World Haskell* Chapter 10: explicit input state, byte offset, explicit failure, and composable parsers. See [`notes/real-world-haskell.md`](notes/real-world-haskell.md).

Current code:

- `src/PDF/Parser.idr` — pure byte parser core;
- `src/PDF/Lexer.idr` — PDF whitespace/comments, names, numbers, header, and indirect-object header;
- `tests/ParserTest.idr` — small deterministic parser tests.

With Idris 2 installed:

```sh
idris2 --source-dir src tests/ParserTest.idr -o parser-tests
build/exec/parser-tests
```

The next step is cross-reference/object parsing, then identification and exact-length extraction of `/Subtype /Image` streams.
