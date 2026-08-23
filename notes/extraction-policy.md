# Extraction policy: figures, scanned text, and handwritten marks

The goal is to harvest genuine images and figures from PDFs, not every raster image object.

A scanned page of an old book may be stored as one large image even though, semantically, it is only a page of text. Those pages should normally be rejected rather than emitted as extracted images. OCR or other page analysis can be used to recognize that the raster content is overwhelmingly text and contains no drawing, photograph, diagram, or other wanted visual material.

This means the tool should distinguish at least two questions:

1. Is this page or object raster/image data?
2. Does it contain visual material the user is actually trying to harvest?

A page can answer yes to the first question and no to the second.

## Reporting rejected scanned-text pages

It is useful to report that scanned pages were examined and rejected as text-only, but not with hundreds of repetitive lines. Bundle page numbers compactly:

- isolated pages separated by commas: `3, 8, 14`
- consecutive pages collapsed into ranges with an en dash: `31–47, 52, 60–63`

For example:

`Scanned text-only pages with no figures: 31–47, 52, 60–63.`

Use an en dash (`–`) for page ranges, not a hyphen-minus (`-`) or mathematical minus sign (`−`).

## Mixed pages

Text-heavy pages must not be discarded wholesale. A page may contain ordinary printed text plus something worth extracting or flagging.

Examples:

- printed text plus a photograph, diagram, engraving, map, chart, or drawing;
- printed text plus handwritten marginal notes from a previous owner;
- a manuscript or diary page with mostly handwriting but also doodles, sketches, diagrams, symbols, or other non-text marks.

The eventual classifier should therefore be able to identify regions within a page rather than treating every page as simply `text` or `image`.

Possible semantic outcomes include:

- scanned text only — suppress;
- genuine figure/image — extract;
- figure plus caption — extract the figure and keep its caption associated with it;
- handwritten marginalia — flag and, when useful, crop/extract separately;
- doodle/sketch/non-text mark on a handwritten page — flag and crop/extract separately;
- uncertain mixed content — report for review rather than silently discarding.

The historical-research use case matters here: someone searching a large collection of nineteenth-century books may care specifically about handwritten ownership notes or annotations, while someone examining a writer's diary may care specifically about occasional doodles. The computer should be able to scan consistently for those rare marks without dumping every scanned text page as an image.
