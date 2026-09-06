# MATLAB SCI Plot V1 — Governance Plan

Status: **Stage 1 governance plan**  
Baseline: `a5920d3b200d5df7d3e0139c76ecb93bef0fe230`  
Scope: architecture and implementation contract only; no Stage 2 implementation is authorized by this file itself.

## 1. Goal

Evolve the repository from a collection of reusable MATLAB figure templates into a research-aware scientific figure design Skill that can accept **data + research context + intended scientific claim + optional publication target**, then plan, render, review, repair, and export a truthful publication-ready figure.

The design must remain MATLAB-first without coupling scientific reasoning to MATLAB syntax. Scientific semantics, figure planning, style policy, publisher profiles, render review, and figure-family registration must be separable so later backends or new figure families can be added without rewriting the core.

## 2. Non-goals for V1

V1 does **not** attempt to:

- implement every possible scientific chart type;
- reproduce or vendor external plotting repositories;
- turn publisher snapshots into permanent compliance claims;
- require `gramm`, `tight_subplot`, `export_fig`, or other third-party packages for the normal path;
- infer missing uncertainty, causal structure, units, or domain meaning from column order alone;
- perform image beautification that alters or hides scientific evidence.

## 3. Architecture invariants

### 3.1 Layer boundaries

The system must be split into five independently evolvable layers:

1. **Scientific semantics** — data roles, sample structure, claim, uncertainty, transformations, integrity rules.
2. **Figure planning** — candidate figure families, panel narrative, visual encoding, final-size target.
3. **Style system** — typography, geometry, semantic color, accessibility, journal/profile overrides.
4. **MATLAB rendering** — native plotting primitives, figure families, layout realization, export.
5. **Review and evidence** — rendered-image review, scientific audit, controlled repair, provenance.

No figure family may hard-code publisher policy or global scientific policy. No publisher profile may contain plotting logic. No review rule may silently mutate scientific data.

### 3.2 Extension contracts

New capabilities must be addable through registries/contracts rather than central conditional chains:

- **figure family**: metadata + compatibility predicate + renderer;
- **style profile**: declarative override of a general style contract;
- **palette**: semantic palette metadata + values;
- **publisher profile**: dated source metadata + final-size/export constraints;
- **audit rule**: code + severity + deterministic check where possible;
- **repair action**: bounded allow-listed visual repair that cannot alter source data or scientific results.

A new figure family should not require editing unrelated renderer files. A new journal profile should not require editing figure-family code.

## 4. Figure Contract

Introduce a machine-readable Figure Contract as the primary interface between scientific intent and rendering. At minimum it must represent:

- figure purpose: manuscript main figure, supplement, thesis, report, presentation;
- scientific claim: primary and optional secondary claims;
- data roles: truth, prediction, ordered variable, group, category, identifier, uncertainty bounds, matrix;
- units and labels;
- sample/replicate structure and comparison policy;
- missing/excluded-data policy;
- transformations already applied or requested;
- uncertainty type, if known;
- target profile and final physical width;
- visual priorities and prohibited encodings;
- provenance identifiers for source data and generated outputs.

Unknown scientific semantics must stay unknown. The planner may request clarification or select a conservative figure; it must not invent them.

## 5. Scientific integrity rules

V1 must make the following defaults explicit and testable:

- never clip negative `R^2` to zero;
- never hide, invent, selectively remove, or visually suppress observations to improve appearance;
- do not use rainbow/`jet` as the default for ordered quantitative data;
- model comparisons must use a common valid sample set by default, or explicitly disclose differing `n`;
- uncertainty must be named (e.g. SD, SE, CI, prediction interval, bootstrap interval); a generic “95% band” is insufficient;
- bar/area encodings normally require a meaningful zero baseline;
- dual-y-axis designs are exceptional and require an explicit semantic justification;
- missing, zero, censored, and excluded values must not be conflated;
- shared comparative panels should use shared scales/color normalization unless a justified exception is explicitly marked;
- units are required for physical quantities when known;
- continuous small-sample data should expose individual observations when feasible instead of defaulting to summary bars;
- visual repair may change presentation, not scientific values or analysis outputs.

## 6. Figure-family taxonomy

Organize figure capabilities by **scientific communication task**, not historical template filename.

Initial V1 family groups:

- `prediction/`: parity, density parity, residual companion;
- `comparison/`: metric panels, ranked dot/point-range, grouped comparison;
- `distribution/`: histogram/KDE, box+points, violin/raincloud-ready contract, ECDF-ready contract;
- `trend/`: line, multi-line, uncertainty band, segmented/zoomed trend;
- `relationship/`: scatter, grouped scatter, regression/density variants;
- `explainability/`: feature-importance base with extension points for SHAP/PDP/ICE;
- `matrix/`: heatmap/correlation-ready contract;
- `optimization/`: extension point for Pareto/response-surface families;
- `metallurgy/`: domain patterns assembled from generic families, not duplicated plotting code.

