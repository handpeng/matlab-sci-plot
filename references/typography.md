# Typography and CJK text

Typography is presentation state. It must not alter scientific data, labels,
units, claims, family selection or scientific audit rules.

## Implemented and qualified scope

The v1.2.0 CJK increment passed independent Stage 3 qualification on Windows
MATLAB R2023b (`23.2.0.2365128`) at exact implementation SHA
`21f7ffdc63d6664f6b1a989ae73ab4731dd7ccfb`. Qualification is limited to that
runtime environment and the governed text surfaces below.

| Statement | What it establishes |
| --- | --- |
| UTF-8 supported | Governed contracts accept and round-trip Chinese strings |
| CJK detected | A deterministic Unicode range check found CJK text |
| Runtime font resolved | A requested or fallback font met the candidate policy and runtime inventory |
| CJK smoke tested | Synthetic runtime, export-existence and evidence checks passed on Windows MATLAB R2023b (`23.2.0.2365128`) |
| Stage 3 qualified | 14 original PNGs and 14 vector PDFs were independently inspected; 13 exercised CJK and one preserved the English path |

No Linux/macOS or cross-platform CJK certification is claimed. Candidate fonts
are not general guarantees of glyph coverage or font embedding. For the exact
Stage 3 matrix, `pdffonts` verified embedded/subset/Unicode-mapped fonts in all
14 PDFs. Supplementary Unicode ingestion and detection passed, but
supplementary glyph rendering is not claimed. Smoke review objects remain
synthetic gate inputs, not independent visual reviews. The complete evidence is
recorded in [Issue #44](https://github.com/handpeng/matlab-sci-plot/issues/44).

## Governed text surfaces

Figure Contract `1.0` accepts UTF-8 `purpose`, claims, role-keyed `labels` and
`units`, and composite `panels` with `panel_label`. The current runtime draws
axis labels/units and composite panel titles. It also draws bound category
ticks, group legends and feature-name ticks. A standalone contract title or
caption is not a supported field. See the [contract reference](figure-contract.md)
and [synthetic Chinese fixture](../examples/chinese_temperature_property.json).

Python `inspect_cjk_text` provides a conservative planning hint from text fields
and caller-supplied visible data labels. Native rendering uses actual graphics
text after object creation, including axis ticks, legends and panel titles.
Claims, purpose metadata, source paths and numeric values do not select fonts.
The deterministic Unicode ranges are stored with the font policy; detection
uses no language model, locale guessing or translation.

For MATLAB JSON consumption, use `mpReadJson(path)` after adding the repository
to the MATLAB path. Validate the governed contract structure before planning.
The reader explicitly decodes UTF-8 bytes. On the tested Windows R2023b runtime,
`jsondecode(fileread(path))` can replace supplementary characters such as
U+20000 with U+001A, even when `fileread` requests UTF-8. The centralized reader
preserves those characters in contracts and evidence. Supplementary detection
and round-trip support do not establish a font's supplementary glyph coverage.

## One authoritative font policy

[policies/cjk_typography.json](../policies/cjk_typography.json) is the single
ordered candidate/range authority for Python and MATLAB. Candidate additions
require a reviewed metadata change. Do not maintain separate platform or test
candidate lists, install/download fonts automatically, or commit font binaries.

English-only figures retain their existing profile/requested `font_name`
behavior, including ordinary overrides. For CJK figures, `mpResolveFont`:

1. Discovers actual inventory through MATLAB `listfonts`.
2. Accepts the requested/profile font only if its exact, case-sensitive name
   belongs to both the governed candidate list and the runtime inventory.
3. Otherwise selects the first available governed candidate in policy order.
4. Raises `matlab_sci_plot:CJKFontUnavailable` if none is available.

Both preview and final governed export stop on this error. Arbitrary installed
fonts do not acquire CJK capability merely by being requested. No particular
candidate is mandatory. A machine with no candidate needs a separately managed
font prerequisite before it can produce CJK artifacts.

`mpApplyTypography` runs after text creation and scientific audit, before export.
For CJK it applies one font with `fontname(fig, resolvedFont)` to the hierarchy,
including axes, labels, legends and titles. `mpApplyStyle` retains size,
linewidth, tick and grid responsibilities. Family renderers contain no CJK
branches. Font inventory can be supplied as a test seam to `mpResolveFont`,
`mpApplyTypography`, or the optional seventh argument of `mpRenderFigure`;
normal callers omit that argument and use runtime discovery.

## Scientific symbols and literal identifiers

Unicode units such as `°C`, `μm` and `W/(m·K)` pass through unchanged. Real R2023b
testing confirmed that default TeX turns `样品_A` into a subscript. The narrow
repair applies to ordinary text objects (axis labels, titles and annotations)
whose current interpreter is `tex`: CJK text containing `_`, and none of the
explicit TeX markers `\`, `^`, `{` or `}`, uses `Interpreter='none'`.
The original `String` is preserved.

English formulas and explicitly marked TeX keep their existing interpretation;
for example, use `温度 T_{i}` when a subscript is intended. Legend and tick
interpreters retain native behavior; do not assume literal underscore/backslash
handling on those surfaces. General mixed-font or full Unicode shaping support
is outside this increment.

## Export and evidence

`mpRenderFigure -> mpExport -> mpWriteEvidence` retains native `exportgraphics`
PNG and vector PDF output. The renderer returns `result.typography` and passes
that exact state to `manifest.typography`, recording:

- `contains_cjk`;
- `requested_font` and actual `resolved_font`;
- `font_policy_id`, `policy_version` and `resolution` (`requested_english`,
  `requested_cjk` or `fallback_cjk`).

The optional sixth `mpWriteEvidence` argument preserves existing callers.
Omitted state stays absent; it is never invented from the profile. Supplied
state must be internally consistent with the governed policy. Existing source,
version, candidate, renderer, family, review and SHA-256 fields remain present.
The historical field name `qualification_timestamp` is an export timestamp;
its presence does not establish qualification. JSON evidence is UTF-8.

`listfonts`, a matching manifest and file-existence checks do not establish PDF
font embedding or glyph correctness. Never rasterize vector output to hide font
problems, hide scientific labels, or modify data/units to obtain an export.

## Running runtime checks

Run the Python suite after installing `requirements-test.txt`. With MATLAB,
use explicit repository and temporary output paths:

```matlab
root = pwd; % repository root
addpath(genpath(root));
out = fullfile(tempdir, 'matlab_cjk_builder');
run_matlab_contract_smoke(root, fullfile(out,'contracts'));
run_matlab_typography_smoke(root, fullfile(out,'typography'));
run_matlab_evidence_smoke(root, fullfile(out,'evidence'));
run_matlab_smoke(root, fullfile(out,'english'));
run_matlab_qualification(root, fullfile(out,'scientific_regression'));
run_matlab_cjk_smoke(root, fullfile(out,'cjk'), candidateSha);
```

Set `candidateSha` to the exact clean commit reported by `git rev-parse HEAD`
before running. The CJK entrypoint reports 11 cases individually and writes a
`cjk_smoke_report.json` plus temporary PNG/PDF/manifest/contract fixtures. Its
fallback export needs an actually available candidate after the first policy
entry; resolver controls use injected inventories without changing system fonts.
Missing MATLAB is `SKIPPED_UNAVAILABLE`, never PASS. A font prerequisite error
also remains a failure, not a successful smoke run.

The existing `run_matlab_qualification` is used here solely as an English and
scientific regression entrypoint. Neither it nor `run_matlab_cjk_smoke` alone
reproduces the independent visual/PDF qualification in Issue #44. See the
[v1.2.0 release notes](../docs/RELEASE_NOTES_V1.2.0.md) for the released scope.
