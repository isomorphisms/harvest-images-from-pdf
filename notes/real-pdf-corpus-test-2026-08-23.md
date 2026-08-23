# Real PDF corpus test — 2026-08-23

This records raw-byte corpus checks against four actual PDFs from the working file library. These checks are an oracle for the Edriç parser tests: they exercise the same PDF header, whitespace/comment, decimal-integer, and indirect-object-header rules and independently inspect the next structures we intend to parse.

This is **not** a claim that the Edriç compiler executed successfully on this date. The local runtime did not have the Edriç compiler installed, and automated GitHub workflow writes did not produce an Actions run. The corpus checks below did run against the actual PDF bytes.

## Files

| file | bytes | SHA-256 | PDF version | first indirect object | first object byte offset | indirect-object headers found | final `startxref` target | xref form |
| --- | ---: | --- | --- | --- | ---: | ---: | ---: | --- |
| `GrAmHCScamManuscript.pdf` | 6,769,003 | `d9ad01512271038eff2c2748208cd4e3eee5423c4d2e79b2d7eda1f4f953bb27` | 1.3 | `1 0 obj` | 16 | 1,641 | 6,759,321 | classic `xref` table |
| `Hegel Myths and Legends … .pdf` | 19,457,412 | `05db714daa6d9ed2562c9fa2ee84130b1c7cdc3cc34511e618ac2332852c879d` | 1.5 | `1 0 obj` | 16 | 5,735 | 19,303,496 | classic `xref` table |
| `fourier.pdf` | 125,710 | `999c59821b62ba8398a1dc669e6965e6c4ed1170c52ac97f664615f4d9546b47` | 1.4 | `3 0 obj` | 15 | 118 | 123,168 | classic `xref` table |
| `making_matrices_better.pdf` | 4,584,128 | `64d8ec829fcff266937138914aac942f35f7c579c7000a92869e284eda68488a` | 1.4 | `4 0 obj` | 15 | 507 | 4,573,805 | classic `xref` table |

All four:

- start with a header accepted by `parse_pdf_header`;
- have a real indirect-object header within the first 16 bytes, so the current 8 KiB prefix integration test is ample for these samples;
- end with `%%EOF` after their final `startxref` section;
- have a final `startxref` value that points to a classic `xref` table.

A reference implementation of the current Edriç object-header byte rules was applied to every structurally recognized indirect-object header above. It agreed on object number and generation number for all 8,001 headers; there were zero mismatches.

## Bug found by the corpus

The first version of `tests/real_pdf_test.idric` scanned every suffix by calling `parse_indirect_object_header`. That parser deliberately accepts leading PDF whitespace and comments. Since the PDF header itself begins with `%`, a scan starting at byte 0 could skip `%PDF-...` and then parse the later first object while incorrectly reporting its position as byte 0.

The test scanner now attempts an object-header parse only when the current raw byte is an ASCII digit. On these files it therefore reports the actual first-object offsets: 15 or 16.

## Image-object observations

These counts use dictionary-level `/Subtype /Image` markers associated with the nearest enclosing indirect object. They are useful corpus expectations, not yet Edriç parser output.

| file | image markers | `/Length` direct | `/Length` indirect reference | observed filters |
| --- | ---: | ---: | ---: | --- |
| `GrAmHCScamManuscript.pdf` | 57 | 57 | 0 | 25 `/DCTDecode`, 32 `/FlateDecode` |
| `Hegel Myths and Legends … .pdf` | 1,194 | 1,194 | 0 | 799 `/JPXDecode`, 395 `/JBIG2Decode` |
| `fourier.pdf` | 0 | 0 | 0 | — |
| `making_matrices_better.pdf` | 50 | 0 | 50 | 50 `/FlateDecode` |

The important parser consequence is immediate: **`/Length` cannot be modeled as only a direct integer.** In `making_matrices_better.pdf`, every observed image stream uses an indirect length such as `/Length 21 0 R`. Image-stream extraction therefore needs to resolve an indirect reference before it knows how many bytes to consume.

Other image metadata also varies. The Hegel scan uses both JPX and JBIG2 image compression; its JBIG2 image dictionaries do not necessarily carry the same `/ColorSpace` and `/BitsPerComponent` entries as the JPX images. The extractor should preserve dictionary metadata rather than assume one fixed image schema.

## Next corpus test

After `startxref`, dictionaries, indirect references, and streams are implemented in Edriç, these four files are suitable for regression checks that:

1. resolve the final cross-reference table;
2. seek to a known indirect object by byte offset;
3. identify image stream dictionaries structurally;
4. resolve both direct and indirect `/Length` values;
5. consume exactly the declared stream bytes;
6. report image filter and basic geometry metadata without scanning inside opaque stream data.