Existing templates are migration inputs, not permanent architecture boundaries.

## 7. Panel narrative engine

Provide reusable layout primitives rather than `N -> rows x columns` only:

- `single`;
- `paired`;
- `triptych`;
- `hero_plus_diagnostics`;
- `overview_plus_small_multiples`;
- `small_multiples`;
- `legend_panel`.

Rules:

- reading order follows the scientific argument;
- main evidence may receive more area than diagnostics;
- comparable panels share axes/scales where comparison requires it;
- repeated labels are removed from interior panels;
- shared legends/colorbars are preferred when semantics are shared;
- panel letters use one consistent placement and typography;
- white space is intentional; panels must not be packed merely to fill a page.

MATLAB `tiledlayout` is the V1 normal-path layout primitive. `tight_subplot` remains legacy-compatible only.

## 8. Style system

Style must be compositional rather than one global hard-coded “SCI style”.

### 8.1 Style layers

1. semantic visual roles;
2. typography;
3. geometry (line/marker/spine/grid/spacing);
4. color semantics;
5. target profile overrides.

### 8.2 Final-size design

Figures are designed for final physical width, not A4-window dimensions. General presets should include at least:

- `single_column`;
- `double_column`;
- `thesis_textwidth`;
- `presentation`.

Publisher-specific widths remain dated profile data.

### 8.3 Color

Provide semantic roles such as:

- observed/reference;
- proposed/highlight;
- baseline/comparator;
- positive/negative;
- uncertainty;
- missing/out-of-range.

Include colorblind-aware categorical and perceptually ordered sequential/diverging palettes. Color must not be the only distinguishing channel when print/accessibility requires redundancy.

### 8.4 Grid, spines, legend

- grid is conditional, not globally enabled;
- use minimal spines by default unless a profile/task calls for a box;
- prefer direct labels for very small series counts when practical;
- prefer shared legends for multi-panel figures;
- allow a dedicated legend tile when a legend would occlude data.

## 9. Publisher/profile architecture

Create declarative dated profiles under `profiles/` for general publication and selected publisher/journal families. Each non-general profile must store:

- `checked_at` date;
- authoritative source URL(s);
- intended phase/scope;
- physical-size/font/export constraints that can be represented safely;
- notes marking guidance that still requires live verification.

Profiles are planning snapshots, not compliance certificates. Universal scientific rules live outside profiles.

## 10. MATLAB rendering architecture

Target structure:

```text
matlab/
  core/
    mpInspectData.m
    mpInferRoles.m
    mpPlanFigure.m
    mpBuildLayout.m
    mpApplyStyle.m
    mpExport.m
    mpAudit.m
  families/
    prediction/
    comparison/
    distribution/
    trend/
    relationship/
    explainability/
    matrix/
    optimization/
    metallurgy/
  palettes/
```

Normal-path implementation should use native MATLAB first:

- `readtable` / import options for tabular input;
- `tiledlayout` / `nexttile` for layout;
- native plotting primitives for V1 families;
- `exportgraphics` for PDF/SVG/PNG where supported.

Third-party plotting packages may be adapters, never required core dependencies.

## 11. Render-review-repair contract

Publication-facing tasks must not stop at code generation.

Workflow:

1. inspect data;
2. build Figure Contract;
3. generate 2–3 semantically valid candidate plans when ambiguity is material;
4. render candidate PNGs;
5. review every candidate at intended final size;
6. run scientific-integrity audit;
7. select `accept`, `repair`, or `reject`;
8. apply only allow-listed visual repairs;
9. rerender and reaudit;
10. export final vector/raster artifacts plus report and manifest.

Review dimensions:

- scientific correctness — hard PASS/FAIL;
- claim support;
- statistical transparency;
- perceptual clarity;
- layout hierarchy;
- accessibility;
- style consistency;
- final-size legibility;
- reproducibility.

Initial repair actions may include font/marker/line-size adjustment, legend relocation, grid enable/disable, palette substitution, spacing/layout correction, and zero-baseline enforcement when semantically required. Repairs must never alter data values, calculated metrics, filtering, uncertainty, or model results.

## 12. Outputs and provenance

A completed figure task should be capable of producing:

```text
figure_plan.json
figure_script.m
candidate_*.png        # when candidate review is used
figure_preview.png
figure.pdf
figure.svg
figure.png
figure_review.md
figure_manifest.json
```

Manifest fields should include source-data identity/hash when available, Skill version, MATLAB version, profile/style, final dimensions, selected palette, transformations/exclusions supplied to the figure contract, uncertainty definition, candidate/review result, and output hashes where practical.

## 13. Migration policy for current templates

The existing scripts are preserved as historical working examples during V1 migration. Stage 2 must:

