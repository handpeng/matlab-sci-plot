"""Figure-family manifests, planning, and dependency-free synthetic renderers."""

from __future__ import annotations

import html
from pathlib import Path
from typing import Any, Mapping

from .contracts import ContractError, validate_contract
from .layout import build_layout
from .registry import Registry

ROOT = Path(__file__).parents[2]
MANIFEST_DIR = ROOT / "manifests" / "families"


def load_registry() -> Registry:
    registry = Registry()
    registry.discover(MANIFEST_DIR)
    return registry


def plan_figure(contract: Mapping[str, Any], *, backend: str = "matlab", max_candidates: int = 3) -> dict[str, Any]:
    checked = validate_contract(contract, "figure_contract")
    roles = set(checked.get("roles", {}).keys()) | {value for value in checked.get("roles", {}).values() if isinstance(value, str)}
    task = checked.get("communication_task", "validation")
    candidates = load_registry().compatible(roles, task, backend)
    if not candidates:
        raise ContractError(f"no compatible family for task={task}, roles={sorted(roles)}")
    selected = candidates[:max(1, min(max_candidates, 3))]
    family = load_registry().get(selected[0]["family_id"])
    layout_id = (checked.get("layout") or family["recommended_layout_primitives"])[0]
    plan = {"contract_type": "figure_plan", "contract_version": "1.0", "family_id": family["id"], "layout_id": layout_id, "backend_id": backend, "style_id": checked.get("target_profile") or "publication.general", "candidate_rank": 1, "compatibility": selected[0], "alternatives": selected[1:], "panels": [], "scale_policy": checked.get("scale_policy", "shared")}
    plan["layout"] = build_layout(layout_id, int(checked.get("panel_count", 1)), shared_scales=plan["scale_policy"] == "shared", independent_scales=plan["scale_policy"] == "independent")
    return plan


def render_synthetic(plan: Mapping[str, Any], output: str | Path) -> Path:
    """Render a deterministic, reviewable SVG placeholder for non-MATLAB tests."""
    validate_contract(plan, "figure_plan")
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    label = html.escape(str(plan["family_id"]))
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="640" height="360" viewBox="0 0 640 360"><rect width="640" height="360" fill="white"/><line x1="70" y1="300" x2="590" y2="300" stroke="#222"/><line x1="70" y1="300" x2="70" y2="40" stroke="#222"/><circle cx="220" cy="180" r="7" fill="#0072B2"/><circle cx="330" cy="140" r="7" fill="#E69F00"/><circle cx="440" cy="100" r="7" fill="#009E73"/><text x="80" y="30" font-family="Arial" font-size="16">{label}</text></svg>'
    output.write_text(svg, encoding="utf-8")
    return output
