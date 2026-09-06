# V1 Extension and Compatibility Contracts

Status: Stage 1 architecture contract.  
Purpose: ensure V1 can grow in figure breadth, journal profiles, domain patterns, review rules, and rendering backends without rewriting the core planner.

## 1. Contract versioning

Every machine-readable boundary introduced in V1 must carry an explicit schema/contract version.

Minimum versioned boundaries:

- Figure Contract;
- Figure Plan;
- figure-family manifest;
- style/profile manifest;
- review record;
- evidence/provenance manifest.

Rules:

- use explicit versions such as `1.0`, not implicit repository commit semantics;
- readers must reject unsupported major versions rather than guessing;
- additive optional fields may be accepted within a compatible major version;
- required semantic changes require a major-version change;
- generated artifacts record both contract version and Skill version;
- migrations, when introduced, are explicit functions/tools rather than silent reinterpretation.

## 2. Figure-family plugin contract

Each figure family must expose declarative metadata separate from rendering code.

Conceptual fields:

```text
id
version
communication_tasks
data_roles_required
data_roles_optional
sample_constraints
supports_grouping
supports_uncertainty
supports_small_multiples
supports_shared_color_scale
recommended_layout_primitives
incompatible_encodings
renderer_backend
renderer_entrypoint
capabilities
status
```

The planner ranks compatible families from metadata/capabilities. It must not require edits to a central list of family-specific `if/elseif` rules beyond registry discovery.

A renderer receives a validated Figure Contract + Figure Plan + resolved Style object. It does not infer publisher policy independently.

## 3. Backend adapter contract

MATLAB is the V1 primary backend, but the semantic/planning architecture must support a future backend adapter interface.

Conceptual backend capabilities:

```text
backend_id
backend_version
available
supported_family_ids
vector_formats
raster_formats
layout_capabilities
font_capabilities
interactive_capabilities
optional_dependencies
```

V1 requirements:

- implement MATLAB as the default backend;
- do not implement another backend merely to prove abstraction;
- keep backend-specific calls below the rendering boundary;
- never make Figure Contract fields depend on MATLAB object handles;
- planner output refers to semantic family/layout/style ids, not concrete MATLAB handles;
- if a requested capability is unsupported, fail or choose an explicitly compatible alternative; never silently degrade scientific meaning.

Future examples that should fit without core semantic redesign:

- `gramm` adapter for grouped/faceted MATLAB plots;
- Python/Matplotlib adapter;
- R/ggplot2 adapter.

These are extension targets, not V1 dependencies.

## 4. Style/profile composition contract

Resolve style in this order:

```text
universal scientific constraints
  -> general publication style
  -> destination preset (single/double/thesis/presentation)
  -> publisher/journal profile
  -> figure-family scoped defaults
  -> explicit user-safe overrides
```

Rules:

- later layers may refine presentation but may not override scientific-integrity constraints;
- profile values are declarative and dated;
- unknown profile fields fail validation rather than being ignored silently;
- palette ids and semantic color roles are stable references; raw RGB values are implementation details;
- family-specific style additions must be namespaced so they do not pollute global style objects.

## 5. Audit-rule extension contract

Audit rules are registered independently from families.

Conceptual rule metadata:

```text
code
version
severity
scope
requires_rendered_image
requires_data_summary
applicable_family_ids
check_entrypoint
repairable
allowed_repair_ids
```

Severity classes:

- `error`: scientific or publication integrity failure; finalization blocked;
- `warning`: material quality concern requiring disclosure/review;
- `info`: advisory improvement.

Hard scientific rules cannot be downgraded by a style profile.

## 6. Controlled-repair extension contract

Repairs must be explicit, allow-listed, bounded operations on presentation state.

Allowed repair domains may include:

- typography scale within supported range;
- line/marker scale;
- legend placement or conversion to shared/dedicated legend;
- grid enable/disable;
- palette substitution preserving semantic roles;
- panel spacing/layout primitive adjustment;
- explicit zero-baseline enforcement when the encoding requires it;
- label wrapping/abbreviation when meaning is preserved.

