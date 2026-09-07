"""Data binding, conservative role inference, and shared Class-B summaries."""

from __future__ import annotations

import csv
import math
from pathlib import Path
from statistics import mean, median
from typing import Any, Iterable, Mapping, Sequence


def read_table(path: str | Path) -> list[dict[str, Any]]:
    """Read CSV only on the dependency-free path; other formats fail explicitly."""
    path = Path(path)
    if path.suffix.lower() not in {".csv", ".tsv"}:
        raise ValueError("V1 dependency-free reader supports CSV/TSV; use an explicit upstream adapter for other formats")
    with path.open(newline="", encoding="utf-8-sig") as handle:
        return list(csv.DictReader(handle, delimiter="\t" if path.suffix.lower() == ".tsv" else ","))


def _numeric(values: Iterable[Any]) -> list[float]:
    result = []
    for value in values:
        try:
            number = float(value)
        except (TypeError, ValueError):
            continue
        if math.isfinite(number):
            result.append(number)
    return result


def inspect_table(rows: Sequence[Mapping[str, Any]]) -> dict[str, Any]:
    columns = sorted({key for row in rows for key in row})
    summary = {}
    for column in columns:
        values = [row.get(column) for row in rows]
        numeric = _numeric(values)
        missing = sum(value is None or str(value).strip() == "" for value in values)
        summary[column] = {"n": len(values), "numeric_n": len(numeric), "missing_n": missing, "unique_n": len({str(value) for value in values if value not in (None, "")}), "kind": "numeric" if len(numeric) == len(values) - missing and numeric else "categorical"}
    return {"n_rows": len(rows), "columns": summary}


def infer_roles(rows: Sequence[Mapping[str, Any]], explicit: Mapping[str, str] | None = None) -> dict[str, list[str]]:
    """Infer only observable roles; explicit bindings always win."""
    explicit = explicit or {}
    info = inspect_table(rows)["columns"]
    roles: dict[str, list[str]] = {"numeric": [], "categorical": [], "ordered": [], "identifier": []}
    for column, metadata in info.items():
        role = explicit.get(column)
        if role:
            roles.setdefault(role, []).append(column)
            continue
        roles[metadata["kind"]].append(column)
        if metadata["unique_n"] == metadata["n"] and metadata["n"] > 1:
            roles["identifier"].append(column)
    return roles


def common_valid_mask(truth: Sequence[Any], predictions: Mapping[str, Sequence[Any]]) -> list[bool]:
    lengths = [len(truth), *(len(values) for values in predictions.values())]
    if len(set(lengths)) != 1:
        raise ValueError("truth and predictions must have equal row counts")
    mask = []
    for index, actual in enumerate(truth):
        valid = _numeric([actual]) and all(_numeric([values[index]]) for values in predictions.values())
        mask.append(bool(valid))
    return mask


def _paired(truth: Sequence[float], prediction: Sequence[float], mask: Sequence[bool]) -> tuple[list[float], list[float]]:
    if len(truth) != len(prediction) or len(mask) != len(truth):
        raise ValueError("truth, prediction, and mask lengths must match")
    actual = [float(a) for a, keep in zip(truth, mask) if keep]
    predicted = [float(p) for p, keep in zip(prediction, mask) if keep]
    return actual, predicted


def rmse(truth: Sequence[float], prediction: Sequence[float], mask: Sequence[bool] | None = None) -> float:
    mask = list(mask) if mask is not None else common_valid_mask(truth, {"prediction": prediction})
    actual, predicted = _paired(truth, prediction, mask)
    return math.sqrt(mean((a - p) ** 2 for a, p in zip(actual, predicted))) if actual else math.nan


def mae(truth: Sequence[float], prediction: Sequence[float], mask: Sequence[bool] | None = None) -> float:
    mask = list(mask) if mask is not None else common_valid_mask(truth, {"prediction": prediction})
    actual, predicted = _paired(truth, prediction, mask)
    return mean(abs(a - p) for a, p in zip(actual, predicted)) if actual else math.nan


def r2(truth: Sequence[float], prediction: Sequence[float], mask: Sequence[bool] | None = None) -> float:
    mask = list(mask) if mask is not None else common_valid_mask(truth, {"prediction": prediction})
    actual, predicted = _paired(truth, prediction, mask)
    if not actual:
        return math.nan
    baseline = mean(actual)
    total = sum((a - baseline) ** 2 for a in actual)
    return 1.0 - sum((a - p) ** 2 for a, p in zip(actual, predicted)) / total if total else math.nan


def quantiles(values: Sequence[float], probabilities: Sequence[float] = (0.25, 0.5, 0.75)) -> list[float]:
    ordered = sorted(_numeric(values))
    if not ordered:
        return [math.nan for _ in probabilities]
    return [ordered[min(len(ordered) - 1, max(0, round(probability * (len(ordered) - 1))))] for probability in probabilities]


def summary(truth: Sequence[float], predictions: Mapping[str, Sequence[float]]) -> dict[str, Any]:
    mask = common_valid_mask(truth, predictions)
    result = {"n_common": sum(mask), "sample_mask": mask, "metrics": {}}
    for name, prediction in predictions.items():
        result["metrics"][name] = {"rmse": rmse(truth, prediction, mask), "mae": mae(truth, prediction, mask), "r2": r2(truth, prediction, mask)}
    return result


def histogram_metadata(values: Sequence[float], bins: int = 10) -> dict[str, Any]:
    finite = _numeric(values)
    if bins < 1:
        raise ValueError("bins must be positive")
    if not finite:
        return {"method": "fixed_count", "bins": bins, "edges": [], "n": 0}
    low, high = min(finite), max(finite)
    width = (high - low) / bins if high != low else 1.0
    edges = [low + index * width for index in range(bins + 1)]
    return {"method": "fixed_count", "bins": bins, "edges": edges, "n": len(finite)}
