# MATLAB SCI Plot — CJK / Chinese Support Governance Plan

Status: **Stage 1 governance plan — implementation not yet authorized by this file alone**  
Planning baseline: `6eeafa47f9b0ca73234c875b8398c3f5ef5ba7aa` (`v1.1.1`)  
Qualified runtime basis: `v1.1.0` Stage 3 on MATLAB R2023b (`23.2.0.2365128`)  
Scope: Unicode/CJK text contracts, typography resolution, MATLAB text application, export evidence, and qualification coverage.  
Out of scope: scientific-model changes, family redesign, data transformations, publisher-compliance claims, or replacement of the qualified registry/render/audit architecture.

## 1. Goal

Extend `matlab-sci-plot` from an English-qualified scientific figure runtime into a language-aware figure runtime that can safely render Chinese and other CJK text without weakening scientific integrity or changing existing English behavior.

The target user experience is that a valid Figure Contract and bound data may contain UTF-8 Chinese text in scientific labels, group/category names, titles, panel labels, and other governed text surfaces. The renderer must select a usable font deterministically, apply it consistently, preserve mixed scientific symbols and units, export reproducible PNG/vector PDF artifacts, and record the typography decision in evidence.

The implementation must remain language-agnostic at the architecture level. Chinese is the first qualification target; the architecture must not create a separate Chinese renderer tree or duplicate figure families.

## 2. Baseline findings

The current v1.1.1 repository already has useful foundations:

- Python JSON loading uses UTF-8.
- MATLAB text values are carried through `char(string(...))`.
- `mpAxisLabel` accepts contract labels and appends units.
- family renderers pass labels into native MATLAB `xlabel`, `ylabel`, legend `DisplayName`, and title surfaces.
- `typography.font_name` is an allow-listed style override.
- final export uses native `exportgraphics` for PNG and vector PDF.

However, Chinese support is not currently qualified or production-governed:

1. `schemas/figure_contract.schema.json` does not describe the `labels` surface consumed by MATLAB, and the schema uses `additionalProperties: false`; therefore a renderer-valid label field can be schema-invalid.
2. default and publisher profile typography is fixed to Arial; there is no CJK-aware font resolution or explicit fail-closed policy.
3. there is no `listfonts`-based capability discovery or ordered fallback policy.
4. typography is applied primarily through axes style state; there is no explicit guarantee that every title, legend, panel label, and text descendant receives the resolved CJK font.
5. evidence does not explicitly record whether CJK was detected or which runtime font was resolved.
6. MATLAB smoke/qualification fixtures are English-only and therefore cannot establish Chinese PNG/PDF correctness.
7. the current typography reference explicitly describes English-only legacy compatibility rather than a multilingual contract.

## 3. Architecture invariants

### 3.1 Preserve the qualified scientific architecture

The CJK extension must compose with the existing pipeline:

```text
Figure Contract
    -> plan / family registry
    -> style resolution
    -> MATLAB native renderer
    -> scientific audit
    -> review gate
    -> export
    -> evidence
```

Do not introduce:

- a Chinese-only family registry;
- duplicated Chinese renderers;
- locale branches inside scientific audit logic;
- data changes made to solve typography problems;
- publisher-specific font logic inside family renderers.

### 3.2 Unicode is data; font choice is presentation

Scientific text values belong to the Figure Contract or bound data. Font selection belongs to the style/typography layer.

A Chinese label must not require the caller to rewrite scientific content into MATLAB escape sequences or pre-render text as an image.

### 3.3 Fail closed for final CJK export

If renderable text contains CJK characters and no approved runtime font can be resolved, final governed export must fail with a specific diagnostic such as `matlab_sci_plot:CJKFontUnavailable`.

The system must not silently continue with Arial or another font whose glyph coverage is unknown and then claim a successful governed export.

English-only behavior must remain backward compatible.

### 3.4 Font availability is runtime capability

Font availability differs by operating system and installation. The repository may define an ordered candidate policy, but it must discover the actual runtime font set through MATLAB rather than assuming a specific Windows, macOS, or Linux font exists.

The policy should prefer broadly available CJK fonts without making any one commercial/system font mandatory. Candidate examples may include:

- `Microsoft YaHei` / `Microsoft YaHei UI`;
- `SimSun`;
- `SimHei`;
- `PingFang SC`;
- `Heiti SC`;
- `Noto Sans CJK SC`;
- `Source Han Sans SC`;
- other reviewed equivalents.

This is an ordered candidate list, not a guarantee that every listed font is installed or renders correctly.

## 4. Governed renderable-text surface

Stage 2 must reconcile the machine-readable Figure Contract with the text surfaces actually consumed by the qualified runtime.

At minimum, the governed contract must cover the current runtime fields needed for multilingual rendering, including where applicable:

- axis/value labels;
- panel labels;
- communication-task metadata already used by planning;
- composite/panel structures already used by qualified native rendering;
- optional human-readable title/caption-like text only if the runtime actually consumes it;
- units as Unicode-capable strings.

