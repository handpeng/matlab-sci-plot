# matlab-sci-plot v1.3.0

Version 1.3.0 adds independently qualified Figure Relationship Semantics V1
to the existing contract-first, MATLAB-first scientific figure architecture.

## Highlights

- Figure Contracts may explicitly declare scientific intent, communication task,
  required relationship, required data roles, pairing requirement, minimum data
  requirement, authorized transformations and annotation roles.
- Relationship planning selects only families compatible with the declared
  task, relationship, roles, representation and backend.
- Paired relationship observations are validated for required roles, finite
  numeric values, minimum observations and equal lengths before rendering.
- An explicitly authorized aggregate representation is supported only when its
  contract semantics and data are present. Summary statistics such as `rho`,
  `p` and `n` remain annotations and cannot substitute for observations.
- Missing, mismatched, stale, malformed and unauthorized relationship inputs
  fail closed. A failed relationship prerequisite cannot create a governed
  success export or evidence manifest.
- Native MATLAB relationship surfaces cover scatter, trend, parity, provider
  mapping, authorized aggregate and representative composite layout paths.

The implementation does not fabricate observations, infer missing scientific
data, silently smooth/filter/aggregate/impute values, or upgrade a scientific
claim. External research data remains outside the repository and is referenced
through explicit bindings and source identities.

## Qualification basis

The exact source implementation independently qualified in Stage 3 is:

```text
SOURCE_EXACT_QUALIFIED_SHA=bed373a3a3b07dda5fcf8663f483cf3df41dc1b6
SOURCE_STAGE3_ISSUE=#53
SOURCE_GOVERNANCE_ISSUE=#47
```

Fresh release qualification is governed by [Issue #57](https://github.com/handpeng/matlab-sci-plot/issues/57).
The actual runtime used for the relationship qualification was Linux MATLAB
R2024a (`24.1.0.2537033`). The qualification covered real scatter, trend,
parity and composite exports, provider mappings, authorized aggregates,
annotation-versus-representation separation, scientific negative controls and
candidate-bound PNG/PDF/evidence hashes.

The full non-MATLAB suite passed 66/66 tests, with integration, schema,
registry/family, scientific-integrity, layout/style/profile and evidence/export
checks passing. Historical English, UTF-8, style, layout, export and evidence
behavior remains preserved.

## CJK boundary

The historical v1.2.0 CJK behavior remains preserved, including deterministic
UTF-8/CJK detection, governed font policy, evidence binding and fail-closed
`matlab_sci_plot:CJKFontUnavailable` behavior. The positive CJK glyph
qualification remains the independent Windows MATLAB R2023b evidence recorded
in [Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44).

The Linux MATLAB R2024a environment used for v1.3.0 exposed zero
policy-governed CJK candidate fonts. CJK fail-closed regression passed, but no
new positive CJK glyph qualification is claimed for this environment. This
release does not claim arbitrary CJK glyph coverage, Linux-wide font
qualification, cross-version MATLAB qualification, or supplementary-plane
glyph coverage. No fonts are bundled, installed or downloaded.

## Installation

After publication authorization and creation of the `v1.3.0` tag, the
recommended user-scoped installation is:

```bash
mkdir -p "$HOME/.agents/skills"
git clone --branch v1.3.0 --depth 1 \
  https://github.com/handpeng/matlab-sci-plot.git \
  "$HOME/.agents/skills/matlab-sci-plot"
```

Verify that `VERSION` prints `1.3.0` and record the exact release tag or commit
with downstream figure evidence. Generated qualification PNG/PDF artifacts
remain outside Git.

## Release identity

Release preparation is separate from publication. The `v1.3.0` tag and GitHub
Release must target the exact merged release-preparation candidate only after
fresh Release Qualify RQ0-RQ8 passes and explicit publication authorization is
received under Issue #57. No tag, GitHub Release or package is created by the
release-preparation process itself.
