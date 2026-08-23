# Source record for PDF type inventory

The type inventory in `notes/pdf-data-types.md` and `src/PDF/Types.idric` was checked against the following manual source on **2026-08-23**.

## Manual

**ISO 32000-2:2020, _Document management — Portable document format — Part 2: PDF 2.0_.**

The parser-level object categories come from **Clause 7, §7.3 “Objects”**:

- Boolean object — §7.3.2
- Integer and real numeric objects — §7.3.3
- String object — §7.3.4
- Name object — §7.3.5
- Array object — §7.3.6
- Dictionary object — §7.3.7
- Stream object — §7.3.8
- Null object — §7.3.9
- Indirect objects and indirect references — §7.3.10

The broader standard vocabulary comes from **§7.9.1 “General”, Table 35 — “PDF data types” (informative)**. With the current resolved errata, Table 35 contains these 20 type names:

1. ASCII string
2. array
3. boolean
4. byte string
5. date
6. dictionary
7. file specification
8. function
9. integer
10. name
11. name tree
12. null
13. number
14. number tree
15. PDFDocEncoded string
16. rectangle
17. stream
18. string
19. text string
20. text stream

`real` is deliberately not a separate Table 35 row: §7.3.3 defines integer and real numeric objects, while Table 35 uses the broader `number` data type for an integer or real.

## Copy consulted

I consulted the PDF Association rendering of the ISO 32000-2:2020 resolved errata for Clause 7:

`https://pdf-issues.pdfa.org/32000-2-2020/clause07.html`

**Date consulted:** 2026-08-23.

The page itself reported **“Page last modified: Jun 19 2026”** when consulted.

This source record is intentionally separate from implementation choices. The manual tells us what PDF types and structures exist; `src/PDF/Types.idric` decides only how to name those categories in Edriç. Runtime representation can be chosen later.