Do not add speculative fields merely for future convenience.

The reconciliation must audit schema-versus-runtime drift before editing. If the current schema rejects other fields required by already-qualified execution paths, fix the minimum coherent contract surface rather than adding a one-off `labels` exception that leaves the same authority mismatch elsewhere.

Python lightweight validation and JSON Schema validation must agree on the supported contract envelope.

## 5. CJK/script detection

Introduce one deterministic helper for renderable-text inspection. Requirements:

- detect CJK Unified Ideographs and common CJK extension/radical/punctuation ranges needed for Chinese scientific labels;
- operate on UTF-8/Unicode strings without transliteration;
- inspect contract text and runtime category/group labels that can become visible figure text;
- return explicit metadata such as `contains_cjk=true/false`;
- keep scientific numeric values out of this concern;
- do not use an LLM or locale guesser for font gating.

The first implementation may conservatively classify CJK presence. It does not need full natural-language identification.

## 6. Typography resolution contract

### 6.1 Inputs

Typography resolution should receive:

- the resolved style/profile typography state;
- renderable contract text;
- visible categorical/group labels from bound data where applicable;
- the runtime font inventory.

### 6.2 Resolution order

For English-only content:

1. preserve the existing requested/profile `font_name` behavior;
2. preserve existing style size/geometry semantics.

For CJK-containing content:

1. honor an explicitly requested font only when it is present in the runtime font inventory and is part of the governed CJK-capable policy or has been explicitly approved by the caller contract/style path;
2. otherwise select the first available font from the ordered CJK fallback list;
3. if none is available, fail closed before final governed export.

Do not silently rewrite the user's scientific text.

### 6.3 Single resolved figure font for the first qualified CJK path

For the first CJK-qualified implementation, prefer one resolved CJK-capable font across the complete figure text hierarchy. This reduces cross-object fallback differences and makes PNG/PDF review reproducible.

Per-span mixed-font typography is explicitly deferred unless Stage 3 demonstrates it is necessary.

## 7. MATLAB application boundary

Add a small typography capability boundary rather than changing each family renderer independently. A coherent design may include helpers such as:

```text
matlab/core/mpContainsCJK.m
matlab/core/mpResolveFont.m
matlab/core/mpApplyTypography.m
```

Exact names may differ if a smaller design is clearer.

Requirements:

- use MATLAB `listfonts` for runtime font inventory;
- apply the resolved font to the figure and all relevant text descendants after renderable text objects exist;
- prefer a supported R2023b-compatible mechanism such as `fontname(fig, resolvedFont)` or an equivalent complete descendant traversal;
- retain existing `mpApplyStyle` responsibility for size, line width, ticks, grid, and other axes presentation;
- do not scatter `FontName` special cases across families.

## 8. Interpreter and scientific-symbol policy

The implementation must test, not assume, the behavior of Chinese text combined with scientific notation.

Minimum qualification strings should cover combinations such as:

```text
温度 (°C)
热导率 (W/(m·K))
粒径 (μm)
实验值 / 预测值
热处理状态 A
```

Also cover at least one literal underscore/backslash or other interpreter-sensitive label if that surface is supported.

Do not globally disable MATLAB text interpretation unless tests prove that is required. Any interpreter policy change must be narrow, documented, and regression-tested against existing English/scientific-symbol behavior.

## 9. Export and evidence

The existing native export boundary remains authoritative:

- PNG for raster review;
- vector PDF for publication-oriented output.

CJK support must add evidence sufficient to reproduce typography decisions. The evidence/manifest path should record at least:

- whether CJK was detected;
- requested/profile font;
- resolved runtime font;
- font-resolution policy/version or fallback identity;
- MATLAB version already recorded by the existing evidence system;
- output hashes through the existing evidence mechanism.

Do not claim that a font is embeddable merely because `listfonts` returns it. Final vector-PDF correctness is a Stage 3 runtime qualification concern.

## 10. Documentation changes

Stage 2 must update the documentation so users can distinguish:

- UTF-8 text support;
- runtime font availability;
- CJK fallback behavior;
- governed final-export failure when no CJK font is available;
- English-only backward compatibility;
- qualification scope by MATLAB release/platform.

`references/typography.md` should become the canonical typography/CJK policy document. `SKILL.md` should only route to it and summarize the boundary.

## 11. Test strategy

### 11.1 Non-MATLAB tests

Add deterministic tests for:

- UTF-8 Chinese contract load/round-trip;
- JSON Schema acceptance of governed multilingual text fields;
- Python validator and JSON Schema agreement for those fields;
- CJK detection positive and negative fixtures;
- style resolution preserving English defaults;
- safe explicit font override behavior;
- no scientific constraint mutation from typography resolution;
- documentation/source consistency.

### 11.2 MATLAB Stage 2 smoke tests

When MATLAB R2023b is available, Stage 2 must exercise at least:

- Chinese x/y labels;
- Chinese category or group legend labels;
- Chinese panel/title-like visible text on a supported surface;
- Chinese + ASCII/Unicode scientific units;
- PNG creation;
- vector PDF creation;
- resolved-font evidence;
- fail-closed behavior when the CJK fallback list is deliberately replaced with nonexistent fonts in a negative control.

