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


if __name__ == "__main__":
    unittest.main()
