# CJK Stage 2 Builder handoff

Status: `IMPLEMENTED_PENDING_STAGE3`. Planning authority is PR #31, merged as
`e43ad8984da2232a22d172e209395008053c3e23`; the frozen plan is `TODO.md`.
The repository release version remains `1.1.1`. No release or tag is created
by this Builder increment.

## Serial implementation evidence

| Issue | PR | Merge SHA |
| --- | --- | --- |
| #32 contract reconciliation | #38 | `5482e371b183aeac27fa6536216d8bdc35454611` |
| #33 detection/policy | #39 | `9080494bdb540f51c802c38da0fa51d00eacf42f` |
| #34 native typography | #40 | `f6df4525c7df6f35af2e498429e1bbac6eb99647` |
| #35 evidence binding | #41 | `03181f0b736e405c293b96db28df676f5f5dd6fb` |
| #36 CJK smoke | #42 | `f174449406f833b4714e99f8c0e84c5f6a8da694` |

Each predecessor was reviewed, squash-merged at its exact reviewed head,
recorded with test evidence and closed before the next implementation began.
[Issue #37](https://github.com/handpeng/matlab-sci-plot/issues/37) records this
documentation PR, its exact reviewed head/merge SHA, and the final merged
candidate validation. That closing evidence is the authoritative final SHA;
this document cannot embed the hash of its own future merge commit.

## Builder validation and limits

The non-MATLAB suite contains 52 tests, including independent Draft 2020-12
schema checks, UTF-8 round-trip, unknown-field controls, Unicode range/boundary
tests, font policy ordering, English/scientific-state preservation and evidence
validation. Native tests ran on Windows MATLAB R2023b (`23.2.0.2365128`).

The dedicated CJK smoke reports 11 cases: axes, legend, categories, mixed
scientific symbols, panel titles, explicit font, fallback, no-font failure,
literal underscore, grouped scatter and feature-name ticks. Ten successful
cases create PNG/vector PDF and manifests; the no-font case produces a specific
failure without an output directory. Runtime discovery on the Builder machine
resolved `Microsoft YaHei UI`. Candidate names/order remain solely in the
[policy manifest](../policies/cjk_typography.json).

Existing English smoke covers five native families. The existing scientific
regression preserves negative R2 (`-3`), six audit negative controls and the
two-panel narrative. The new contract, typography and evidence smoke entrypoints
cover UTF-8/native planning, figure-wide font application, preview/final no-font
failure, evidence binding, original evidence callers and malformed state.
Actual temporary manifests/contracts were independently schema/Python checked
and output SHA-256 hashes recomputed.

Generated artifacts stay in temporary output directories, not Git. The final
run supplies the exact merged candidate SHA to `run_matlab_cjk_smoke`; see
[running checks](../references/typography.md#running-builder-checks).

`CJK_FINAL_QUALIFICATION=NOT_PERFORMED`.
`RELEASE_QUALIFICATION=NOT_PERFORMED`.
`RELEASE_CREATED=NO`.

The smoke review objects and file checks establish technical execution only.
They do not qualify Chinese glyphs, PDF font embedding, publication legibility,
other operating systems or releases. The next stage is
`INDEPENDENT_STAGE3_CJK_QUALIFICATION`, under separate authority, on the exact
merged candidate recorded in #37. Stage 2 does not initiate that stage.
