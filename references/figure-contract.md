# Figure Contract

The Figure Contract is the semantic handoff from research intent to planning. It uses `contract_type=figure_contract` and `contract_version=1.0` and references external data by source identity and bindings. Bindings may name truth, prediction, ordered, group, category, identifier, uncertainty, or matrix roles. Unknown units, replicate meaning, causal meaning, and uncertainty semantics stay unknown.

The contract records purpose, primary/secondary claim, sample and missing-data policy, declared transformations, target profile, final physical width, visual priorities, prohibited encodings, and provenance. MATLAB handles and renderer objects are forbidden. See `schemas/figure_contract.schema.json`.
