# V1 CJK / Chinese Typography Research Basis

Date: 2026-09-07  
Repository baseline: `6eeafa47f9b0ca73234c875b8398c3f5ef5ba7aa` (`v1.1.1`)  
Purpose: Stage 1 research record for the planned CJK/Chinese support increment. This document is not a qualification certificate.

## 1. Repository observations

The current runtime already preserves Unicode text through important boundaries:

- Python contract files are opened with UTF-8 encoding.
- `matlab/core/mpAxisLabel.m` converts contract text through `char(string(...))` and appends units.
- family renderers pass those labels to native MATLAB text surfaces.
- `matlab/core/mpExport.m` exports PNG and vector PDF through `exportgraphics`.

The current runtime is nevertheless English-qualified rather than CJK-qualified:

- default/general/Nature style profiles use Arial;
- `mpApplyStyle` applies `style.typography.font_name` without CJK capability discovery;
- no CJK font fallback resolver exists;
- the current Figure Contract JSON Schema does not define the `labels` field used by MATLAB and rejects unknown top-level fields;
- native MATLAB smoke and qualification fixtures use English labels and Arial;
- current evidence does not explicitly bind CJK detection to the resolved runtime font.

## 2. Authoritative MATLAB findings

### 2.1 Fonts are system/runtime dependent

MathWorks documents `FontName` as a supported font name and states that text displays and prints properly only when a font supported by the system is selected. The default depends on operating system and locale.

Source:

- https://www.mathworks.com/help/matlab/ref/matlab.graphics.primitive.text-properties.html
- https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html

Implication for this repository:

A hard-coded publication font cannot by itself constitute a cross-platform CJK guarantee. Font availability is a runtime capability and must be resolved before governed final export.

### 2.2 `listfonts` provides the runtime font inventory

MathWorks documents `listfonts` as returning the available system fonts. The documentation also cautions that the list of system fonts can differ from the set of fonts MATLAB can actually display.

Source:

- https://www.mathworks.com/help/matlab/ref/listfonts.html

Implication:

`listfonts` is appropriate for deterministic discovery and negative controls, but Stage 3 must still visually qualify Chinese output. Presence in `listfonts` is not enough to certify glyph correctness.

### 2.3 `fontname` can apply a font to a figure hierarchy

MathWorks documents `fontname(obj, fname)` as changing text within the specified graphics object and its contained graphics objects, including axes and legends. It is available in releases compatible with the repository's R2023b qualification basis.

Source:

- https://www.mathworks.com/help/matlab/ref/fontname.html

Implication:

A centralized post-render typography application boundary is preferable to adding font special cases to every figure-family renderer.

### 2.4 Vector PDF embeds fonts only when they are embeddable

MathWorks documents that `exportgraphics(..., ContentType="vector")` stores vector content and that PDF output includes embeddable fonts. PNG output represents characters as pixels and therefore does not embed fonts.

Sources:

- https://www.mathworks.com/help/matlab/ref/exportgraphics.html
- https://www.mathworks.com/help/matlab/creating_plots/saving-your-work.html
- https://www.mathworks.com/help/matlab/creating_plots/compare-ways-to-export-save-graphics-plots-from-figures.html

Implication:

The existing vector-PDF export path should remain. A Chinese PNG looking correct cannot certify the Chinese PDF. Stage 3 must inspect both.

## 3. Design conclusions

### 3.1 Do not create a Chinese renderer fork

Language affects renderable text and typography capability, not the scientific family architecture. The existing registry/family/planning/audit pipeline should remain shared.

### 3.2 Use deterministic script detection, not language inference

The runtime only needs to know whether visible text requires CJK-capable typography. It does not need to determine the natural language of the scientific claim.

### 3.3 Resolve one figure-level CJK font for the first qualified path

Using one resolved CJK-capable font across a figure reduces inconsistent fallback between axes, legends, titles, and panel text and provides a reproducible first qualification target. Per-span mixed-font typography can be added later if justified.

### 3.4 Fail closed when CJK is present but no governed font is available

Silent fallback can generate a file that exists but contains missing-glyph boxes or substituted typography. Governed final export must surface this as a runtime prerequisite failure rather than a successful scientific artifact.

### 3.5 Preserve English defaults

English-only figures should continue using the current profile/requested font path so the CJK increment does not invalidate the existing visual qualification basis unnecessarily.

## 4. Required qualification evidence

Independent Stage 3 should retain artifacts outside the repository and verify at least:

- English baseline output;
- Chinese axes;
- Chinese group/category legend text;
- mixed Chinese and `°C`, `μm`, `W/(m·K)`;
- multi-panel visible Chinese text;
- requested CJK font resolution;
- automatic fallback resolution;
- unavailable-font fail-closed behavior;
- PNG visual correctness;
- vector-PDF text/glyph correctness;
- manifest binding to the exact candidate SHA and resolved font.

The first qualified platform should be stated explicitly. Qualification on MATLAB R2023b for one OS must not be generalized to untested operating systems.

## 5. Research boundary

This research freezes architecture guidance, not implementation details. Stage 2 may choose smaller helper names or representations if they preserve the contracts in `TODO.md`. Any material change to fail-closed semantics, the shared renderer architecture, scientific audit boundaries, or Stage 3 qualification requirements requires governance escalation rather than an ordinary Builder deviation.
