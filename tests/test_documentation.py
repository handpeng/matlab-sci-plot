import unittest
from pathlib import Path

from src.matlab_sci_plot.migration import load_matrix


class DocumentationTests(unittest.TestCase):
    def test_reference_routes_and_examples_exist(self):
        root = Path(__file__).parents[1]
        for name in ["figure-contract.md", "chart-selection.md", "panel-layout.md", "style-system.md", "typography.md", "color-system.md", "uncertainty.md", "accessibility.md", "scientific-integrity.md", "anti-patterns.md", "review-contract.md", "metallurgy-patterns.md"]:
            self.assertTrue((root / "references" / name).exists(), name)
        for name in ["prediction_validation.json", "model_comparison.json", "distribution.json", "trend.json", "metallurgy_external_generalization.json", "explainability.json"]:
            self.assertTrue((root / "examples" / name).exists(), name)
        self.assertEqual(len(load_matrix()["entries"]), 17)


if __name__ == "__main__":
    unittest.main()