- map every existing template to a new family or mark it `legacy_only` with rationale;
- remove scientifically unsafe defaults during migration (negative-R2 clipping, unconditional `jet`, ambiguous uncertainty labels, default dual-axis promotion);
- avoid a flag-day deletion of all old scripts;
- add compatibility examples showing how old use cases are expressed through the new planner/family API;
- delete or deprecate legacy templates only after equivalent behavior is tested.

## 14. Documentation structure

V1 should move detailed knowledge out of a monolithic `SKILL.md`:

```text
SKILL.md
references/
  figure-contract.md
  chart-selection.md
  panel-layout.md
  style-system.md
  typography.md
  color-system.md
  uncertainty.md
  accessibility.md
  scientific-integrity.md
  anti-patterns.md
  review-contract.md
  metallurgy-patterns.md
profiles/
...
```

`SKILL.md` should focus on activation, workflow, boundaries, and routing to references.

## 15. Test strategy

Stage 2 must add local-first tests; no heavy CI is required for V1.

Minimum gates:

- repository structure and registry consistency;
- Figure Contract schema validation;
- data-role inference fixtures;
- family compatibility/selection fixtures;
- scientific anti-pattern negative controls;
- style/profile schema validation;
- layout primitive smoke tests;
- MATLAB render smoke tests on synthetic data when MATLAB is available;
- graceful skip/report when MATLAB is unavailable;
- export existence/metadata checks;
- legacy-template mapping completeness;
- deterministic plan/review fixtures where possible;
- `git diff --check` and clean-worktree handoff.

Synthetic or clearly redistributable data only in repository tests/examples.

## 16. Stage 2 work packages

Stage 2 is one continuous Builder sequence. Complete these in order unless a hard blocker is discovered:

### WP1 — Repository skeleton and contracts

Create the modular directory structure, Figure Contract schema, registries, profile schema, and concise `SKILL.md` routing surface.

### WP2 — Scientific integrity and data inspection

Implement data inspection/role inference and machine-checkable anti-pattern rules. Correct unsafe behavior inherited from current templates.

### WP3 — Style, palette, final-size, and profile engine

Implement compositional style objects/presets, semantic palettes, final-size calculation, and dated general/publisher profiles.

### WP4 — Panel narrative/layout engine

Implement layout primitives and shared label/legend/colorbar policies using `tiledlayout` as the normal path.

### WP5 — Figure-family registry and core families

Implement registry-based family discovery/compatibility and enough representative families to exercise all core contracts: prediction, relationship, comparison, distribution, and trend.

### WP6 — Legacy migration

Map all current templates; migrate safe reusable logic into families; preserve temporary compatibility where needed; explicitly deprecate unsafe/over-specialized defaults.

### WP7 — Render/review/repair/evidence loop

Implement candidate planning/rendering, structured review contract, bounded repair actions, final audit, export report, and provenance manifest.

### WP8 — Explainability and metallurgy extension surfaces

Add a base explainability family and metallurgy pattern layer demonstrating domain composition without coupling domain rules into generic rendering. Leave SHAP/ternary/Pareto breadth extensible rather than overbuilding V1.

### WP9 — Tests, examples, and documentation

Add synthetic fixtures, end-to-end examples, local test entrypoints, architecture/reference docs, migration matrix, and troubleshooting.

### WP10 — Stage 2 handoff

Run focused and full local validation, record exact candidate SHA, keep worktree clean, and report `IMPLEMENTED_PENDING_STAGE3`. Do **not** perform final qualification, certification, promotion, release qualification, or Stage 3 repair authority in Stage 2.

## 17. Stage boundaries

### Stage 1 — Governance

Defines and reviews this architecture, merges the exact reviewed planning diff, and creates the implementation issues.

### Stage 2 — Builder

Implements the approved plan as a continuous sequence. It may repair ordinary implementation defects discovered while building, but it must not weaken this governance contract or self-certify the final candidate.

### Stage 3 — Independent qualification and repair

Starts only after Stage 2 produces a merged implementation candidate. It independently qualifies scientific behavior, architecture boundaries, rendering/review behavior, regression safety, and release readiness; any qualification repairs happen under Stage 3 authority.

## 18. Completion criteria for V1 Stage 2

Stage 2 is complete only when:

- the core architecture exists and is documented;
- extension contracts are demonstrated by more than one family/profile;
- unsafe scientific defaults identified in Stage 1 are removed or fail closed;
- all current templates have a migration status;
- representative end-to-end synthetic workflows run from data inspection through export;
- review/evidence artifacts are generated for at least one publication-style example;
- local tests pass or MATLAB-dependent tests are truthfully reported as unavailable/skipped;
- no raw/private user data is committed;
- exact implementation candidate SHA is reported;
- final status is `IMPLEMENTED_PENDING_STAGE3`, never `QUALIFIED`.
