# Changelog

All notable repository releases are documented here. Contract and manifest
schema versions are managed independently from the repository version.

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
