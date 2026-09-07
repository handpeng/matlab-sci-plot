"""Machine-checkable scientific integrity gates."""

from __future__ import annotations

from typing import Any, Mapping


def audit_contract(contract: Mapping[str, Any]) -> list[dict[str, str]]:
    findings: list[dict[str, str]] = []
    uncertainty = contract.get("uncertainty")
    if contract.get("requested_layers", {}).get("uncertainty") and not uncertainty:
        findings.append({"code": "UNCERTAINTY_UNDECLARED", "severity": "error", "message": "uncertainty layer requires explicit semantics"})
    for key in ("truth", "prediction"):
        binding = contract.get("data_bindings", {}).get(key)
        if isinstance(binding, Mapping) and binding.get("unit") is None and binding.get("physical_quantity"):
            findings.append({"code": "UNIT_UNDECLARED", "severity": "warning", "message": f"unit is unknown for {key}"})
    if contract.get("encoding") in {"bar", "area"} and contract.get("zero_baseline") is not True:
        findings.append({"code": "BAR_ZERO_BASELINE", "severity": "error", "message": "bar/area magnitude requires an explicit zero baseline"})
    if contract.get("dual_y_axis") and not contract.get("dual_y_axis_justification"):
        findings.append({"code": "DUAL_AXIS_UNJUSTIFIED", "severity": "warning", "message": "dual y-axis requires semantic justification"})
    if contract.get("uncertainty_label") == "95% Band" and not uncertainty:
        findings.append({"code": "AMBIGUOUS_INTERVAL", "severity": "error", "message": "generic 95% Band has no declared interval semantics"})
    return findings


def require_class_c_authority(contract: Mapping[str, Any], operation: str) -> None:
    authorization = contract.get("analysis_authorization", {})
    if not authorization.get("class_c") or operation not in authorization.get("operations", []):
        raise PermissionError(f"Class-C operation '{operation}' is not authorized by the Figure Contract")