Forbidden repair domains:

- source values;
- model predictions;
- computed metrics;
- sample membership/filtering;
- uncertainty values/type;
- grouping labels or scientific categories;
- regression/statistical method;
- axis transformations not authorized by the Figure Contract.

Each repair record must state what changed and why.

## 7. Domain-pattern contract

Domain packages such as `metallurgy/` are composition/routing layers, not renderer forks.

A domain pattern may define:

- vocabulary aliases (e.g. heat, batch, temperature regime, composition);
- recommended evidence sequences;
- common Figure Contract presets;
- domain-specific audit recommendations;
- mappings from research questions to generic families.

A domain pattern may not duplicate a generic parity, residual, trend, distribution, or heatmap renderer merely to change labels/colors.

Example composition:

```text
metallurgy.external_generalization
  -> prediction.parity_by_group
  -> comparison.regime_error
  -> distribution.error_ecdf
  -> layout.hero_plus_diagnostics
```

## 8. Publisher-profile lifecycle

Publisher/profile records must include lifecycle metadata:

```text
profile_id
profile_version
checked_at
source_urls
scope
status
supersedes
notes
```

Status values should distinguish at least:

- `active_snapshot`;
- `stale_review_required`;
- `deprecated`.

A stale profile does not become a scientific failure; it becomes a publication-compliance warning requiring live verification before submission.

## 9. Capability negotiation

Planning and rendering must use explicit capability checks.

Examples:

- a family requiring density estimation must declare whether it can use a native fallback without Statistics Toolbox;
- an SVG request must be checked against the running MATLAB version/backend capability;
- a SHAP family may accept precomputed SHAP values but must not pretend MATLAB can compute them if no computation path is present;
- a journal profile requesting a specific export property must report when the backend cannot verify it.

No optional dependency may turn an unavailable feature into a false PASS.

## 10. Legacy compatibility

The 17 initial `scripts/template_*.m` files are legacy assets.

V1 must maintain a migration table with, for every legacy template:

- source path;
- new family/layout mapping;
- scientific issues found;
- compatibility status;
- replacement example;
- deprecation status.

Compatibility statuses:

- `mapped`;
- `mapped_with_behavior_change`;
- `legacy_only`;
- `deprecated`.

Unsafe behavior is not preserved for backward compatibility.

## 11. Dependency policy

Core normal path:

- MATLAB built-ins;
- native `tiledlayout` / `nexttile`;
- native `exportgraphics` where supported.

Optional dependencies are isolated behind adapters/capability checks. The core must remain usable when optional packages are absent.

Do not vendor third-party code merely for convenience in V1.

## 12. Knowledge-loading policy

The Skill must remain concise and load detailed references on demand.

Recommended routing:

- `SKILL.md`: activation, high-level workflow, safety boundaries;
- Figure Contract questions -> `references/figure-contract.md`;
- chart choice -> `references/chart-selection.md`;
- panel design -> `references/panel-layout.md`;
- appearance -> style/typography/color references;
- uncertainty -> `references/uncertainty.md`;
- scientific risk -> integrity/anti-pattern references;
- metallurgy use cases -> `references/metallurgy-patterns.md`.

Do not preload every reference for every figure request.

## 13. V1 extensibility acceptance tests

Stage 2 must demonstrate that the architecture is genuinely extensible, not merely described as extensible.

At minimum tests/fixtures must prove:

1. two or more families can register/discover without family-specific central branching;
2. adding a synthetic test family through the registry does not require changes to an unrelated renderer;
3. at least two profiles compose over the same base style without editing family code;
4. an unsupported major schema version fails closed;
5. an optional capability can be unavailable without breaking unrelated families;
6. one domain metallurgy pattern composes generic families without duplicated renderer code;
7. legacy mapping covers all 17 initial templates;
8. scientific-integrity rules remain authoritative after profile/style resolution.

## 14. Scope discipline

V1 should prove the contracts with representative capabilities rather than maximize breadth. New chart families belong in later increments once the registration, style, review, and compatibility boundaries have passed independent Stage 3 qualification.
