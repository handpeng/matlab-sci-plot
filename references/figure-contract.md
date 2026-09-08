# Figure Contract

The Figure Contract is the semantic handoff from research intent to planning. It uses `contract_type=figure_contract` and `contract_version=1.0` and references external data by source identity and bindings. Bindings may name truth, prediction, ordered, group, category, identifier, uncertainty, or matrix roles. Unknown units, replicate meaning, causal meaning, and uncertainty semantics stay unknown.

The contract records purpose, primary/secondary claim, sample and missing-data policy, declared transformations, target profile, final physical width, visual priorities, prohibited encodings, and provenance. MATLAB handles and renderer objects are forbidden. See `schemas/figure_contract.schema.json`.

Governed runtime fields include Unicode `labels`/`units` and role string maps,
`communication_task`, composite `panels` and `panel_label`, layout/final size,
and existing scientific audit controls. An empty parent `data_bindings` is
valid only with nonempty recursively valid panels. Unknown top-level and panel
fields fail closed. Python validates the same schema; native planning retains
its precondition of a structurally validated contract.

See [reconciliation audit](../docs/CJK_CONTRACT_RECONCILIATION.md) for the
baseline drift and [Chinese fixture](../examples/chinese_temperature_property.json)
for a synthetic example. Unicode acceptance does not qualify rendering; the
[typography policy](typography.md) describes detection, font resolution and
the Windows MATLAB R2023b qualification boundary.
