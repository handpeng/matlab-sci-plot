"""Small, dependency-free validation for V1 machine-readable boundaries."""

from __future__ import annotations

import json
import math
import re
from functools import lru_cache
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


RELATIONSHIP_SEMANTICS = {
    "distance_to_error": {"x_role": "distance", "y_role": "error"},
}
RELATIONSHIP_ALIASES = {
    "distance -> error": "distance_to_error",
    "distance->error": "distance_to_error",
    "distance_to_error": "distance_to_error",
}
SUPPORTED_RELATIONSHIP_TRANSFORMATIONS = {"none", "identity"}


def relationship_spec(value: Any) -> dict[str, str]:
    """Return the canonical governed relationship identity or fail closed."""
    if isinstance(value, str):
        identifier = RELATIONSHIP_ALIASES.get(value.strip().lower())
        if identifier is None:
            raise ContractError(f"UNKNOWN_RELATIONSHIP_SEMANTICS: {value}")
        roles = RELATIONSHIP_SEMANTICS[identifier]
        return {"id": identifier, **roles}
    if isinstance(value, Mapping):
        identifier = value.get("id")
        if identifier not in RELATIONSHIP_SEMANTICS:
            raise ContractError(f"UNKNOWN_RELATIONSHIP_SEMANTICS: {identifier}")
        roles = RELATIONSHIP_SEMANTICS[identifier]
        if value.get("x_role") != roles["x_role"] or value.get("y_role") != roles["y_role"]:
            raise ContractError("RELATIONSHIP_ROLE_IDENTITY_MISMATCH")
        return {"id": identifier, **roles}
    raise ContractError("required_relationship must be a governed relationship identity")


def minimum_observations(value: Any) -> int:
    """Read the additive minimum-data form shared by Python and provider adapters."""
    if isinstance(value, int) and not isinstance(value, bool):
        return value
    if isinstance(value, Mapping) and isinstance(value.get("observations"), int) and not isinstance(value.get("observations"), bool):
        return value["observations"]
    raise ContractError("minimum_data_requirement must declare observations")


def validate_relationship_semantics(payload: Mapping[str, Any]) -> dict[str, Any] | None:
    """Validate explicitly declared relationship authority without affecting legacy contracts."""
    relationship = payload.get("required_relationship")
    semantic_fields = ("required_data_roles", "pairing_requirement", "relationship_representation",
                       "minimum_data_requirement", "allowed_transformations", "annotation_roles")
    if relationship is None:
        present = [field for field in semantic_fields if field in payload]
        if present:
            raise ContractError("RELATIONSHIP_SEMANTICS_REQUIRE_REQUIRED_RELATIONSHIP")
        return None

    spec = relationship_spec(relationship)
    required_roles = payload.get("required_data_roles")
    if not isinstance(required_roles, list) or not required_roles or not all(isinstance(role, str) for role in required_roles):
        raise ContractError("RELATIONSHIP_REQUIRED_DATA_ROLES_MISSING")
    missing_roles = [role for role in (spec["x_role"], spec["y_role"]) if role not in required_roles]
    if missing_roles:
        raise ContractError(f"RELATIONSHIP_REQUIRED_DATA_ROLES_MISSING: {','.join(missing_roles)}")
    bindings = payload.get("roles", payload.get("relationship_bindings", {}))
    bound_tokens = set(bindings) | set(bindings.values()) if isinstance(bindings, Mapping) else set()
    unbound_roles = [role for role in required_roles if role not in bound_tokens]
    if unbound_roles:
        raise ContractError(f"RELATIONSHIP_ROLE_BINDING_MISSING: {','.join(unbound_roles)}")

    pairing = payload.get("pairing_requirement")
    if pairing not in {"paired", "aggregate"}:
        raise ContractError("RELATIONSHIP_PAIRING_REQUIREMENT_MISSING")
    representation = payload.get("relationship_representation")
    expected = "paired_observations" if pairing == "paired" else "authorized_aggregate"
    if representation != expected:
        raise ContractError("RELATIONSHIP_REPRESENTATION_NOT_AUTHORIZED")

    if "minimum_data_requirement" in payload:
        minimum = minimum_observations(payload["minimum_data_requirement"])
        if minimum < 1:
            raise ContractError("RELATIONSHIP_MINIMUM_DATA_INVALID")
        requirement = payload["minimum_data_requirement"]
        if isinstance(requirement, Mapping):
            scoped_roles = requirement.get("roles", [])
            if any(role not in required_roles for role in scoped_roles):
                raise ContractError("RELATIONSHIP_MINIMUM_DATA_ROLES_INVALID")

    transformations = payload.get("allowed_transformations", [])
    if not isinstance(transformations, list) or not all(isinstance(item, str) for item in transformations):
        raise ContractError("RELATIONSHIP_ALLOWED_TRANSFORMATIONS_INVALID")
    unknown_transformations = [item for item in transformations if item not in SUPPORTED_RELATIONSHIP_TRANSFORMATIONS]
    if unknown_transformations:
        raise ContractError(f"UNAUTHORIZED_RELATIONSHIP_TRANSFORMATION: {unknown_transformations[0]}")

    annotations = payload.get("annotation_roles", [])
    if not isinstance(annotations, list) or not all(isinstance(item, str) for item in annotations):
        raise ContractError("RELATIONSHIP_ANNOTATION_ROLES_INVALID")
    if set(annotations).intersection(required_roles):
        raise ContractError("RELATIONSHIP_ANNOTATION_ROLE_OVERLAP")
    return {"relationship": spec, "required_data_roles": list(required_roles),
            "pairing_requirement": pairing, "relationship_representation": representation,
            "minimum_observations": minimum_observations(payload["minimum_data_requirement"]) if "minimum_data_requirement" in payload else 1,
            "allowed_transformations": list(transformations), "annotation_roles": list(annotations)}


