# V1 Research Basis and Design Decisions

This document records the research basis for the V1 governance plan. It is a planning artifact, not implementation code and not a claim of journal certification.

## 1. Reference projects reviewed

### K-Dense Scientific Agent Skills

Repository: https://github.com/K-Dense-AI/scientific-agent-skills  
Relevant skill: `skills/scientific-visualization/`

Ideas adopted:

- scientific meaning before appearance;
- preserve raw data and transformations;
- distinguish universal scientific rules from dated publisher rules;
- explicit uncertainty semantics;
- accessibility and color redundancy;
- inspect exported artifacts rather than trusting plotting defaults;
- provenance-aware output and review.

Ideas not copied directly:

- Python/Matplotlib-specific implementation details;
- any profile value as a timeless publication rule.

### figures4papers

Repository: https://github.com/ChenLiu-1996/figures4papers  
Relevant skill: `scientific-figure-making/`

Ideas adopted:

- concise Skill entrypoint with detailed reference documents loaded on demand;
- visual hierarchy across panels;
- semantic highlight vs neutral comparators;
- shared legends / dedicated legend panels for complex multi-panel figures;
- consistent typography and geometry across a figure rather than panel-by-panel decoration;
- publication-oriented vector/raster export discipline.

Ideas deliberately constrained:

- tight non-zero y-limits are not generalized to bar/area encodings;
- repository-specific house colors are not treated as universal scientific colors;
- visual style never overrides scientific integrity.

### Kkkakania MATLAB Plotting Skill

Repository: https://github.com/Kkkakania/matlab-plotting-skill

Ideas adopted:

- data schema inspection before rendering;
- communication-task-oriented scheme selection;
- candidate generation rather than trusting a single rule score;
- render -> visual review -> controlled repair -> rerender;
- structured review/evidence artifacts;
- MATLAB CLI availability must be reported truthfully.

Ideas deliberately constrained:

- scientific correctness becomes a hard gate rather than only a scored dimension;
- repair actions are forbidden from changing scientific data, metrics, uncertainty, filtering, or model results;
- V1 keeps the core smaller and uses extension contracts rather than maximizing scheme count.

### gramm

Repository: https://github.com/piermorel/gramm

Ideas adopted:

- grammar-of-graphics thinking: data roles, mapping, statistical layer, facets, style;
- value of declarative composition for grouped/faceted scientific views.

Decision:

- `gramm` is an optional future backend/adapter, not a required core dependency.

## 2. Official platform guidance reviewed

### MATLAB `tiledlayout`

Source: https://www.mathworks.com/help/matlab/ref/tiledlayout.html

Decision:

- native `tiledlayout` / `nexttile` is the V1 normal-path layout engine;
- `tight_subplot` is retained only for legacy compatibility during migration.

Rationale:

- fewer third-party dependencies;
- better shared legends/colorbars and spanning layouts;
- lower coupling to historical templates.

### MATLAB `exportgraphics`

Source: https://www.mathworks.com/help/matlab/ref/exportgraphics.html

Decision:

- `exportgraphics` is the V1 normal-path exporter for supported PDF/SVG/PNG outputs;
- legacy/export helper packages remain optional fallbacks.

## 3. Publisher and scientific-figure guidance reviewed

### Nature Research Figure Guide

Sources:

- https://research-figure-guide.nature.com/figures/preparing-figures-our-specifications/
- https://research-figure-guide.nature.com/figures/building-and-exporting-figure-panels/

Design consequences:

- design at final publication size;
- avoid rainbow color scales as a default;
- avoid unnecessary background grids;
- multi-panel figures should use deliberate hierarchy, consistent panel labeling, and efficient layout;
- publisher dimensions/fonts belong in dated profiles rather than the universal style core.

### IEEE Author Center graphics guidance

Sources:

- https://journals.ieeeauthorcenter.ieee.org/create-your-ieee-journal-article/create-graphics-for-your-article/file-formatting/
- https://journals.ieeeauthorcenter.ieee.org/create-your-ieee-journal-article/create-graphics-for-your-article/resolution-and-size/

Design consequence:

- publisher-specific size/font/export requirements are profile data and can differ materially from Nature-like defaults.

### PLOS continuous-data guidance

Source: https://journals.plos.org/plosbiology/s/submission-guidelines

Design consequence:

- continuous small-sample observations should expose underlying data when feasible rather than defaulting to summary bars.

## 4. Scientific visualization research informing V1

### Cleveland and McGill graphical perception

Core design consequence:

- prefer encodings that support accurate comparison (especially common-position/common-scale judgments) before decorative encodings.

### Crameri scientific colour maps

Reference implementation: https://github.com/chadagreene/crameri

Design consequences:

- distinguish categorical, sequential, diverging, and cyclic semantics;
- rainbow/`jet` is not a default quantitative map;
- palettes are semantic assets with accessibility/print considerations.

### Raincloud plots

Reference: Allen et al., *Raincloud plots: a multi-platform tool for robust data visualization*.

Design consequence:

- distribution families should support combined raw observations + distribution + summary/interval views, rather than treating histogram/KDE and summary bars as the only choices.

## 5. Decisions specific to this repository

### D1 — MATLAB-first, reasoning-backend-neutral

Scientific planning contracts must not depend on MATLAB syntax. MATLAB is the primary V1 renderer, not the definition of scientific truth.

### D2 — Figure families, not template filenames

The current scripts are valuable migration inputs, but the permanent API is organized by scientific communication family.

### D3 — Registry-based extensibility

Future SHAP, ternary, Pareto, response-surface, calibration, domain-shift, or other families should register metadata/compatibility/renderers without expanding one central `if/elseif` planner.

### D4 — Profiles are dated data

Publisher/journal guidance is allowed to evolve independently from rendering code. Every non-general profile records source and review date.

### D5 — Scientific integrity is above style

A visually appealing figure that clips negative `R^2`, uses incomparable samples without disclosure, invents uncertainty, or hides evidence is invalid.

### D6 — Candidate review is bounded

Generate 2–3 candidates only when semantic/layout ambiguity is meaningful. Do not exhaustively render dozens of arbitrary styles.

### D7 — Controlled repair

Visual review can change spacing, typography, marker/line size, palette, legend, grid, and layout within policy. It cannot change the analysis result.

### D8 — Domain specialization by composition

Metallurgy/materials patterns should compose generic prediction, trend, distribution, explainability, and matrix families. Domain-specific layers supply vocabulary, common evidence sequences, and pattern selection—not duplicate renderer implementations.

## 6. Expected V1 value

The success criterion is not “more templates”. V1 is successful when a user can provide data and a research context and the Skill can produce a defensible figure plan, choose a suitable visual grammar, render it with MATLAB, review the rendered result, repair presentation defects, and export reproducible publication artifacts while preserving scientific meaning.
