"""Render-review-repair-evidence loop with bounded, presentation-only repairs."""

from __future__ import annotations

import hashlib
import json
from copy import deepcopy
from pathlib import Path
from typing import Any, Mapping

from .contracts import ContractError, validate_contract
from .families import render_synthetic

REVIEW_DIMENSIONS = ("claim_support", "statistical_transparency", "perceptual_clarity", "layout_hierarchy", "accessibility", "style_consistency", "final_size_legibility", "reproducibility")
ALLOWED_REPAIRS = {"font_scale", "marker_scale", "line_scale", "legend_relocation", "shared_legend", "grid_state", "palette_substitution", "panel_spacing", "layout_adjustment", "zero_baseline", "label_wrap"}
FORBIDDEN_REPAIR_KEYS = {"source_values", "predictions", "metrics", "sample_membership", "uncertainty", "grouping", "statistical_method", "axis_transform"}


def review_record(verdict: str, scientific_correctness: str, *, scores: Mapping[str, str] | None = None, repair_ids: list[str] | None = None, notes: str = "") -> dict[str, Any]:
    if verdict not in {"accept", "repair", "reject"} or scientific_correctness not in {"PASS", "FAIL"}:
        raise ContractError("invalid review verdict or scientific correctness")
    if scientific_correctness == "FAIL" and verdict == "accept":
        raise ContractError("scientific failure cannot be accepted")
    dimensions = {name: (scores or {}).get(name, "PASS") for name in REVIEW_DIMENSIONS}
    record = {"record_type": "figure_review", "record_version": "1.0", "verdict": verdict, "scientific_correctness": scientific_correctness, "dimensions": dimensions, "repair_ids": repair_ids or [], "notes": notes}
    return validate_contract(record, "figure_review")


def apply_repairs(plan: Mapping[str, Any], repairs: list[Mapping[str, Any]]) -> dict[str, Any]:
    result = deepcopy(dict(plan))
    style = result.setdefault("style_adjustments", {})
    for repair in repairs:
        identifier = repair.get("repair_id")
        if identifier not in ALLOWED_REPAIRS:
            raise ContractError(f"unknown repair id: {identifier}")
        if FORBIDDEN_REPAIR_KEYS.intersection(repair):
            raise ContractError(f"repair {identifier} attempts to mutate scientific state")
        style[identifier] = repair.get("value", True)
    return result


def export_evidence(plan: Mapping[str, Any], review: Mapping[str, Any], output_dir: str | Path, *, source_data: Mapping[str, Any] | None = None, skill_version: str = "1.2.0") -> dict[str, Any]:
    checked_plan = validate_contract(plan, "figure_plan")
    checked_review = validate_contract(review, "figure_review")
    if checked_review["scientific_correctness"] != "PASS" or checked_review["verdict"] != "accept":
        raise PermissionError("final export is blocked until scientific correctness passes and review is accepted")
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    artifact = render_synthetic(checked_plan, output_dir / "figure_preview.svg")
    digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
    manifest = {"manifest_type": "figure_evidence", "manifest_version": "1.0", "skill_version": skill_version, "contract_versions": {"figure_plan": checked_plan["contract_version"], "figure_review": checked_review["record_version"]}, "source_data": dict(source_data or {}), "matlab_version": None, "style_profile": checked_plan["style_id"], "final_dimensions": checked_plan.get("final_size", {}), "palette": checked_plan.get("palette", {}), "transformations": [], "exclusions": [], "uncertainty": None, "selected_candidate": checked_plan.get("family_id"), "review_result": checked_review, "outputs": [{"path": str(artifact.name), "sha256": digest}]}
    manifest = validate_contract(manifest, "figure_evidence")
    (output_dir / "figure_manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True), encoding="utf-8")
    (output_dir / "figure_review.json").write_text(json.dumps(checked_review, indent=2, sort_keys=True), encoding="utf-8")
    return manifest
