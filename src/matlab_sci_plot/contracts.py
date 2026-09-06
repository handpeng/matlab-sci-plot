"""Small, dependency-free validation for V1 machine-readable boundaries."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Mapping

SUPPORTED_MAJOR = 1
CONTRACT_VERSIONS = {
    "figure_contract": "1.0",
    "figure_plan": "1.0",
    "figure_family": "1.0",
    "style_profile": "1.0",
    "figure_review": "1.0",
    "figure_evidence": "1.0",
}


class ContractError(ValueError):
    """Raised when a contract is missing, malformed, or unsupported."""


def _version(value: Any, field: str) -> tuple[int, int]:
    if not isinstance(value, str) or value.count(".") != 1:
        raise ContractError(f"{field} must be a major.minor string")
    try:
        major, minor = (int(part) for part in value.split("."))
    except ValueError as exc:
        raise ContractError(f"{field} must be numeric") from exc
    if major != SUPPORTED_MAJOR:
        raise ContractError(f"unsupported major version {value} for {field}")
    return major, minor


def validate_contract(payload: Mapping[str, Any], expected_type: str | None = None) -> dict[str, Any]:
    """Validate the stable envelope and required fields, failing closed on major versions.

    This intentionally validates semantic invariants without requiring jsonschema at runtime.
    """
    if not isinstance(payload, Mapping):
        raise ContractError("contract must be an object")
    ctype = payload.get("contract_type") or payload.get("manifest_type") or payload.get("record_type")
    if expected_type and ctype != expected_type:
        raise ContractError(f"expected {expected_type}, got {ctype}")
    if ctype not in CONTRACT_VERSIONS:
        raise ContractError(f"unknown contract type: {ctype}")
    field = "contract_version" if "contract_version" in payload else ("manifest_version" if "manifest_version" in payload else "record_version")
    _version(payload.get(field), field)
    required = {
        "figure_contract": ("purpose", "claim", "data_bindings", "provenance"),
        "figure_plan": ("family_id", "layout_id", "backend_id", "style_id"),
        "figure_family": ("id", "communication_tasks", "data_roles_required", "renderer_entrypoint", "status"),
        "style_profile": ("profile_id", "profile_version", "status", "checked_at", "source_urls", "scope"),
        "figure_review": ("verdict", "scientific_correctness", "dimensions"),
        "figure_evidence": ("skill_version", "contract_versions", "outputs"),
    }[ctype]
    missing = [key for key in required if key not in payload]
    if missing:
        raise ContractError(f"missing required fields: {', '.join(missing)}")
    if ctype == "figure_review" and payload["scientific_correctness"] == "FAIL" and payload["verdict"] == "accept":
        raise ContractError("scientific failure cannot be accepted")
    return dict(payload)


def load_json(path: str | Path, expected_type: str | None = None) -> dict[str, Any]:
    with Path(path).open(encoding="utf-8") as handle:
        payload = json.load(handle)
    return validate_contract(payload, expected_type)
