# Changelog

All notable repository releases are documented here. Contract and manifest
schema versions are managed independently from the repository version.

## 1.3.0 - 2026-09-12

### Added

- Figure Relationship Semantics V1 for explicitly declared scientific
  relationships, required data roles, pairing requirements and governed
  representations.
- Deterministic family compatibility and data-sufficiency checks for paired
  observations, explicitly authorized aggregate representations, provider
  mappings and annotation-only statistics.
- Fail-closed relationship validation and evidence gates for missing,
  mismatched, stale, malformed or unauthorized relationship inputs.

### Qualified

- Fresh Stage 3 qualification passed at exact implementation SHA
  `bed373a3a3b07dda5fcf8663f483cf3df41dc1b6` on Linux MATLAB R2024a
  (`24.1.0.2537033`), including scatter, trend, parity, composite, provider
  mapping, authorized aggregate and scientific negative-control paths.
- Historical English, UTF-8, style, layout, export, evidence and CJK
  fail-closed behavior remains preserved. The tested Linux MATLAB runtime had
  zero policy-governed CJK candidates, so no new positive CJK glyph
  qualification is claimed.

### Scope

- The renderer does not fabricate missing observations, infer scientific data,
  or become authority for an external manuscript or research dataset.
- No fonts are bundled, installed or downloaded. CJK positive glyph
  qualification remains limited to the historical v1.2.0 Windows MATLAB
  evidence.

## 1.2.0 - 2026-09-08

### Added

- Governed UTF-8 Chinese/CJK labels, units, legends, category/group labels,
  feature ticks and composite panel-visible text in the existing Figure
  Contract and MATLAB renderer architecture.
- Deterministic Unicode-range CJK detection and one machine-readable ordered
  CJK font candidate policy shared by Python and MATLAB.
- Runtime font discovery and fail-closed CJK resolution through MATLAB
  `listfonts`, with figure-wide native typography application.
- Actual typography state in evidence manifests, including requested/resolved
  font, policy identity/version and resolution route.
- Synthetic CJK MATLAB smoke coverage and independent Stage 3 qualification
  of real PNG and vector-PDF outputs.

### Changed

- Centralized MATLAB JSON input through explicit UTF-8 byte decoding so
  supplementary Unicode survives Windows R2023b ingestion.
- Ordinary CJK identifiers such as `样品_A` preserve literal underscores while
  explicitly marked TeX scientific expressions retain their interpreter.
- Repository and generated evidence version advanced to `1.2.0`; V1 contract
  and manifest schema major versions remain `1.0`.

### Qualified

- Independent CJK Stage 3 passed at implementation SHA
  `21f7ffdc63d6664f6b1a989ae73ab4731dd7ccfb` on Windows MATLAB R2023b
  (`23.2.0.2365128`).
- All 52 non-MATLAB tests, six native MATLAB entrypoints, English/scientific
  regression, nine CJK negative-control categories and evidence provenance
  passed.
- Fourteen PNGs and fourteen vector PDFs were individually inspected; all
  listed PDF fonts were verified embedded, subset and Unicode mapped.
- Qualification is not a Linux/macOS claim and does not claim supplementary
  font glyph coverage. See Issue #44 and `docs/RELEASE_NOTES_V1.2.0.md`.

## 1.1.1 - 2026-09-07

### Added

- Root `README.md` with installation, verification, quick-start, validation,
  documentation routing, and reproducible release-pinning guidance.
- `docs/installation.md` with user-scoped and repository-scoped Codex Skill
  installation, discovery verification, upgrade, disable, uninstall, and
  provenance guidance.

### Changed

- Installation examples now pin the `v1.1.1` documentation/usability patch.
- Repository version advanced to `1.1.1`; V1 scientific contracts, manifests,
  MATLAB renderers, review/evidence behavior, and schema major version remain
  unchanged from the qualified v1.1.0 runtime implementation.

### Qualification basis

- This is a documentation/usability patch only and does not claim a new
  scientific runtime qualification.
- The production runtime qualification basis remains the v1.1.0 Stage 3 result
  on MATLAB R2023b (`23.2.0.2365128`).

## 1.1.0 - 2026-09-07

### Added

- Native MATLAB planning, registry dispatch, family rendering, review, and
  evidence pipeline for representative prediction, relationship, comparison,
  distribution, trend, and precomputed explainability figures.
- Native `tiledlayout`/`nexttile` panel composition and PNG/PDF export through
  `exportgraphics`.
- Artifact-bound review and evidence manifests with renderer identity,
  candidate identity, MATLAB version, and SHA-256 output hashes.
- Fail-closed MATLAB scientific-integrity controls and qualification tests.

### Changed

- One-panel plans now resolve to the semantic `single` layout.
- Unavailable optional family renderers report their capability truthfully.
- Repository and generated evidence version advanced to `1.1.0`; V1 machine
  contracts remain at compatible schema version `1.0`.

### Qualified

- Stage 3 native MATLAB benchmark executed with MATLAB R2023b
  (`23.2.0.2365128`) on synthetic qualification data.
- Eight positive native MATLAB cases, thirteen negative controls, PNG/PDF
  exports, evidence binding, and final-size visual review passed.
- Thirty-six non-MATLAB tests and all seventeen legacy migration entries
  passed at the Stage 3 qualification candidate.

## 1.0.0 - 2026-09-06

- Initial legacy MATLAB SCI plotting skill release.
