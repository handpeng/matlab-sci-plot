"""Validation and lookup for the historical template migration matrix."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ALLOWED_STATUSES = {"mapped", "mapped_with_behavior_change", "legacy_only", "deprecated"}
ROOT = Path(__file__).parents[2]


def load_matrix() -> dict[str, Any]:
    with (ROOT / "docs" / "LEGACY_MIGRATION_MATRIX.json").open(encoding="utf-8") as handle:
        matrix = json.load(handle)
    entries = matrix.get("entries", [])
    if len(entries) != 17:
        raise ValueError(f"expected 17 migration entries, got {len(entries)}")
    for entry in entries:
        required = {"source_path", "new_family", "layout", "scientific_findings", "compatibility_status", "replacement_example", "deprecation_status"}
        if not required.issubset(entry) or entry["compatibility_status"] not in ALLOWED_STATUSES:
            raise ValueError(f"invalid migration entry: {entry}")
    return matrix


def status_for(source_path: str) -> dict[str, Any]:
    for entry in load_matrix()["entries"]:
        if entry["source_path"] == source_path:
            return entry
    raise KeyError(source_path)
