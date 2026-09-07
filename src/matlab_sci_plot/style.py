"""Compositional, final-size-aware publication style resolution."""

from __future__ import annotations

from copy import deepcopy
from datetime import date
from typing import Any, Mapping

from .contracts import ContractError, validate_contract

SIZE_PRESETS = {
    "single_column": {"width_mm": 89.0, "height_mm": 66.75},
    "double_column": {"width_mm": 178.0, "height_mm": 118.0},
    "thesis_textwidth": {"width_mm": 150.0, "height_mm": 100.0},
    "presentation": {"width_mm": 254.0, "height_mm": 142.875},
}

PALETTES = {
    "categorical.okabe_ito": {
        "class": "categorical",
        "colors": ["#0072B2", "#E69F00", "#009E73", "#D55E00", "#CC79A7", "#56B4E9", "#F0E442", "#000000"],
    },
    "sequential.viridis_like": {
        "class": "sequential",
        "colors": ["#440154", "#3B528B", "#21918C", "#5EC962", "#FDE725"],
    },
    "diverging.blue_orange": {
        "class": "diverging",
        "colors": ["#2166AC", "#67A9CF", "#F7F7F7", "#EF8A62", "#B2182B"],
    },
}

SEMANTIC_ROLE_INDEX = {
    "observed": ("categorical.okabe_ito", 0),
    "reference": ("categorical.okabe_ito", 0),
    "proposed": ("categorical.okabe_ito", 1),
    "highlight": ("categorical.okabe_ito", 1),
    "baseline": ("categorical.okabe_ito", 2),
    "comparator": ("categorical.okabe_ito", 2),
    "positive": ("categorical.okabe_ito", 2),
    "negative": ("categorical.okabe_ito", 3),
    "uncertainty": ("categorical.okabe_ito", 5),
    "missing": ("categorical.okabe_ito", 7),
    "out_of_range": ("categorical.okabe_ito", 7),
}

SCIENTIFIC_CONSTRAINTS = {
    "preserve_negative_r2": True,
    "require_declared_uncertainty": True,
    "ordered_quantitative_palette_forbidden": ["jet", "rainbow"],
    "bar_zero_baseline_required": True,
}

GENERAL_STYLE = {
    "style_id": "publication.general",
    "typography": {"font_name": "Arial", "base_pt": 8.0, "minimum_pt": 6.5},
    "geometry": {"line_width_pt": 0.8, "marker_size_pt": 4.5, "spines": "minimal"},
    "axes": {"tick_direction": "out", "grid": "conditional"},
    "legend": {"policy": "shared_when_multi_panel", "occlusion": "forbidden"},
    "spacing": {"tile": "compact", "padding": "compact"},
    "palette_ids": {"categorical": "categorical.okabe_ito", "sequential": "sequential.viridis_like", "diverging": "diverging.blue_orange"},
}

SAFE_OVERRIDE_PATHS = {
    "typography.base_pt", "typography.font_name", "geometry.line_width_pt",
    "geometry.marker_size_pt", "axes.grid", "legend.policy", "spacing.tile", "spacing.padding",
}


def _merge(target: dict[str, Any], update: Mapping[str, Any]) -> None:
    for key, value in update.items():
        if isinstance(value, Mapping) and isinstance(target.get(key), dict):
            _merge(target[key], value)
        else:
            target[key] = deepcopy(value)


def _safe_overrides(style: dict[str, Any], overrides: Mapping[str, Any], prefix: str = "") -> None:
    for key, value in overrides.items():
        path = f"{prefix}.{key}" if prefix else key
        if isinstance(value, Mapping):
            _safe_overrides(style, value, path)
        elif path in SAFE_OVERRIDE_PATHS:
            cursor = style
            parts = path.split(".")
            for part in parts[:-1]:
                cursor = cursor.setdefault(part, {})
            cursor[parts[-1]] = value
        else:
            raise ContractError(f"unsafe or unknown style override: {path}")


def resolve_style(size_id: str, profile: Mapping[str, Any] | None = None, family_defaults: Mapping[str, Any] | None = None, user_overrides: Mapping[str, Any] | None = None, panel_count: int = 1) -> dict[str, Any]:
    if size_id not in SIZE_PRESETS:
        raise ContractError(f"unknown final-size preset: {size_id}")
    resolved = deepcopy(GENERAL_STYLE)
    resolved["scientific_constraints"] = deepcopy(SCIENTIFIC_CONSTRAINTS)
    resolved["final_size"] = {"preset": size_id, **SIZE_PRESETS[size_id]}
    density = max(1, panel_count) ** 0.5
    resolved["typography"]["resolved_pt"] = max(resolved["typography"]["minimum_pt"], round(resolved["typography"]["base_pt"] / (0.85 + 0.15 * density), 2))
    if profile:
        validate_contract(profile, "style_profile")
        _merge(resolved, profile.get("overrides", {}))
        resolved["profile_id"] = profile["profile_id"]
        resolved["profile_status"] = profile["status"]
        if profile["status"] == "stale_review_required":
            resolved.setdefault("warnings", []).append("publication profile snapshot is stale; verify live guidance")
    if family_defaults:
        resolved["family"] = {}
        _merge(resolved["family"], family_defaults)
    if user_overrides:
        _safe_overrides(resolved, user_overrides)
    resolved["scientific_constraints"] = deepcopy(SCIENTIFIC_CONSTRAINTS)
    return resolved


def semantic_color(role: str) -> str:
    palette_id, index = SEMANTIC_ROLE_INDEX[role]
    return PALETTES[palette_id]["colors"][index]
