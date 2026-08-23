# Real PDF fixture corpus

These are real PDFs selected from links previously supplied in project discussions. The point is to exercise the parser and image/caption harvester against ordinary published PDFs, not only synthetic byte strings.

Source review date: **2026-08-23**.

## Checked-in fixtures

### `pdfs/origami-in-n-dimensions-2203.11355.pdf`

- Title: *Origami in N dimensions: How feed-forward networks manufacture linear separability*
- Authors: Christian Keup, Moritz Helias
- Source: https://arxiv.org/abs/2203.11355
- PDF: https://arxiv.org/pdf/2203.11355
- Submitted: 2022-03-21
- License shown by arXiv: CC BY-SA 4.0
- License: https://creativecommons.org/licenses/by-sa/4.0/
- SHA-256 observed 2026-08-23: `5cbcfdaff46b8ce38bf54e9f70aa8e92e66edb232e0763417ac99daa0f642770`
- Why useful: figure-heavy mathematical paper; useful for image objects, page resources, figure/caption association, and mixed text/graphics layouts.

### `pdfs/complexity-of-linear-regions-in-deep-networks.pdf`

- Title: *Complexity of Linear Regions in Deep Networks*
- Authors: Boris Hanin, David Rolnick
- Original publication: Proceedings of the 36th International Conference on Machine Learning, PMLR 97:2596-2604, 2019
- Publication page: https://proceedings.mlr.press/v97/hanin19a.html
- PDF: https://proceedings.mlr.press/v97/hanin19a/hanin19a.pdf
- Related arXiv source previously supplied: https://arxiv.org/abs/1901.09021
- PMLR publication agreement licenses articles to the public under CC BY 4.0: https://proceedings.mlr.press/pmlr-license-agreement.html
- License: https://creativecommons.org/licenses/by/4.0/
- SHA-256 observed 2026-08-23: `951f8f5c92c3d6b2da046168d02bdc058c12dacffe518c023fea60ca13ec4e25`
- Why useful: nine-page two-column paper with figures and captions beginning on page 1; useful for testing spatial caption association as well as extraction.

### `pdfs/on-the-expressive-power-of-deep-neural-networks.pdf`

- Title: *On the Expressive Power of Deep Neural Networks*
- Authors: Maithra Raghu, Ben Poole, Jon Kleinberg, Surya Ganguli, Jascha Sohl-Dickstein
- Original publication: Proceedings of the 34th International Conference on Machine Learning, PMLR 70, 2017
- Publication page: https://proceedings.mlr.press/v70/raghu17a.html
- PDF: https://proceedings.mlr.press/v70/raghu17a/raghu17a.pdf
- Related arXiv source previously supplied: https://arxiv.org/abs/1606.05336
- PMLR publication agreement licenses articles to the public under CC BY 4.0: https://proceedings.mlr.press/pmlr-license-agreement.html
- License: https://creativecommons.org/licenses/by/4.0/
- SHA-256 observed 2026-08-23: `865fece7060b79b2a47db57a1a7842759337a894facd6eb932bf62241920364b`
- Why useful: eight-page two-column scientific paper; a useful contrast with the more image-heavy fixtures and another independently produced real PDF structure.

## Indexed remote PDFs from previously supplied arXiv links

These are useful parser targets, but their arXiv pages currently show only arXiv's non-exclusive distribution license rather than a general redistribution license. They remain indexed here instead of being copied into this public repository unless another redistributable publication copy is identified.

- https://arxiv.org/abs/1312.6098 — *On the number of response regions of deep feed forward networks with piece-wise linear activations* — Razvan Pascanu, Guido Montufar, Yoshua Bengio
- https://arxiv.org/abs/1803.01719 — *How to Start Training: The Effect of Initialization and Architecture* — Boris Hanin, David Rolnick
- https://arxiv.org/abs/2305.00241 — *When Deep Learning Meets Polyhedral Theory: A Survey* — Joey Huchette, Gonzalo Muñoz, Thiago Serra, Calvin Tsay

The previously supplied arXiv links `1606.05336` and `1901.09021` are represented above by their redistributable PMLR publication copies.

arXiv's non-exclusive distribution license records permission granted to arXiv itself: https://arxiv.org/licenses/nonexclusive-distrib/1.0/

## Indexed Internet Archive source previously supplied

- https://archive.org/details/hegelmythslegendOOOOunse — *Hegel Myths and Legends*, edited by Jon Stewart.

This remains a remote source in this pass because no general redistribution license for copying the complete PDF into this public repository has been established.

## Fixture policy

Repository size is not a reason to avoid real fixtures. When a previously supplied PDF has clear redistribution permission, prefer checking the complete PDF into `fixtures/pdfs/` rather than replacing it with a tiny generated stand-in.

For extraction tests, figures and their captions belong together: a successful figure fixture should eventually assert both the extracted visual material and its associated caption/layout text where the PDF provides one.
