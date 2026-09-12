# matlab-sci-plot

`matlab-sci-plot` is a MATLAB-first Agent Skill for planning, rendering, reviewing, and evidencing publication-quality scientific figures from explicit scientific intent.

The V1 architecture is contract-first: scientific intent is bound into a versioned Figure Contract, converted into a Figure Plan, dispatched through registered MATLAB renderers, resolved through semantic styles and final-size layouts, and finished with scientific review plus provenance evidence.

## Current release

- Repository version: **v1.3.0**
- Production backend: **MATLAB**
- Runtime qualification basis: **v1.3.0 Figure Relationship Semantics V1 on Linux MATLAB R2024a (`24.1.0.2537033`)**
- V1 contract/schema major version: **1.0**
- Historical CJK qualification scope: **v1.2.0 Windows MATLAB R2023b; no new Linux CJK glyph claim**

See [`docs/RELEASE_NOTES_V1.3.0.md`](docs/RELEASE_NOTES_V1.3.0.md) for the release summary and [Issue #53](https://github.com/handpeng/matlab-sci-plot/issues/53) for the complete Figure Relationship Semantics Stage 3 qualification record.

## Qualified Figure Relationship Semantics

Version 1.3.0 accepts an explicitly declared relationship, required data roles,
pairing requirement and representation. It selects only compatible families,
verifies supplied observations before rendering, keeps summary statistics as
annotations, and blocks governed export when a relationship prerequisite fails.
Provider bindings remain explicit and authorized aggregate representations are
never inferred implicitly.

Fresh Stage 3 qualification passed on Linux MATLAB R2024a
(`24.1.0.2537033`) at exact implementation SHA
`bed373a3a3b07dda5fcf8663f483cf3df41dc1b6`. It covered actual scatter, trend,
parity and composite renders, provider mapping, authorized aggregate data,
annotation separation, fail-closed negative controls and evidence binding.
The plotter does not invent paired observations or upgrade a scientific claim.

## Historical CJK compatibility

The v1.2.0 CJK capability remains in the same contract-first architecture:
UTF-8 detection, governed font resolution, evidence state and deterministic
`CJKFontUnavailable` failure before preview/final export. Its independent
positive glyph qualification remains the Windows MATLAB R2023b evidence in
[Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44).

The Linux MATLAB R2024a environment used for v1.3.0 exposed zero
policy-governed CJK candidates. CJK fail-closed regression passed, but no new
positive CJK glyph, arbitrary-font, cross-platform or supplementary glyph
qualification is claimed. This repository does not bundle, install or download
fonts.

## What this Skill does

Use this Skill when a scientific figure must communicate a claim reproducibly rather than merely look attractive in a MATLAB window.

It provides a governed workflow for:

- binding research intent and external data through a Figure Contract;
- checking roles, units, missingness, sample policy, uncertainty semantics, and authorized summaries;
- selecting compatible chart families and panel narratives through registries;
- resolving semantic styles, color, physical figure size, and safe overrides;
- rendering with native MATLAB using `tiledlayout`, `nexttile`, and `exportgraphics`;
- preserving scientific values, including negative R2 values;
- reviewing final artifacts and applying only allow-listed presentation repairs; and
- recording renderer identity, candidate identity, hashes, and review/evidence provenance.

Raw or private research data should remain outside this repository. Bind external data by path/source identity according to the Figure Contract rather than copying datasets into the Skill directory.

## Requirements

For Skill discovery and orchestration:

- an Agent Skills-compatible Codex environment;
- Git for the installation methods below.

For production rendering:

- MATLAB is required;
- **Linux MATLAB R2024a is the exact relationship-qualified runtime basis** for v1.3.0;
- **Windows MATLAB R2023b remains the historical CJK-qualified basis** for v1.2.0;
- other MATLAB releases and platforms are not claimed as release-qualified unless separately tested.

For repository validation utilities:

- Python 3 is used by the non-MATLAB validation and test suite.
- The CJK development suite also uses `jsonschema` from `requirements-test.txt`;
  production Python helpers remain dependency-free.

## Install as a Codex Skill

### Recommended: user-scoped installation

Current Codex discovery supports user-installed skills under `$HOME/.agents/skills`.
For a reproducible installation, pin the released tag:

```bash
mkdir -p "$HOME/.agents/skills"
git clone --branch v1.3.0 --depth 1 \
  https://github.com/handpeng/matlab-sci-plot.git \
  "$HOME/.agents/skills/matlab-sci-plot"
```

This makes the Skill available across repositories for that user.

### Repository-scoped installation

To make the Skill available only within one repository, place the complete Skill repository at:

```text
<repo>/.agents/skills/matlab-sci-plot/
```

The directory must contain this repository's `SKILL.md` together with its referenced `schemas/`, `manifests/`, `matlab/`, `profiles/`, `references/`, and supporting files.

For installation details, repository-scoped examples, compatibility notes, upgrade instructions, and uninstall instructions, see **[`docs/installation.md`](docs/installation.md)**.

## Verify installation

For the recommended user-scoped installation:

```bash
test -f "$HOME/.agents/skills/matlab-sci-plot/SKILL.md"
grep -E '^name: matlab-sci-plot$' \
  "$HOME/.agents/skills/matlab-sci-plot/SKILL.md"
cat "$HOME/.agents/skills/matlab-sci-plot/VERSION"
```

Expected version for this release:

```text
1.3.0
```

If the Skill does not appear in Codex after installation or an update, restart Codex and verify that the directory is inside a supported Skill discovery root.

## Quick start

A simple smoke prompt is:

> Use the `matlab-sci-plot` skill to design a publication-quality prediction parity figure for a regression model. Preserve negative R2 values, use final-size layout planning, and produce the Figure Contract and Figure Plan before rendering.

A normal V1 workflow is:

```text
research intent + external data binding
                |
                v
         Figure Contract
                |
                v
          Figure Plan
                |
                v
   family registry + semantic style
                |
                v
       native MATLAB render
                |
                v
 scientific audit + visual review
                |
                v
      PNG/PDF + evidence manifest
```

## Local validation

From the Skill repository root:

```bash
python -m pip install -r requirements-test.txt
python -m unittest discover -s tests -v
python scripts/integration_check.py
```

MATLAB-dependent checks report `SKIPPED_UNAVAILABLE` when MATLAB cannot be found; that is not equivalent to a MATLAB production qualification pass.

Use the [native Builder entrypoints](references/typography.md#running-builder-checks)
for actual MATLAB checks, including `run_matlab_cjk_smoke`. A MATLAB availability
probe in the integration utility is not an execution of those smoke cases.

## Documentation map

- Skill entrypoint: [`SKILL.md`](SKILL.md)
- Installation and lifecycle: [`docs/installation.md`](docs/installation.md)
- Figure Contract: [`references/figure-contract.md`](references/figure-contract.md)
- Scientific integrity: [`references/scientific-integrity.md`](references/scientific-integrity.md)
- Chart selection: [`references/chart-selection.md`](references/chart-selection.md)
- Panel composition: [`references/panel-layout.md`](references/panel-layout.md)
- Style system: [`references/style-system.md`](references/style-system.md)
- Typography/CJK: [`references/typography.md`](references/typography.md)
- Color system: [`references/color-system.md`](references/color-system.md)
- Review/evidence contract: [`references/review-contract.md`](references/review-contract.md)
- Legacy migration: [`references/legacy-migration.md`](references/legacy-migration.md)
- Metallurgy composition patterns: [`references/metallurgy-patterns.md`](references/metallurgy-patterns.md)
- v1.3.0 release notes: [`docs/RELEASE_NOTES_V1.3.0.md`](docs/RELEASE_NOTES_V1.3.0.md)
- v1.3.0 relationship qualification evidence: [Issue #53](https://github.com/handpeng/matlab-sci-plot/issues/53)
- v1.2.0 historical CJK release notes: [`docs/RELEASE_NOTES_V1.2.0.md`](docs/RELEASE_NOTES_V1.2.0.md)
- v1.2.0 CJK qualification evidence: [Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44)
- v1.1.0 qualification evidence: [`docs/RELEASE_NOTES_V1.1.0.md`](docs/RELEASE_NOTES_V1.1.0.md)

## Versioning

The repository release version is declared in [`VERSION`](VERSION). Contract and manifest schema versions are managed independently from the repository version.

For reproducible scientific work, prefer a released tag such as `v1.3.0` rather than an unpinned moving branch. Record the exact tag or commit with downstream figure evidence.
