import tempfile
import unittest
from pathlib import Path

from src.matlab_sci_plot.contracts import ContractError
from src.matlab_sci_plot.families import load_registry, plan_figure, render_synthetic


class FamilyTests(unittest.TestCase):
    @staticmethod
    def relationship_contract(**overrides):
        contract = {
            "contract_type": "figure_contract", "contract_version": "1.0", "purpose": "relationship",
            "claim": {"primary": "distance and error relationship"},
            "data_bindings": {"distance": "synthetic", "error": "synthetic"},
            "roles": {"distance": "numeric", "error": "numeric"}, "communication_task": "relationship",
            "required_relationship": "distance -> error", "required_data_roles": ["distance", "error"],
            "pairing_requirement": "paired", "relationship_representation": "paired_observations",
            "provenance": {"source_id": "synthetic-relationship"},
        }
        contract.update(overrides)
        return contract

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

    def test_relationship_family_requires_data_before_synthetic_export(self):
        contract = self.relationship_contract()
        data = {"distance": [-2, 0, 4], "error": [-1, 2, 3]}
        plan = plan_figure(contract, data=data)
        self.assertEqual(plan["family_id"], "relationship.scatter")
        self.assertEqual(plan["relationship_bindings"], {"distance": "distance", "error": "error"})
        with tempfile.TemporaryDirectory() as directory:
            output = render_synthetic(plan, Path(directory) / "relationship.svg", data)
            self.assertTrue(output.exists())
        with self.assertRaisesRegex(ContractError, "INSUFFICIENT_RELATIONSHIP_DATA"):
            plan_figure(contract, data={"rho": 0.4, "p": 0.2, "n": 3})

    def test_relationship_family_is_rejected_for_incompatible_task(self):
        with self.assertRaisesRegex(ContractError, "INCOMPATIBLE_RELATIONSHIP_FAMILY"):
            plan_figure(self.relationship_contract(communication_task="distribution"), data={"distance": [1], "error": [2]})

    def test_legacy_summary_statistics_do_not_require_pairs(self):
        contract = {
            "contract_type": "figure_contract", "contract_version": "1.0", "purpose": "summary",
            "claim": {"primary": "summary statistics"}, "data_bindings": {"metrics": "synthetic"},
            "roles": {"metrics": "numeric", "model": "category"}, "communication_task": "model_comparison",
            "provenance": {"source_id": "synthetic-summary"},
        }
        self.assertEqual(plan_figure(contract)["family_id"], "comparison.metric_panels")


if __name__ == "__main__":
    unittest.main()
