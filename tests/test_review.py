import tempfile
import unittest
from pathlib import Path

from src.matlab_sci_plot.families import plan_figure
from src.matlab_sci_plot.review import apply_repairs, export_evidence, review_record
from src.matlab_sci_plot.contracts import ContractError


def plan():
    return plan_figure({"contract_type":"figure_contract","contract_version":"1.0","purpose":"manuscript","claim":{"primary":"validate"},"data_bindings":{"truth":"t","prediction":"p"},"roles":{"truth":"truth","prediction":"prediction"},"communication_task":"validation","provenance":{"source_id":"synthetic"}})


class ReviewTests(unittest.TestCase):
    def test_scientific_failure_blocks_acceptance_and_export(self):
        with self.assertRaises(ContractError):
            review_record("accept", "FAIL")
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(PermissionError):
                export_evidence(plan(), review_record("reject", "FAIL"), directory)

    def test_allow_list_and_forbidden_repair(self):
        updated = apply_repairs(plan(), [{"repair_id":"font_scale", "value":1.1}, {"repair_id":"legend_relocation", "value":"southoutside"}])
        self.assertEqual(updated["style_adjustments"]["font_scale"], 1.1)
        with self.assertRaises(ContractError):
            apply_repairs(plan(), [{"repair_id":"unknown"}])
        with self.assertRaises(ContractError):
            apply_repairs(plan(), [{"repair_id":"font_scale", "source_values": [1]}])

    def test_accept_export_writes_hash_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            manifest = export_evidence(plan(), review_record("accept", "PASS"), Path(directory), source_data={"source_id":"synthetic"})
            self.assertTrue((Path(directory) / "figure_preview.svg").exists())
            self.assertTrue(manifest["outputs"][0]["sha256"])

    def test_relationship_prerequisite_blocks_governed_evidence(self):
        relationship = {
            "contract_type": "figure_contract", "contract_version": "1.0", "purpose": "relationship",
            "claim": {"primary": "distance and error"},
            "data_bindings": {"distance": "synthetic", "error": "synthetic"},
            "roles": {"distance": "numeric", "error": "numeric"}, "communication_task": "relationship",
            "required_relationship": "distance -> error", "required_data_roles": ["distance", "error"],
            "pairing_requirement": "paired", "relationship_representation": "paired_observations",
            "provenance": {"source_id": "synthetic"},
        }
        plan = plan_figure(relationship)
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(Exception, "INSUFFICIENT_RELATIONSHIP_DATA"):
                export_evidence(plan, review_record("accept", "PASS"), directory)
            self.assertFalse((Path(directory) / "figure_manifest.json").exists())


if __name__ == "__main__":
    unittest.main()
