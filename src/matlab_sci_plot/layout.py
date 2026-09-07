"""Semantic panel-narrative planning independent of renderer implementation."""

from __future__ import annotations

from dataclasses import dataclass, asdict
from typing import Any, Sequence

LAYOUT_IDS = {
    "single", "paired", "triptych", "hero_plus_diagnostics",
    "overview_plus_small_multiples", "small_multiples", "legend_panel",
}


@dataclass(frozen=True)
class PanelSlot:
    panel_id: str
    row: int
    column: int
    row_span: int = 1
    column_span: int = 1
    label: str | None = None
    role: str = "evidence"


def build_layout(layout_id: str, panel_count: int = 1, *, shared_scales: bool = True, independent_scales: bool = False) -> dict[str, Any]:
    if layout_id not in LAYOUT_IDS:
        raise ValueError(f"unknown semantic layout: {layout_id}")
    if panel_count < 1:
        raise ValueError("panel_count must be positive")
    if shared_scales and independent_scales:
        raise ValueError("shared and independent scales are mutually exclusive")
    slots: list[PanelSlot]
    rows, columns = 1, 1
    if layout_id == "single":
        slots = [PanelSlot("A", 1, 1, label="A")]
    elif layout_id == "paired":
        rows, columns = 1, 2
        slots = [PanelSlot("A", 1, 1, label="A"), PanelSlot("B", 1, 2, label="B")]
    elif layout_id == "triptych":
        rows, columns = 1, 3
        slots = [PanelSlot(chr(65 + i), 1, i + 1, label=chr(65 + i)) for i in range(3)]
    elif layout_id == "hero_plus_diagnostics":
        rows, columns = 2, 2
        slots = [PanelSlot("A", 1, 1, 2, 1, "A", "main_evidence"), PanelSlot("B", 1, 2, 1, 1, "B", "diagnostic"), PanelSlot("C", 2, 2, 1, 1, "C", "diagnostic")]
    elif layout_id == "overview_plus_small_multiples":
        rows, columns = 2, 3
        slots = [PanelSlot("A", 1, 1, 1, 3, "A", "overview")] + [PanelSlot(chr(66 + i), 2, i + 1, label=chr(66 + i), role="small_multiple") for i in range(3)]
    elif layout_id == "small_multiples":
        columns = min(3, max(1, panel_count))
        rows = (panel_count + columns - 1) // columns
        slots = [PanelSlot(chr(65 + i), i // columns + 1, i % columns + 1, label=chr(65 + i), role="small_multiple") for i in range(panel_count)]
    else:
        rows, columns = 1, 2
        slots = [PanelSlot("A", 1, 1, label="A", role="evidence"), PanelSlot("legend", 1, 2, label=None, role="legend")]
    if panel_count > len(slots) and layout_id not in {"single", "paired", "triptych", "hero_plus_diagnostics", "overview_plus_small_multiples", "legend_panel"}:
        raise ValueError("layout does not provide enough panel slots")
    return {"layout_id": layout_id, "rows": rows, "columns": columns, "reading_order": [slot.panel_id for slot in slots], "slots": [asdict(slot) for slot in slots], "scale_policy": "shared" if shared_scales else "independent", "independent_scale_disclosure": independent_scales}


def apply_panel_labels(plan: dict[str, Any], labels: Sequence[str] | None = None) -> dict[str, Any]:
    result = {**plan, "slots": [dict(slot) for slot in plan["slots"]]}
    wanted = list(labels or [])
    for index, slot in enumerate(result["slots"]):
        if slot["role"] == "legend":
            continue
        if index < len(wanted):
            slot["label"] = wanted[index]
    result["outer_axis_labels"] = {"x": [result["slots"][-1]["panel_id"]], "y": [result["slots"][0]["panel_id"]]}
    return result
