# Installing `matlab-sci-plot` as an Agent Skill

This guide covers local installation, verification, invocation, upgrade, and removal of `matlab-sci-plot` as a standalone Agent Skill.

For production scientific work, prefer an exact qualified release tag rather than a moving branch.

## 1. Choose the installation scope

Current Codex Skill discovery supports the following local scopes:

| Scope | Location | Use case |
| --- | --- | --- |
| User | `$HOME/.agents/skills` | Make the Skill available to the current user across repositories |
| Repository | `$REPO_ROOT/.agents/skills` | Make the Skill available only inside one repository/team workspace |
| Admin | `/etc/codex/skills` | Machine/container-wide managed installation |
| System | Bundled by Codex | Built-in skills managed by OpenAI |

Codex scans repository `.agents/skills` directories from the current working directory upward to the repository root. It also follows symlinked Skill directories.

The current Codex documentation is available at <https://developers.openai.com/codex/skills>.

## 2. Recommended user-scoped installation

The recommended manual installation for an individual user is:

```bash
mkdir -p "$HOME/.agents/skills"
git clone --branch v1.1.0 --depth 1 \
  https://github.com/handpeng/matlab-sci-plot.git \
  "$HOME/.agents/skills/matlab-sci-plot"
```

Resulting layout:

```text
$HOME/.agents/skills/
└── matlab-sci-plot/
    ├── SKILL.md
    ├── VERSION
    ├── schemas/
    ├── manifests/
    ├── matlab/
    ├── profiles/
    ├── references/
    ├── scripts/
    └── tests/
```

Do not copy only `SKILL.md`. This Skill routes into repository-local schemas, manifests, MATLAB renderers, profiles, references, scripts, and tests, so the complete repository is the installable unit.

## 3. Repository-scoped installation

Use repository scope when a project should carry an exact Skill version with its own source control.

From the target repository root:

```bash
mkdir -p .agents/skills
git submodule add \
  https://github.com/handpeng/matlab-sci-plot.git \
  .agents/skills/matlab-sci-plot

git -C .agents/skills/matlab-sci-plot checkout v1.1.0
git add .gitmodules .agents/skills/matlab-sci-plot
```

The parent repository records the exact Skill commit, which is useful for reproducible paper and analysis workflows.

If the target project does not use Git submodules, another acceptable approach is to place a complete copy of the released repository at:

```text
<repo>/.agents/skills/matlab-sci-plot/
```

Keep the installed copy versioned or otherwise provenance-bound to a specific release.

## 4. Compatibility note for older Codex installations

Older Codex setups and the built-in Skill Installer may use:

```text
$CODEX_HOME/skills/<skill-name>
```

with `$CODEX_HOME` commonly defaulting to `~/.codex`.

Current manual authoring/discovery documentation uses `$HOME/.agents/skills` for user scope and `.agents/skills` for repository scope. Prefer those current locations for new manual installations. If an existing Codex installation already manages skills under `$CODEX_HOME/skills`, do not duplicate the same `name: matlab-sci-plot` into multiple discovery roots unless that is intentional.

## 5. Verify the installed files

For a user-scoped install:

```bash
SKILL_ROOT="$HOME/.agents/skills/matlab-sci-plot"

test -f "$SKILL_ROOT/SKILL.md"
test -f "$SKILL_ROOT/VERSION"
test -d "$SKILL_ROOT/matlab"
test -d "$SKILL_ROOT/manifests"
test -d "$SKILL_ROOT/references"

grep -E '^name: matlab-sci-plot$' "$SKILL_ROOT/SKILL.md"
cat "$SKILL_ROOT/VERSION"
```

For v1.1.0 the final command should print:

```text
1.1.0
```

To verify the Git identity:

```bash
git -C "$SKILL_ROOT" describe --tags --exact-match
git -C "$SKILL_ROOT" rev-parse HEAD
```

For the released v1.1.0 installation, `git describe --tags --exact-match` should resolve to:

```text
v1.1.0
```

## 6. Verify Codex discovery

Codex can invoke skills explicitly or implicitly.

For explicit invocation in Codex CLI or the IDE extension, use `/skills` to inspect available skills or type `$` and select/mention the Skill. A direct smoke prompt can be:

