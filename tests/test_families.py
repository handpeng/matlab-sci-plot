import tempfile
import unittest
from pathlib import Path

from src.matlab_sci_plot.families import load_registry, plan_figure, render_synthetic


class FamilyTests(unittest.TestCase):
    def test_representative_and_extension_manifests_discover(self):
        ids = load_registry().ids()
        for identifier in ["prediction.parity", "relationship.scatter", "comparison.metric_panels", "distribution.histogram_kde", "trend.line", "explainability.base"]:
            self.assertIn(identifier, ids)

    def test_plan_uses_roles_and_task_and_is_bounded(self):
        plan = plan_figure({"contract_type":"figure_contract","contract_version":"1.0","purpose":"manuscript","claim":{"primary":"validate"},"data_bindings":{"truth":"t","prediction":"p"},"roles":{"truth":"truth","prediction":"prediction"},"communication_task":"validation","provenance":{"source_id":"synthetic"}})
        self.assertEqual(plan["family_id"], "prediction.parity")
        self.assertLessEqual(len(plan["alternatives"]), 2)

    def test_incompatible_task_fails(self):
        with self.assertRaises(Exception):
            plan_figure({"contract_type":"figure_contract","contract_version":"1.0","purpose":"x","claim":{"primary":"x"},"data_bindings":{"x":"x"},"roles":{"x":"matrix"},"communication_task":"validation","provenance":{"source_id":"synthetic"}})

    def test_synthetic_renderer_creates_artifact(self):
        plan = plan_figure({"contract_type":"figure_contract","contract_version":"1.0","purpose":"x","claim":{"primary":"validate"},"data_bindings":{"truth":"t","prediction":"p"},"roles":{"truth":"truth","prediction":"prediction"},"communication_task":"validation","provenance":{"source_id":"synthetic"}})
        with tempfile.TemporaryDirectory() as directory:
            output = render_synthetic(plan, Path(directory) / "candidate.svg")
            self.assertTrue(output.exists())
            self.assertIn("prediction.parity", output.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
