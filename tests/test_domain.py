import tempfile
import unittest
from pathlib import Path

from src.matlab_sci_plot.domain import metallurgy_pattern, render_precomputed_explanation
from src.matlab_sci_plot.families import load_registry


class DomainTests(unittest.TestCase):
    def test_metallurgy_composes_generic_families(self):
        pattern = metallurgy_pattern("external_generalization")
        self.assertGreaterEqual(len(pattern["families"]), 3)
        self.assertTrue(all(identifier in load_registry().ids() for identifier in pattern["families"]))

    def test_explainability_uses_precomputed_values(self):
        with tempfile.TemporaryDirectory() as directory:
            path = render_precomputed_explanation(["CaO", "SiO2"], [0.4, -0.2], Path(directory) / "importance.svg")
            self.assertTrue(path.exists())
            self.assertIn("CaO", path.read_text(encoding="utf-8"))

    def test_unknown_domain_question_fails(self):
        with self.assertRaises(KeyError):
            metallurgy_pattern("causal_mechanism")


if __name__ == "__main__":
    unittest.main()