```text
$matlab-sci-plot
Design a publication-quality prediction parity figure for a regression model.
Preserve negative R2 values, use final-size layout planning, and produce the
Figure Contract and Figure Plan before rendering.
```

The Skill may also be selected implicitly when the task matches the `description` in `SKILL.md`.

Codex detects Skill changes automatically. If a new or updated Skill does not appear, restart Codex and re-check that the Skill directory is located under a supported discovery root.

## 7. Repository validation

The installation check and the scientific runtime qualification are different things.

From the installed Skill root:

```bash
cd "$HOME/.agents/skills/matlab-sci-plot"
python -m unittest discover -s tests -v
python scripts/integration_check.py
```

MATLAB-dependent checks may report `SKIPPED_UNAVAILABLE` if MATLAB cannot be found. That result is truthful environment reporting and must not be interpreted as a MATLAB production qualification pass.

The v1.1.0 release was independently qualified with MATLAB R2023b (`23.2.0.2365128`). Other MATLAB releases may work, but this repository does not claim them as release-qualified unless separate evidence exists.

## 8. MATLAB production smoke test

When MATLAB R2023b is available, use the repository's MATLAB smoke and qualification surfaces rather than treating Python-only checks as sufficient production validation.

The released architecture expects native MATLAB rendering through the registered family layer and final export through the governed review/evidence pipeline.

Before using a new machine for publication artifacts, confirm at minimum that:

- MATLAB is discoverable and reports the expected release;
- representative native family rendering completes;
- final PNG/PDF export completes;
- scientific negative controls remain fail-closed; and
- evidence/provenance manifests bind the generated artifacts.

See [`RELEASE_NOTES_V1.1.0.md`](RELEASE_NOTES_V1.1.0.md) for the release qualification evidence.

## 9. Upgrade

### Upgrade to another qualified release

Fetch tags, inspect the release notes, and check out the desired exact tag:

```bash
SKILL_ROOT="$HOME/.agents/skills/matlab-sci-plot"

git -C "$SKILL_ROOT" fetch --tags origin
git -C "$SKILL_ROOT" checkout <qualified-release-tag>
```

Then repeat the installation verification and local validation steps.

For scientific reproducibility, record the installed repository version/tag or exact commit SHA alongside the project evidence.

### Follow `main` for development

Only use a moving development branch when reproducibility requirements allow it:

```bash
SKILL_ROOT="$HOME/.agents/skills/matlab-sci-plot"

git -C "$SKILL_ROOT" fetch origin
git -C "$SKILL_ROOT" checkout main
git -C "$SKILL_ROOT" pull --ff-only
```

A moving `main` checkout is not equivalent to a qualified release pin.

## 10. Disable without deleting

Codex supports local Skill configuration in `~/.codex/config.toml`. To disable a discovered Skill while retaining the files, add an entry using the actual installed `SKILL.md` path:

```toml
[[skills.config]]
path = "/absolute/path/to/matlab-sci-plot/SKILL.md"
enabled = false
```

Restart Codex after changing the configuration.

## 11. Uninstall

For the recommended user-scoped installation:

```bash
rm -rf "$HOME/.agents/skills/matlab-sci-plot"
```

For a Git submodule-based repository installation, remove the submodule using the parent repository's normal Git submodule workflow rather than deleting only the working directory.

If the Skill remains visible after removal, restart Codex and check for another copy with the same Skill name under a different discovery root.

## 12. Data and provenance boundary

Installing the Skill must not change the repository's scientific data boundary:

- keep raw/private data outside the Skill repository;
- bind data through Figure Contract source identities and paths;
- do not commit research datasets into the installed Skill directory;
- pin the Skill release used to generate publication artifacts; and
- retain review/evidence manifests with the downstream research project.

The Skill governs figure planning and rendering. It does not become the authority for the scientific truth of an external dataset or manuscript claim.

## 13. Distribution note

A standalone Skill directory is appropriate for local authoring, user-scoped use, and repository-scoped workflows. Current OpenAI guidance recommends packaging reusable third-party distribution as a plugin when broader one-click distribution is desired. Plugin packaging is separate from the v1.1.0 scientific figure contract and is not required for the manual installation methods in this guide.