If MATLAB is unavailable, report the MATLAB subset truthfully as `SKIPPED_UNAVAILABLE`; do not treat the skip as a pass.

### 11.3 Backward regression

Run the full existing non-MATLAB suite and existing native MATLAB smoke/qualification entrypoints without weakening assertions.

The current English qualification fixtures must remain valid.

## 12. Stage 3 qualification matrix

Stage 2 must stop at `IMPLEMENTED_PENDING_STAGE3`. It must not certify Chinese rendering.

Independent Stage 3 must qualify the exact merged candidate with real MATLAB and visually inspect final-size artifacts. The minimum matrix is:

1. English-only baseline figure — no regression.
2. Chinese axis labels — PNG + vector PDF.
3. Chinese legend/category labels — PNG + vector PDF.
4. mixed Chinese + Latin units/symbols (`°C`, `μm`, `W/(m·K)`) — PNG + vector PDF.
5. multi-panel figure with Chinese panel-visible text.
6. explicit approved CJK font override.
7. automatic fallback to an installed CJK font.
8. no CJK font available negative control — fail closed.
9. evidence manifest matches the actually resolved font and exact candidate SHA.

Stage 3 must inspect both raster appearance and vector-PDF text/glyph correctness. A file-existing check alone is insufficient.

Qualification claims are platform-specific. Passing on Windows + MATLAB R2023b does not automatically certify Linux/macOS font availability.

## 13. Stage 2 work packages

Stage 2 is one continuous Builder sequence and must execute these issues serially after Stage 1 creates them.

### CJK-I1 — Contract text-surface reconciliation

Audit JSON Schema, Python validation, MATLAB planner, and renderer text fields. Reconcile the minimum coherent contract surface required by qualified runtime paths and multilingual labels. Add UTF-8 schema/validator tests.

### CJK-I2 — Unicode/CJK detection and typography policy

Add deterministic CJK detection, CJK fallback policy metadata, and Python-side style/policy tests while preserving existing English defaults and scientific constraints.

### CJK-I3 — Native MATLAB font capability boundary

Implement runtime `listfonts` discovery, deterministic font resolution, fail-closed CJK behavior, and complete figure-level font application without family-specific duplication.

### CJK-I4 — Evidence/export binding

Record CJK detection and requested/resolved font identity in governed evidence while keeping the existing `exportgraphics` boundary and output hashing behavior.

### CJK-I5 — Chinese smoke fixtures and negative controls

Add synthetic Chinese/mixed-language MATLAB fixtures for axes, legends/categories, panel-visible text, scientific symbols, PNG, vector PDF, fallback, and unavailable-font failure. Keep all test data synthetic.

### CJK-I6 — Documentation and Stage 2 handoff

Update typography/SKILL/install or README guidance only where necessary; run focused and full regressions; record exact Stage 2 candidate SHA and clean-worktree state; stop at `IMPLEMENTED_PENDING_STAGE3`.

## 14. Non-goals for this cycle

Do not:

- redesign chart selection, scientific audit, family registry, or panel layout architecture;
- add a separate Chinese plotting API;
- vendor font files into the repository;
- download/install fonts automatically;
- make a specific proprietary font a mandatory dependency;
- promise full Unicode shaping for every world script;
- certify Linux/macOS without actually running qualification there;
- rasterize all vector output merely to hide a font problem;
- change numerical results, filters, metrics, units, uncertainty, or scientific claims to solve a presentation issue.

## 15. Stage boundaries

### Stage 1 — ChatGPT Governance

Audit the released baseline, research authoritative MATLAB behavior, freeze this plan, merge the exact reviewed planning diff, then create serial implementation issues.

### Stage 2 — Builder

Implement only the approved issues. Ordinary implementation defects may be repaired, but architecture or governance must not be weakened. Stage 2 may run smoke/regression tests and merge its implementation candidate, but the terminal status is `IMPLEMENTED_PENDING_STAGE3`.

### Stage 3 — Independent Qualification & Repair

Qualify the exact Stage 2 candidate in real MATLAB, inspect Chinese PNG/PDF artifacts, execute negative controls, repair material defects under Stage 3 authority, and only then determine release readiness.

## 16. Stage 2 completion criteria

Stage 2 is complete only when:

- governed multilingual text fields are accepted consistently by schema and runtime validation;
- English behavior remains backward compatible;
- CJK detection is deterministic and tested;
- CJK font resolution uses runtime capability discovery and has a clear fail-closed path;
- all visible figure text receives the resolved font through a centralized boundary;
- typography decisions are captured in evidence;
- Chinese/mixed-language smoke fixtures exist;
- existing scientific-integrity and family/layout tests remain intact;
- no font binaries or private/raw user data are committed;
- exact candidate SHA and validation results are recorded;
- final status is exactly `IMPLEMENTED_PENDING_STAGE3`, never `QUALIFIED`.
