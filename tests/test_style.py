import json
import unittest
from pathlib import Path

from src.matlab_sci_plot.contracts import ContractError
from src.matlab_sci_plot.style import PALETTES, SCIENTIFIC_CONSTRAINTS, SIZE_PRESETS, resolve_style, semantic_color


ROOT = Path(__file__).parents[1]


class StyleTests(unittest.TestCase):
    def load(self, name):
        return json.loads((ROOT / "profiles" / name).read_text(encoding="utf-8"))

    def test_final_size_presets_are_deterministic(self):
        self.assertEqual(set(SIZE_PRESETS), {"single_column", "double_column", "thesis_textwidth", "presentation"})
        self.assertEqual(resolve_style("single_column")["final_size"]["width_mm"], 89.0)

    def test_profile_composition_keeps_semantic_roles(self):
        general = resolve_style("single_column", self.load("general-publication-2026.json"))
        nature = resolve_style("single_column", self.load("nature-research-2026.json"))
        self.assertNotEqual(general["typography"]["base_pt"], nature["typography"]["base_pt"])
        self.assertEqual(semantic_color("observed"), semantic_color("reference"))
        self.assertEqual(general["scientific_constraints"], nature["scientific_constraints"])

    def test_quantitative_default_is_not_rainbow(self):
        self.assertEqual(PALETTES["sequential.viridis_like"]["class"], "sequential")
        self.assertNotIn("jet", resolve_style("double_column")["palette_ids"].values())

    def test_stale_profile_warns_without_scientific_failure(self):
        style = resolve_style("single_column", self.load("stale-demo-2024.json"))
        self.assertTrue(style["warnings"])
        self.assertTrue(style["scientific_constraints"]["preserve_negative_r2"])

    def test_unsafe_override_fails(self):
        with self.assertRaises(ContractError):
            resolve_style("single_column", user_overrides={"scientific_constraints": {"preserve_negative_r2": False}})


if __name__ == "__main__":
    unittest.main()
