import math
import unittest

from src.matlab_sci_plot.audit import audit_contract, require_class_c_authority
from src.matlab_sci_plot.data import common_valid_mask, infer_roles, r2, summary


class DataIntegrityTests(unittest.TestCase):
    def test_common_mask_and_negative_r2(self):
        truth = [0.0, 1.0, 2.0, 3.0]
        predictions = {"good": [0.0, 1.0, 2.0, 3.0], "bad": [3.0, 2.0, 1.0, 0.0]}
        result = summary(truth, predictions)
        self.assertEqual(result["n_common"], 4)
        self.assertLess(result["metrics"]["bad"]["r2"], 0.0)

    def test_missing_rows_are_common_and_zero_is_valid(self):
        mask = common_valid_mask([0, 1, "", 3], {"a": [0, 1, 2, 3], "b": [0, 1, 2, 3]})
        self.assertEqual(mask, [True, True, False, True])

    def test_explicit_roles_override_inference(self):
        rows = [{"time": "1", "value": "2.0", "group": "A"}, {"time": "2", "value": "3.0", "group": "B"}]
        roles = infer_roles(rows, {"time": "ordered"})
        self.assertIn("time", roles["ordered"])

    def test_negative_controls(self):
        findings = audit_contract({"requested_layers": {"uncertainty": True}, "encoding": "bar", "dual_y_axis": True})
        codes = {finding["code"] for finding in findings}
        self.assertIn("UNCERTAINTY_UNDECLARED", codes)
        self.assertIn("BAR_ZERO_BASELINE", codes)
        self.assertIn("DUAL_AXIS_UNJUSTIFIED", codes)
        with self.assertRaises(PermissionError):
            require_class_c_authority({}, "fit_regression")


if __name__ == "__main__":
    unittest.main()
