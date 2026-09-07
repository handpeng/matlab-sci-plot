# matlab-sci-plot v1.1.1

Version 1.1.1 is a documentation and release-usability patch for the qualified V1 scientific figure architecture.

## What changed

- Added a root `README.md` that explains purpose, requirements, installation, verification, quick start, local validation, documentation routing, and release pinning.
- Added `docs/installation.md` with user-scoped and repository-scoped Codex Skill installation, compatibility guidance, explicit invocation, upgrade, disable, uninstall, and provenance practices.
- Updated all release-facing installation examples to pin `v1.1.1`.
- Advanced the repository version from `1.1.0` to `1.1.1` and documented the patch in `CHANGELOG.md`.

## Scientific/runtime scope

This patch does **not** change:

- `SKILL.md` execution semantics;
- Figure Contract or Figure Plan schemas;
- family/style manifests;
- MATLAB renderers, registry dispatch, or export behavior;
- scientific-integrity controls;
- review/evidence contracts; or
- the V1 schema major version (`1.0`).

Accordingly, v1.1.1 does not claim a new scientific runtime qualification. Its runtime qualification basis is the independently qualified v1.1.0 implementation.

## Qualification basis inherited from v1.1.0

The underlying V1 runtime was qualified with MATLAB R2023b (`23.2.0.2365128`) using a fixed-seed synthetic hot-work tool-steel benchmark. The benchmark data are synthetic and are not experimental measurements.

The v1.1.0 qualification recorded:

- 8/8 positive native MATLAB cases passed;
- 13/13 scientific negative controls passed;
- 8 PNG and 8 vector PDF outputs passed artifact and manifest checks;
- 8/8 evidence manifests and 78 aggregate SHA-256 entries verified;
- final-size visual review mean score 4.55/5.00, minimum 4.40/5.00; and
- non-MATLAB regression and legacy migration checks passed.

See `RELEASE_NOTES_V1.1.0.md` for the full underlying qualification summary.

## Installation

After the `v1.1.1` tag is published, the recommended user-scoped installation is:

```bash
mkdir -p "$HOME/.agents/skills"
git clone --branch v1.1.1 --depth 1 \
  https://github.com/handpeng/matlab-sci-plot.git \
  "$HOME/.agents/skills/matlab-sci-plot"
```

Verify that `VERSION` prints `1.1.1` and that Codex discovers `matlab-sci-plot` from a supported Skill root.

## Release identity

The maintainer should create the `v1.1.1` tag and GitHub Release only from the exact merged release-preparation commit on `main`. No additional runtime mutation should be introduced between this release-preparation merge and tagging.
