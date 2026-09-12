import math
import unittest

from src.matlab_sci_plot.audit import audit_contract, require_class_c_authority
from src.matlab_sci_plot.data import (RelationshipDataError, common_valid_mask, infer_roles, r2, summary,
                                      validate_relationship_data)
from src.matlab_sci_plot.contracts import ContractError, validate_contract, validate_relationship_semantics


class DataIntegrityTests(unittest.TestCase):
    @staticmethod
    def relationship_contract(**overrides):
        contract = {
            "contract_type": "figure_contract", "contract_version": "1.0",
            "purpose": "relationship validation", "claim": {"primary": "distance and error are related"},
            "data_bindings": {"distance": "synthetic", "error": "synthetic"},
            "roles": {"distance": "numeric", "error": "numeric", "rho": "numeric", "p": "numeric", "n": "numeric"},
            "communication_task": "relationship", "required_relationship": "distance -> error",
            "required_data_roles": ["distance", "error"], "pairing_requirement": "paired",
            "relationship_representation": "paired_observations", "annotation_roles": ["rho", "p", "n"],
            "provenance": {"source_id": "synthetic-relationship"},
        }
        contract.update(overrides)
        return contract

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
        findings = audit_contract({"requested_layers": {"uncertainty": True}, "encoding": "bar", "dual_y_axis": True, "category_count": 20, "scale_policy": "independent", "palette_id": "jet", "comparison_policy": "model_specific", "data_bindings": {"temperature": {"physical_quantity": True}}, "units": {}})
        codes = {finding["code"] for finding in findings}
        self.assertIn("UNCERTAINTY_UNDECLARED", codes)
        self.assertIn("BAR_ZERO_BASELINE", codes)
        self.assertIn("DUAL_AXIS_UNJUSTIFIED", codes)
        self.assertIn("CATEGORICAL_OVERPOPULATION", codes)
        self.assertIn("INDEPENDENT_SCALE_UNDISCLOSED", codes)
        self.assertIn("QUANTITATIVE_RAINBOW_FORBIDDEN", codes)
        self.assertIn("COMMON_SAMPLE_UNDISCLOSED", codes)
        self.assertIn("UNIT_UNDECLARED", codes)
        with self.assertRaises(PermissionError):
            require_class_c_authority({}, "fit_regression")

    def test_relationship_data_is_paired_and_annotations_do_not_substitute(self):
        contract = self.relationship_contract()
        validate_contract(contract)
        data = {"distance": [-3.0, 0.0, 4.0], "error": [-2.0, 1.0, 5.0], "rho": -0.4, "p": 0.2, "n": 3}
        result = validate_relationship_data(contract, data)
        self.assertEqual(result["x"], data["distance"])
        self.assertEqual(result["y"], data["error"])
        self.assertEqual(result["representation"], "paired_observations")

        summary_only = {key: data[key] for key in ("rho", "p", "n")}
        with self.assertRaisesRegex(RelationshipDataError, "INSUFFICIENT_RELATIONSHIP_DATA"):
            validate_relationship_data(contract, summary_only)

    def test_relationship_pairing_and_numeric_fail_closed(self):
        contract = self.relationship_contract()
        with self.assertRaisesRegex(RelationshipDataError, "RELATIONSHIP_PAIRING_LENGTH_MISMATCH"):
            validate_relationship_data(contract, {"distance": [1, 2], "error": [3]})
        with self.assertRaisesRegex(RelationshipDataError, "INSUFFICIENT_RELATIONSHIP_DATA"):
            validate_relationship_data(contract, {"distance": [1, float("nan")], "error": [3, 4]})
        with self.assertRaisesRegex(RelationshipDataError, "INSUFFICIENT_RELATIONSHIP_DATA"):
            validate_relationship_data(contract, None)

    def test_explicit_aggregate_representation_is_bounded(self):
        contract = self.relationship_contract(
            pairing_requirement="aggregate", relationship_representation="authorized_aggregate",
            minimum_data_requirement=1,
        )
        result = validate_relationship_data(contract, {"distance": -1.5, "error": 0.25})
        self.assertEqual(result["representation"], "authorized_aggregate")
        with self.assertRaisesRegex(RelationshipDataError, "INSUFFICIENT_RELATIONSHIP_DATA"):
            validate_relationship_data(contract, {"distance": [1, 2], "error": [3, 4]})

    def test_legacy_summary_contract_remains_legal(self):
        legacy = {
            "contract_type": "figure_contract", "contract_version": "1.0", "purpose": "summary",
            "claim": {"primary": "metrics"}, "data_bindings": {"metrics": "synthetic"},
            "roles": {"metrics": "numeric", "model": "category"},
            "communication_task": "model_comparison", "provenance": {"source_id": "synthetic-summary"},
        }
        self.assertIsNone(validate_relationship_data(legacy, {"rho": 0.2, "p": 0.1, "n": 5}))

    def test_provider_mapping_is_explicit_and_cannot_drop_required_roles(self):
        contract = self.relationship_contract()
        plan = {
            "contract_type": "figure_plan", "contract_version": "1.0", "family_id": "relationship.scatter",
            "layout_id": "single", "backend_id": "matlab", "style_id": "publication.general",
            "required_relationship": contract["required_relationship"], "required_data_roles": contract["required_data_roles"],
            "pairing_requirement": contract["pairing_requirement"], "relationship_representation": contract["relationship_representation"],
            "roles": {}, "relationship_bindings": {"distance": "provider_distance", "error": "provider_error"},
        }
        data = {"provider_distance": [-3, 0, 4], "provider_error": [-2, 1, 5]}
        result = validate_relationship_data(plan, data, family_id="relationship.scatter")
        self.assertEqual(result["x"], data["provider_distance"])
        dropped = dict(plan)
        dropped["relationship_bindings"] = {"distance": "provider_distance"}
        with self.assertRaisesRegex(ContractError, "RELATIONSHIP_ROLE_BINDING_MISSING"):
            validate_relationship_data(dropped, data, family_id="relationship.scatter")

    def test_stale_semantics_and_unauthorized_operations_fail_closed(self):
        with self.assertRaisesRegex(ContractError, "UNKNOWN_RELATIONSHIP_SEMANTICS"):
            validate_relationship_semantics({"required_relationship": "distance -> stale"})
        with self.assertRaisesRegex(ContractError, "UNAUTHORIZED_RELATIONSHIP_TRANSFORMATION"):
            validate_relationship_semantics({
                "required_relationship": "distance -> error", "required_data_roles": ["distance", "error"],
                "roles": {"distance": "numeric", "error": "numeric"},
                "pairing_requirement": "paired", "relationship_representation": "paired_observations",
                "allowed_transformations": ["smooth"],
            })
        with self.assertRaisesRegex(ContractError, "RELATIONSHIP_ANNOTATION_ROLE_OVERLAP"):
            validate_relationship_semantics({
                "required_relationship": "distance -> error", "required_data_roles": ["distance", "error"],
                "roles": {"distance": "numeric", "error": "numeric"},
                "pairing_requirement": "paired", "relationship_representation": "paired_observations",
                "annotation_roles": ["distance"],
            })


if __name__ == "__main__":
    unittest.main()
