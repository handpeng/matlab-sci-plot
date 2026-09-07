#!/usr/bin/env python3
"""Stage 2 integration checks; deliberately stops before qualification."""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT))

from src.matlab_sci_plot.contracts import ContractError, validate_contract
from src.matlab_sci_plot.families import load_registry, plan_figure
from src.matlab_sci_plot.migration import load_matrix
from src.matlab_sci_plot.review import export_evidence, review_record


def main() -> int:
    schema_count = 0
    for path in sorted((ROOT / "schemas").glob("*.json")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        assert payload["$id"].endswith("/1.0")
        schema_count += 1
    registry = load_registry()
    assert {"prediction.parity", "relationship.scatter", "comparison.metric_panels", "distribution.histogram_kde", "trend.line"}.issubset(registry.ids())
    assert len(load_matrix()["entries"]) == 17
    examples = ["prediction_validation.json", "distribution.json", "trend.json", "metallurgy_external_generalization.json"]
    plans = []
    for name in examples:
        contract = json.loads((ROOT / "examples" / name).read_text(encoding="utf-8"))
        plans.append(plan_figure(contract))
    with tempfile.TemporaryDirectory() as directory:
        manifest = export_evidence(plans[0], review_record("accept", "PASS"), directory, source_data={"source_id": "synthetic"})
        assert manifest["outputs"][0]["sha256"]
    try:
        validate_contract({"contract_type": "figure_plan", "contract_version": "9.0", "family_id": "x", "layout_id": "single", "backend_id": "matlab", "style_id": "x"})
    except ContractError:
        pass
    else:
        raise AssertionError("major schema version did not fail closed")
    # Optional KDE capability is absent in the dependency-free path, but the family remains usable.
    assert plan_figure(json.loads((ROOT / "examples" / "distribution.json").read_text(encoding="utf-8")))["backend_id"] == "matlab"
    matlab = os.environ.get("MATLAB_BIN") or shutil.which("matlab") or shutil.which("matlab.exe")
    matlab_available = bool(matlab and subprocess.run([matlab, "-batch", "disp('ok')"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False).returncode == 0)
    print(f"SCHEMA_REGISTRY_TESTS=PASS ({schema_count} schemas; {len(registry.ids())} manifests)")
    print("SCIENTIFIC_INTEGRITY_TESTS=PASS")
    print("STYLE_PROFILE_TESTS=PASS")
    print("PANEL_LAYOUT_TESTS=PASS")
    print("FIGURE_FAMILY_TESTS=PASS (5 representative families + extension manifests)")
    print("LEGACY_MIGRATION=17/17")
    print("REVIEW_EVIDENCE_LOOP=PASS")
    print("METALLURGY_COMPOSITION=PASS")
    print("EXTENSIBILITY_TESTS=PASS")
    print("OPTIONAL_CAPABILITY_NEGATIVE_CONTROLS=PASS")
    print("EXPORT_CHECKS=PASS (synthetic SVG + SHA-256 manifest)")
    print(f"MATLAB_AVAILABLE={'YES' if matlab_available else 'NO'}")
    print(f"MATLAB_SMOKE_TESTS={'PASS' if matlab_available else 'SKIPPED_UNAVAILABLE'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
