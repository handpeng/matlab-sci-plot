# matlab-sci-plot v1.1.0

Version 1.1.0 is the first qualified V1 implementation of the repository's
contract-first, MATLAB-first scientific figure architecture.

## Highlights

- Scientific intent is carried from a versioned Figure Contract into a Figure
  Plan, registry-selected MATLAB renderer, semantic style, native export,
  scientific review, and evidence manifest.
- MATLAB-native production renderers cover prediction parity, relationship
  scatter, metric comparison panels, distributions, trends, and precomputed
  explainability. Metallurgy patterns compose these generic families.
- Scientific gates preserve negative R2, require explicit uncertainty
  semantics and sample disclosure, reject unsafe quantitative rainbow palettes,
  and prevent presentation repairs from changing scientific values.
- Final-size layouts use `tiledlayout`, semantic panel narratives, shared style
  resolution, and native PNG/PDF export.

## Qualification

Stage 3 qualification was performed with MATLAB R2023b
(`23.2.0.2365128`) using a fixed-seed synthetic hot-work tool-steel benchmark.
The benchmark data are synthetic and are not experimental measurements.

Qualification evidence recorded:

- 8/8 positive native MATLAB cases passed;
- 13/13 scientific negative controls passed, including a fail-closed dense
  categorical case;
- 8 PNG and 8 vector PDF outputs passed artifact and manifest checks;
- 8/8 evidence manifests and 78 aggregate SHA-256 entries verified;
- final-size visual review mean score 4.55/5.00, minimum 4.40/5.00;
- 36 non-MATLAB tests and legacy migration coverage 17/17 passed.

Release qualification is performed again on the exact merged version-bump
commit before the `v1.1.0` tag is created. Qualification artifacts remain
outside the Git repository because they include generated PNG/PDF outputs.

## Compatibility

The repository version is `1.1.0`. Figure Contract, Figure Plan, family/style
manifests, review records, and evidence manifests remain on schema major version
`1.0`; unsupported schema major versions continue to fail closed.

No optional plotting package is promoted to a mandatory dependency. MATLAB is
the V1 production backend; Python utilities remain planning, validation, and
test support rather than a substitute production renderer.
