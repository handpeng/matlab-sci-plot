---
name: matlab-sci-plot
description: MATLAB-first scientific figure planning and rendering with explicit contracts, semantic styles, family registries, review evidence, and safe legacy migration.
---

# MATLAB SCI Plot V1

Use this skill when a figure must communicate a scientific claim reproducibly, not only produce a visually attractive MATLAB window.

## Workflow

1. Bind external data and research intent in a versioned Figure Contract.
2. Inspect roles, missingness, units, sample policy, and authorized summaries.
3. Plan a compatible family and semantic panel layout through the registry.
4. Resolve style by final physical size, profile, family defaults, and safe overrides.
5. Render with the MATLAB native backend (`tiledlayout`, `nexttile`, `exportgraphics`).
6. Audit scientific correctness, review the rendered artifact, apply only allow-listed repairs, and export evidence/provenance.

## Boundaries

- Raw/private data remains outside this repository; contracts use bindings and source identities.
- Shared Class-B summaries use one tested definition. Renderers do not silently perform Class-C inference.
- Negative R2 is preserved. Uncertainty is shown only when its semantics are declared.
- Scientific integrity constraints outrank style/profile preferences.
- CJK text requires a runtime-available governed font; fail closed before preview/final export if none resolves. CJK Builder smoke is not Stage 3 qualification.
- New families, profiles, palettes, audit rules, repairs, and domain patterns are registered by metadata; do not add a central family switch.

## Routing

- Contract fields and validation: `references/figure-contract.md`, `schemas/`
- Scientific/data boundary: `references/scientific-integrity.md`, `references/uncertainty.md`
- Family selection: `references/chart-selection.md`, `matlab/families/`
- Panel composition: `references/panel-layout.md`, `matlab/core/`
- Style, color, profiles, final size: `references/style-system.md`, `references/color-system.md`, `profiles/`
- Unicode/CJK text, font resolution, literal identifiers and qualification scope: `references/typography.md`
- Review, repair, evidence: `references/review-contract.md`
- Legacy migration: `references/legacy-migration.md`
- Domain composition: `references/metallurgy-patterns.md`

Install test dependencies from `requirements-test.txt`, then run the local non-MATLAB suite with `python -m unittest discover -s tests -v`. MATLAB-dependent checks report `SKIPPED_UNAVAILABLE` when MATLAB cannot be found. The v1.2.0 CJK capability is independently qualified on Windows MATLAB R2023b within the scope and limits documented in `references/typography.md` and `docs/RELEASE_NOTES_V1.2.0.md`.

The repository version is declared in `VERSION` and is recorded in generated plans and evidence manifests.
