"""Deterministic text capability checks; no scientific or locale inference."""
from __future__ import annotations

import json
from collections.abc import Mapping
from pathlib import Path
from typing import Any, Iterable

POLICY_PATH = Path(__file__).parents[2] / "policies" / "cjk_typography.json"


class CJKFontUnavailable(ValueError):
    """No runtime-available font belongs to the governed CJK policy."""


def load_font_policy() -> dict[str, Any]:
    """One repository policy, also consumed by MATLAB; no shared mutable state."""
    return json.loads(POLICY_PATH.read_text(encoding="utf-8"))


def _strings(value: Any) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, Mapping):
        for item in value.values():
            yield from _strings(item)
    elif isinstance(value, (list, tuple)):
        for item in value:
            yield from _strings(item)


def contains_cjk(text: Any) -> bool:
    """Inspect supplied visible Unicode text; numeric values are never converted."""
    ranges = load_font_policy()["unicode_ranges"]
    return any(first <= ord(char) <= last
               for string in _strings(text) for char in string for first, last in ranges)


def inspect_cjk_text(contract: Mapping[str, Any], visible_data_text: Any = ()) -> bool:
    """Conservative planning hint from governed text and supplied visible labels.

    Source paths, claims and numeric arrays are not text surfaces. MATLAB makes
    the final decision from the rendered hierarchy, including ticks and legends.
    """
    text = [contract.get(key, {}) for key in ("labels", "units", "panel_label")]
    return (contains_cjk([text, visible_data_text]) or
            any(inspect_cjk_text(panel) for panel in contract.get("panels", [])))


def resolve_font(requested_font: str, contains_cjk: bool, available_fonts: Iterable[str]) -> dict[str, Any]:
    """Resolve from an explicit runtime inventory; installation is not qualification."""
    if not isinstance(requested_font, str) or not requested_font:
        raise ValueError("requested_font must be a nonempty font name")
    if not isinstance(contains_cjk, bool):
        raise ValueError("contains_cjk must be boolean")
    policy = load_font_policy()
    state = {"contains_cjk": contains_cjk, "requested_font": requested_font,
             "resolved_font": requested_font, "font_policy_id": policy["font_policy_id"],
             "policy_version": policy["policy_version"], "resolution": "requested_english"}
    if not contains_cjk:
        return state
    available = set(available_fonts)
    if requested_font in policy["candidates"] and requested_font in available:
        state["resolution"] = "requested_cjk"
        return state
    for candidate in policy["candidates"]:
        if candidate in available:
            state.update(resolved_font=candidate, resolution="fallback_cjk")
            return state
    raise CJKFontUnavailable("No runtime-available governed CJK font; final export is unavailable")
