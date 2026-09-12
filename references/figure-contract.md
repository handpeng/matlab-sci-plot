# Figure Contract

The Figure Contract is the semantic handoff from research intent to planning. It uses `contract_type=figure_contract` and `contract_version=1.0` and references external data by source identity and bindings. Bindings may name truth, prediction, ordered, group, category, identifier, uncertainty, or matrix roles. Unknown units, replicate meaning, causal meaning, and uncertainty semantics stay unknown.

The contract records purpose, primary/secondary claim, sample and missing-data policy, declared transformations, target profile, final physical width, visual priorities, prohibited encodings, and provenance. MATLAB handles and renderer objects are forbidden. See `schemas/figure_contract.schema.json`.

Governed runtime fields include Unicode `labels`/`units` and role string maps,
`communication_task`, composite `panels` and `panel_label`, layout/final size,
and existing scientific audit controls. An empty parent `data_bindings` is
valid only with nonempty recursively valid panels. Unknown top-level and panel
fields fail closed. Python validates the same schema; native planning retains
its precondition of a structurally validated contract.

An explicitly declared relationship may add
`required_relationship`, `required_data_roles`, `pairing_requirement`,
`relationship_representation`, `minimum_data_requirement`,
`allowed_transformations`, and `annotation_roles`. V1 recognizes the
provider-neutral `distance -> error` relationship (also written
`distance_to_error`) and requires its `distance` and `error` roles to be bound.
`pairing_requirement=paired` must use `paired_observations`; an aggregate form
must use `pairing_requirement=aggregate` together with the explicit
`authorized_aggregate` representation. Summary roles such as `rho`, `p`, and
`n` are annotations and cannot replace the required relationship roles.

Contracts without `required_relationship` retain their historical semantics;
the additive fields cannot be supplied as orphaned authority. The validator
rejects unknown relationship identities, role-binding mismatches, missing
pairing declarations, unauthorized transformations, and annotation/required
role overlap before planning.

See [reconciliation audit](../docs/CJK_CONTRACT_RECONCILIATION.md) for the
baseline drift and [Chinese fixture](../examples/chinese_temperature_property.json)
for a synthetic example. Unicode acceptance does not qualify rendering; the
[typography policy](typography.md) describes detection, font resolution and
the Windows MATLAB R2023b qualification boundary.
