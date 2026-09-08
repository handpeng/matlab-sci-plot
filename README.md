# matlab-sci-plot

`matlab-sci-plot` is a MATLAB-first Agent Skill for planning, rendering, reviewing, and evidencing publication-quality scientific figures from explicit scientific intent.

The V1 architecture is contract-first: scientific intent is bound into a versioned Figure Contract, converted into a Figure Plan, dispatched through registered MATLAB renderers, resolved through semantic styles and final-size layouts, and finished with scientific review plus provenance evidence.

## Current release

- Repository version: **v1.2.0**
- Production backend: **MATLAB**
- Runtime qualification basis: **v1.2.0 CJK Stage 3 on Windows MATLAB R2023b (`23.2.0.2365128`)**
- V1 contract/schema major version: **1.0**
- CJK qualification scope: **Windows MATLAB R2023b; no Linux/macOS certification**

See [`docs/RELEASE_NOTES_V1.2.0.md`](docs/RELEASE_NOTES_V1.2.0.md) for the release summary and [Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44) for the complete Stage 3 qualification record.

## Qualified CJK typography

Version 1.2.0 accepts governed UTF-8 labels, detects CJK deterministically,
resolves fonts from a shared policy and actual MATLAB inventory, and records the
applied font in evidence. Missing governed fonts stop preview and final export.

Independent Stage 3 qualification passed on Windows MATLAB R2023b
(`23.2.0.2365128`) at exact implementation SHA
`21f7ffdc63d6664f6b1a989ae73ab4731dd7ccfb`. It included direct inspection of
14 PNGs and 14 vector PDFs, governed-font negative controls, font-embedding
inspection and provenance recomputation. See the
[typography policy](references/typography.md) for the supported surface and
qualification limits. Other operating systems and MATLAB releases are not
claimed as qualified.

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
- **Windows R2023b is the exact CJK-qualified runtime basis** for v1.2.0;
- other MATLAB releases are not claimed as release-qualified unless separately tested.

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
git clone --branch v1.2.0 --depth 1 \
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
1.2.0
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
- v1.2.0 release notes: [`docs/RELEASE_NOTES_V1.2.0.md`](docs/RELEASE_NOTES_V1.2.0.md)
- v1.2.0 CJK qualification evidence: [Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44)
- v1.1.0 qualification evidence: [`docs/RELEASE_NOTES_V1.1.0.md`](docs/RELEASE_NOTES_V1.1.0.md)

## Versioning

The repository release version is declared in [`VERSION`](VERSION). Contract and manifest schema versions are managed independently from the repository version.

For reproducible scientific work, prefer a released tag such as `v1.2.0` rather than an unpinned moving branch. Record the exact tag or commit with downstream figure evidence.
