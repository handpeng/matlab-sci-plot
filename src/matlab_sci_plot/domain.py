"""Domain composition patterns; no domain-specific renderer forks."""

from __future__ import annotations

import html
from pathlib import Path
from typing import Any, Mapping, Sequence

METALLURGY_PATTERNS = {
    "model_validation": {"families": ["prediction.parity", "comparison.metric_panels", "distribution.histogram_kde"], "layout": "hero_plus_diagnostics", "audit": ["common_sample", "negative_r2", "uncertainty_declared"]},
    "temperature_property": {"families": ["relationship.scatter", "trend.line", "distribution.histogram_kde"], "layout": "overview_plus_small_multiples", "audit": ["units_declared", "ordered_temperature"]},
    "composition_property": {"families": ["relationship.scatter", "comparison.metric_panels"], "layout": "paired", "audit": ["composition_units", "causality_not_implied"]},
    "process_trend": {"families": ["trend.line", "distribution.histogram_kde", "comparison.metric_panels"], "layout": "hero_plus_diagnostics", "audit": ["heat_or_batch_id", "time_order"]},
    "regime_comparison": {"families": ["comparison.metric_panels", "distribution.histogram_kde", "relationship.scatter"], "layout": "triptych", "audit": ["group_declared", "shared_scale"]},
    "external_generalization": {"families": ["prediction.parity", "comparison.metric_panels", "distribution.histogram_kde"], "layout": "hero_plus_diagnostics", "audit": ["external_split_declared", "n_by_group"]},
    "explainability": {"families": ["explainability.base", "relationship.scatter", "trend.line"], "layout": "paired", "audit": ["precomputed_values", "no_causal_claim"]},
}

VOCABULARY_ALIASES = {"heat": ["heat_id", "heat", "batch"], "temperature": ["temperature", "temp", "t"], "composition": ["composition", "chemistry", "wt_percent"], "regime": ["regime", "group", "condition"]}


def metallurgy_pattern(question: str) -> dict[str, Any]:
    key = question.strip().lower().replace(" ", "_")
    if key not in METALLURGY_PATTERNS:
        raise KeyError(question)
    return {"domain": "metallurgy", "pattern_id": key, **METALLURGY_PATTERNS[key], "vocabulary_aliases": VOCABULARY_ALIASES}


def render_precomputed_explanation(feature_names: Sequence[str], values: Sequence[float], output: str | Path) -> Path:
    if len(feature_names) != len(values) or not feature_names:
        raise ValueError("precomputed feature names and values must be non-empty and aligned")
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    bars = []
    maximum = max(abs(float(value)) for value in values) or 1.0
    for index, (name, value) in enumerate(zip(feature_names, values)):
        width = 240 * abs(float(value)) / maximum
        color = "#009E73" if float(value) >= 0 else "#D55E00"
        bars.append(f'<text x="20" y="{35 + index * 28}" font-family="Arial" font-size="13">{html.escape(str(name))}</text><rect x="150" y="{22 + index * 28}" width="{width:.2f}" height="16" fill="{color}"/>')
    output.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="440" height="{60 + len(bars) * 28}">' + ''.join(bars) + '</svg>', encoding="utf-8")
    return output
