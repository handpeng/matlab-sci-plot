"""Metadata-driven discovery for families and other extension registries."""

from __future__ import annotations

import importlib
import json
from pathlib import Path
from typing import Any, Callable, Iterable

from .contracts import ContractError, validate_contract


class Registry:
    """Discover manifests without a central family-specific conditional chain."""

    def __init__(self, entries: Iterable[dict[str, Any]] = ()) -> None:
        self._entries: dict[str, dict[str, Any]] = {}
        self._renderers: dict[str, Callable[..., Any]] = {}
        for entry in entries:
            self.register(entry)

    def register(self, entry: dict[str, Any]) -> None:
        checked = validate_contract(entry, "figure_family")
        identifier = checked["id"]
        if identifier in self._entries:
            raise ContractError(f"duplicate registry id: {identifier}")
        self._entries[identifier] = checked

    def discover(self, directory: str | Path) -> list[str]:
        paths = sorted(Path(directory).glob("*.json"))
        for path in paths:
            with path.open(encoding="utf-8") as handle:
                self.register(json.load(handle))
        return sorted(self._entries)

    def ids(self) -> list[str]:
        return sorted(self._entries)

    def get(self, identifier: str) -> dict[str, Any]:
        return dict(self._entries[identifier])

    def bind_renderer(self, identifier: str, renderer: Callable[..., Any]) -> None:
        if identifier not in self._entries:
            raise KeyError(identifier)
        self._renderers[identifier] = renderer

    def renderer(self, identifier: str) -> Callable[..., Any]:
        if identifier not in self._renderers:
            entrypoint = self._entries[identifier].get("renderer_entrypoint")
            if not entrypoint or ":" not in entrypoint:
                raise ContractError(f"no renderer registered for {identifier}")
            module_name, function_name = entrypoint.split(":", 1)
            module = importlib.import_module(module_name)
            self._renderers[identifier] = getattr(module, function_name)
        return self._renderers[identifier]

    def compatible(self, roles: set[str], task: str, backend: str = "matlab") -> list[dict[str, Any]]:
        candidates = []
        for entry in self._entries.values():
            if task not in entry["communication_tasks"]:
                continue
            required = set(entry["data_roles_required"])
            if not required.issubset(roles):
                continue
            if entry.get("renderer_backend", "matlab") != backend:
                continue
            score = len(required.intersection(roles)) + (2 if entry.get("status") == "active" else 0)
            candidates.append({"family_id": entry["id"], "score": score, "reason": "required roles and task compatible"})
        return sorted(candidates, key=lambda item: (-item["score"], item["family_id"]))
