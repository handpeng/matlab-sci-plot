# V1 Data and Analysis Boundary

Status: Stage 1 architecture contract.

## 1. Purpose

A scientific figure Skill must distinguish **visualization** from **scientific analysis**. The renderer may perform declared display transformations and simple deterministic summaries, but it must not silently become a second analysis pipeline whose calculations are invisible to the research workflow.

This boundary is especially important because the legacy templates currently compute items such as RMSE, MAE, `R^2`, linear fits, KDEs, and interval-like bands inside plotting scripts.

## 2. Data ownership

Raw research data remains external to the Skill repository and external to machine-readable Figure Contract payloads unless a small synthetic fixture is intentionally embedded for tests/examples.

A Figure Contract should reference or bind:

- source path/identifier supplied by the caller;
- table/sheet/variable selectors;
- semantic column roles;
- units/labels;
- sample/group identifiers;
- optional source hash or upstream artifact identity.

The contract should not duplicate an entire private dataset merely to plan a figure.

## 3. Analysis authority

The Skill recognizes three calculation classes.

### Class A — presentation-only transformations

Allowed in the rendering layer when declared or deterministic, for example:

- sorting display order;
- finite-value masking consistent with the Figure Contract;
- axis/unit display conversion explicitly specified by the contract;
- jitter used only for visibility and never stored as scientific values;
- density estimation used only as a display representation;
- layout-normalized coordinates;
- color normalization;
- label abbreviation/wrapping.

These operations must not change the underlying scientific observation or reported statistic.

### Class B — standard descriptive/view summaries

May be computed by a shared, tested analysis-helper boundary when required by a figure and when the definition is explicit, for example:

- count `n`;
- mean/median/quantiles;
- RMSE/MAE using a defined common sample set;
- `R^2` with a documented formula;
- ECDF;
- deterministic histogram counts/edges;
- deterministic KDE parameters recorded in the plan/report.

Rules:

- definitions live in one shared helper layer, not duplicated across figure families;
- parameters and sample masks are recorded;
- derived values are made available to audit/provenance;
- the same derived statistic must not have family-specific formulas.

### Class C — inferential/modeling analysis

Not silently authorized by visualization. Examples:

- fitting a new predictive model;
- hypothesis tests;
- bootstrap confidence intervals not already specified by the research workflow;
- causal analysis;
- SHAP computation from a model;
- feature selection;
- calibration model fitting;
- regression chosen only because a plotting template contains `fitlm`;
- inventing a “95% band” from residual standard deviation without an explicit uncertainty definition.

Class C requires one of:

1. an upstream analysis artifact supplied by the caller; or
2. explicit Figure Contract authorization naming the method/parameters and a tested analysis adapter.

Absent that authority, the Skill must omit the inferential layer or report that it cannot be drawn truthfully.

## 4. Separation of components

Recommended boundary:

```text
external data / upstream analysis
        |
        v
Data Binding + Figure Contract
        |
        +--> shared descriptive helpers (Class B only)
        |
        v
Figure Plan
        |
        v
Renderer (Class A presentation operations)
```

Figure-family renderers consume already-resolved data bindings and derived summaries. They should not contain ad hoc statistical formulas.

## 5. Missing-data and common-sample policy

For direct model comparison:

- default to a shared valid mask across truth and all compared predictions;
- record `n_common`;
- if model-specific masks are explicitly required, record each `n` and prevent the figure from implying identical evaluation populations.

A renderer must not silently drop rows for convenience beyond the declared missing-data policy.

## 6. Regression and parity plots

A parity plot does not automatically authorize a fitted regression or an uncertainty band.

Default valid elements:

- observed/predicted points;
- `y = x` reference;
- declared performance summaries.

Optional regression/interval elements require explicit semantics:

- regression method;
- whether the line is descriptive or inferential;
- interval type (confidence interval, prediction interval, bootstrap interval, etc.);
- sample definition.

A generic `95% Band` label is invalid.

## 7. Distribution plots

Histogram/KDE/violin/raincloud visual density operations must disclose or persist relevant display parameters when they materially affect appearance:

- bin edges/rule;
- bandwidth/method;
- normalization;
- jitter policy/seed if randomized.

Raw points must not be randomly jittered in a way that can be mistaken for values on a meaningful numeric axis.

## 8. Explainability boundary

V1 may support rendering precomputed feature-importance or SHAP-like artifacts without requiring the plotting Skill to train or explain the model itself.

For future SHAP/PDP/ICE support:

- upstream computed explanation arrays are preferred;
- computation adapters, if later added, are separate capabilities with explicit dependencies/versioning;
- the renderer never fabricates explanation values from feature order or model predictions.

## 9. Provenance requirements

When the Skill computes a Class B summary, the figure manifest/report must be able to record:

- helper/statistic id and version;
- formula/method identifier;
- input role bindings;
- valid sample count/mask policy;
- parameters (bins, bandwidth, etc. where applicable);
- resulting summary values or a referenced machine-readable summary artifact.

## 10. Legacy migration implications

During Stage 2 migration:

- RMSE/MAE/`R^2` formulas are moved out of family renderers into shared tested helpers;
- negative `R^2` values are preserved;
- legacy `fitlm` behavior is not automatically preserved as a default parity feature;
- ambiguous legacy “95% bands” are removed, renamed only when semantics can be proven, or made opt-in through an explicit interval contract;
- KDE/histogram parameters become inspectable/reproducible;
- legacy scripts remain evidence of historical use cases, not authorities for statistical definitions.

## 11. Acceptance tests

Stage 2 must include negative controls proving that:

1. a parity request without uncertainty metadata cannot silently generate a 95% uncertainty band;
2. model comparison uses a common valid mask by default;
3. `R^2 < 0` survives calculation and rendering planning;
4. two figure families requesting the same metric receive the same shared helper result;
5. a renderer cannot silently invoke an undeclared Class C method;
6. distribution display parameters are represented in the plan/report when used;
7. precomputed explainability values can be rendered without coupling the core to a specific ML framework.
