# CJK-I1 contract reconciliation

Audited baseline: `e43ad8984da2232a22d172e209395008053c3e23`.
This records structural contract reconciliation, not CJK rendering qualification.

| Existing consumer | Drift at baseline | Governed resolution |
| --- | --- | --- |
| `mpAxisLabel` and family renderers | `labels` rejected; `units` and `roles` unconstrained | Unicode string maps keyed by runtime role |
| `mpPlanFigure` | `communication_task`, `layout`, `panel_count`, `scale_policy`, `final_size`, `panels` rejected | Describe existing scalar fields, physical dimensions, recursive contracts |
| `mpRenderFigure` composite title | `panel_label` rejected | Unicode string; no speculative top-level title/caption |
| `run_matlab_qualification` composite | Empty parent bindings rejected although bindings live in panels | Empty bindings allowed only with nonempty, recursively valid panels |
| `mpAudit` and Python audit | Existing audit controls/disclosures rejected | Declare consumed flags, limits, counts, unit requirements, uncertainty requests and disclosures; scientific audit still decides scientific validity |
| Existing examples / Class-C gate | `analysis_authorization`, `domain_pattern` rejected | Preserve existing authorization structure and example metadata |
| `mpWriteEvidence` | Provenance carries candidate SHA | Preserve the existing extensible source identity object |
| Python validator | Required envelope only; unknown/malformed fields accepted | Validate Figure Contracts against the same schema with a bounded dependency-free evaluator |
| MATLAB version gate | Native runtime accepts exactly `1.0`; schema accepted arbitrary versions | Figure Contract schema specifies the actual runtime version `1.0` |
| JSON Schema recursive references | Relative schema identity becomes ambiguous on re-entry | Use an absolute schema URI; all references remain local, with no network lookup |

The top-level contract and newly structured surfaces remain closed. Existing
open source-binding and scientific metadata objects retain their established
extension behavior. Registered role keys remain dynamic; their text values
must be strings. No family, renderer, planner selection, audit rule, export
behavior, or numerical data is changed.

`tests/test_contract_schema.py` compares the lightweight Python validator with
Draft 2020-12 JSON Schema validation (test dependency: `jsonschema`). The UTF-8
example is synthetic. `run_matlab_contract_smoke` checks native planning,
labels/units and JSON round-trip, and can export runtime contract shapes into a
temporary directory for the same independent schema validation. Direct MATLAB
planning retains its existing precondition of a structurally validated contract.
