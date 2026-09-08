# matlab-sci-plot v1.2.0

Version 1.2.0 adds independently qualified Chinese/CJK typography to the
existing contract-first, MATLAB-first scientific figure architecture.

## Highlights

- Figure Contract `1.0` accepts the Unicode labels, units, role strings,
  composite panels and panel-visible text already consumed by the native
  runtime while unknown fields continue to fail closed.
- CJK detection is deterministic and policy-driven. Python and MATLAB read one
  ordered machine-readable font policy; no locale inference, translation,
  automatic font installation or arbitrary installed-font fallback is used.
- MATLAB discovers the actual runtime inventory with `listfonts`, applies the
  resolved governed font across the complete figure hierarchy and raises
  `matlab_sci_plot:CJKFontUnavailable` before governed export when no candidate
  is available.
- Evidence manifests bind the requested and actual resolved font, policy
  identity/version and resolution route to the existing renderer, candidate,
  review, output and SHA-256 provenance.
- Literal ordinary-text identifiers such as `样品_A` remain literal while
  explicitly marked TeX scientific expressions retain TeX behavior.
- MATLAB JSON ingestion explicitly decodes UTF-8 bytes, preserving
  supplementary Unicode on Windows R2023b.

The CJK path remains inside the same Figure Contract, planner/registry, style,
native renderer, scientific audit, review, export and evidence pipeline. It
does not introduce a locale-specific renderer tree or change scientific data.

## Independent Stage 3 qualification

Stage 3 qualification is recorded in
[Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44). The frozen
Stage 2 candidate exposed a material supplementary-Unicode JSON ingestion
defect. Repair PR #45 corrected that narrow input boundary; the complete Q0-Q6
matrix then restarted from a clean checkout of exact implementation SHA:

```text
21f7ffdc63d6664f6b1a989ae73ab4731dd7ccfb
```

The actual qualification environment was Windows MATLAB R2023b
(`23.2.0.2365128`, PCWIN64). Evidence recorded:

- 52/52 non-MATLAB tests and full integration checks passed;
- all six native MATLAB contract, typography, evidence, English rendering,
  scientific qualification and CJK smoke entrypoints passed;
- five representative English renderer families, negative R2 = -3, six
  scientific negative controls and the existing two-panel path passed;
- 19 malformed/unknown-field contracts remained fail closed;
- 16 Unicode detection vectors passed repeatedly in Python and real MATLAB;
- all nine named CJK adversarial categories passed, including missing governed
  fonts, unavailable preferred font, arbitrary installed non-governed font,
  literal identifiers, supplementary detection, malformed evidence and failed
  prerequisite artifact cleanup;
- 14 original MATLAB PNGs and 14 original vector PDFs were individually
  inspected across six native families, two composite cases, 13 CJK figures
  and one English control;
- the PDFs parsed and rendered with expected extractable text, vector paths and
  no raster image objects; and
- `pdffonts` reported every listed font embedded, subset and Unicode mapped in
  all 14 inspected PDFs.

Actual default CJK resolution on that runtime was `Arial` to
`Microsoft YaHei UI` via `fallback_cjk` under `cjk-governed-v1` version `1.0`.
The explicit governed selection and unavailable-preferred fallback paths were
also exercised. Qualification artifacts remained outside Git and their hashes
were independently recomputed.

## Scope and limits

This qualification applies to the tested Windows MATLAB R2023b environment and
the governed surfaces/glyph matrix. It does not certify Linux, macOS, other
MATLAB releases, arbitrary Unicode shaping or supplementary-plane font glyph
coverage. Supplementary UTF-8 ingestion and detection are supported separately
from glyph coverage. Fonts are never bundled, installed or downloaded by this
repository.

MATLAB `exportgraphics` retains its existing tight crop. One explicit-TeX
superscript in the Stage 3 matrix had a measured approximately 0.03125-point
outline overshoot at the page edge; enlarged inspection found the numeral fully
legible with connected strokes. Issue #44 records this nonmaterial limitation
and the exact artifact hashes rather than claiming guaranteed whitespace.

Figure Contract, Figure Plan, family/style manifests, review records and
evidence manifests remain on schema major version `1.0`. Existing English and
scientific behavior, including fail-closed audits, is preserved.

## Installation

After the `v1.2.0` tag is published, the recommended user-scoped installation
is:

```bash
mkdir -p "$HOME/.agents/skills"
git clone --branch v1.2.0 --depth 1 \
  https://github.com/handpeng/matlab-sci-plot.git \
  "$HOME/.agents/skills/matlab-sci-plot"
```

Verify that `VERSION` prints `1.2.0` and that Codex discovers the complete
Skill directory, including `policies/cjk_typography.json`.

## Release identity

The `v1.2.0` annotated tag and GitHub Release must target the exact merged
release-preparation commit on `main`. Before tagging, that commit must pass a
fresh release qualification consisting of the full non-MATLAB suite,
integration check, all six native MATLAB entrypoints, output/evidence hash
checks, version consistency, `git diff --check` and clean-worktree verification.
Release qualification evidence belongs in the release-preparation PR and
GitHub Release; generated PNG/PDF artifacts remain outside Git.