@lru_cache(maxsize=None)
def _schema(name: str) -> dict[str, Any]:
    path = Path(__file__).parents[2] / "schemas" / f"{name}.schema.json"
    return json.loads(path.read_text(encoding="utf-8"))


def _validate_schema(value: Any, schema: Mapping[str, Any], root: Mapping[str, Any], path: str = "$") -> None:
    """Evaluate the small schema vocabulary used by Figure Contracts/evidence.

    This is not a general JSON Schema engine. Unsupported schema keywords fail
    closed so extending the authority cannot silently bypass runtime validation.
    Full Draft 2020-12 agreement is checked independently in contract tests.
    """
    supported = {"$schema", "$id", "title", "description", "$defs", "$ref", "type", "const",
                 "required", "properties", "additionalProperties", "minProperties", "items",
                 "minItems", "maxItems", "minimum", "exclusiveMinimum", "anyOf",
                 "pattern", "minLength", "enum"}
    if set(schema) - supported:
        raise ContractError(f"unsupported schema keywords at {path}: {sorted(set(schema) - supported)}")
    if "$ref" in schema:
        ref = schema["$ref"]
        if ref != "#" and not ref.startswith("#/$defs/"):
            raise ContractError(f"unsupported schema reference: {ref}")
        target = root if ref == "#" else root["$defs"][ref[len("#/$defs/"):]]
        _validate_schema(value, target, root, path)
    number = isinstance(value, (int, float)) and not isinstance(value, bool)
    types = {"object": isinstance(value, Mapping), "array": isinstance(value, list),
             "string": isinstance(value, str), "boolean": isinstance(value, bool),
             "null": value is None, "number": number,
             "integer": number and (isinstance(value, int) or (math.isfinite(value) and value.is_integer()))}
    if "type" in schema:
        wanted = schema["type"] if isinstance(schema["type"], list) else [schema["type"]]
        if not any(types.get(kind, False) for kind in wanted):
            raise ContractError(f"{path} must have type {wanted}")
    if "const" in schema and value != schema["const"]:
        raise ContractError(f"{path} must equal {schema['const']!r}")
    if "enum" in schema and value not in schema["enum"]:
        raise ContractError(f"{path} must be a governed enum value")
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            raise ContractError(f"{path} is too short")
        if "pattern" in schema and not re.search(schema["pattern"], value):
            raise ContractError(f"{path} does not match the governed pattern")
    if number:
        if isinstance(value, float) and not math.isfinite(value):
            raise ContractError(f"{path} must be finite JSON data")
        if "minimum" in schema and value < schema["minimum"]:
            raise ContractError(f"{path} is below minimum")
        if "exclusiveMinimum" in schema and value <= schema["exclusiveMinimum"]:
            raise ContractError(f"{path} must exceed minimum")
    if isinstance(value, Mapping):
        missing = set(schema.get("required", [])) - value.keys()
        if missing:
            raise ContractError(f"{path} missing required fields: {sorted(missing)}")
        if len(value) < schema.get("minProperties", 0):
            raise ContractError(f"{path} has too few properties")
        properties = schema.get("properties", {})
        extra = schema.get("additionalProperties", True)
        for key, item in value.items():
            if key in properties:
                _validate_schema(item, properties[key], root, f"{path}.{key}")
            elif extra is False:
                raise ContractError(f"{path} unknown field: {key}")
            elif isinstance(extra, Mapping):
                _validate_schema(item, extra, root, f"{path}.{key}")
    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0) or len(value) > schema.get("maxItems", len(value)):
            raise ContractError(f"{path} has invalid item count")
        if "items" in schema:
            for index, item in enumerate(value):
                _validate_schema(item, schema["items"], root, f"{path}[{index}]")
    if "anyOf" in schema:
        for alternative in schema["anyOf"]:
            try:
                _validate_schema(value, alternative, root, path)
                break
            except ContractError:
                continue
        else:
            raise ContractError(f"{path} does not match any governed alternative")


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
    if ctype == "figure_contract":
        schema = _schema("figure_contract")
        _validate_schema(payload, schema, schema)
        validate_relationship_semantics(payload)
    if ctype == "figure_plan":
        validate_relationship_semantics(payload)
    if ctype == "figure_evidence":
        schema = _schema("evidence_manifest")
        _validate_schema(payload, schema, schema)
        if "typography" in payload:
            from .typography import resolve_font
            state = payload["typography"]
            try:
                expected = resolve_font(state["requested_font"], state["contains_cjk"], [state["resolved_font"]])
            except ValueError as exc:
                raise ContractError("invalid governed typography evidence") from exc
            if state != expected:
                raise ContractError("typography evidence does not match governed resolution state")
    if ctype == "figure_review" and payload["scientific_correctness"] == "FAIL" and payload["verdict"] == "accept":
        raise ContractError("scientific failure cannot be accepted")
    return dict(payload)


def load_json(path: str | Path, expected_type: str | None = None) -> dict[str, Any]:
    with Path(path).open(encoding="utf-8") as handle:
        payload = json.load(handle)
    return validate_contract(payload, expected_type)
