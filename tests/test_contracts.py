import unittest

from src.matlab_sci_plot.contracts import ContractError, validate_contract


class ContractTests(unittest.TestCase):
    def test_figure_contract_and_plan_envelopes(self):
        contract = validate_contract({
            "contract_type": "figure_contract", "contract_version": "1.0",
            "purpose": "manuscript", "claim": {"primary": "prediction agrees"},
            "data_bindings": {"table": "external.csv"}, "provenance": {"source_id": "fixture"}
        })
        self.assertEqual(contract["contract_version"], "1.0")
        plan = validate_contract({
            "contract_type": "figure_plan", "contract_version": "1.0",
            "family_id": "prediction.parity", "layout_id": "single",
            "backend_id": "matlab", "style_id": "publication"
        })
        self.assertEqual(plan["family_id"], "prediction.parity")

    def test_unsupported_major_fails_closed(self):
        with self.assertRaises(ContractError):
            validate_contract({"contract_type": "figure_plan", "contract_version": "2.0", "family_id": "x", "layout_id": "single", "backend_id": "matlab", "style_id": "x"})

    def test_scientific_failure_cannot_be_accepted(self):
        with self.assertRaises(ContractError):
            validate_contract({"record_type": "figure_review", "record_version": "1.0", "verdict": "accept", "scientific_correctness": "FAIL", "dimensions": {}})

    def test_relationship_object_identity_is_governed(self):
        payload = {
            "contract_type": "figure_contract", "contract_version": "1.0",
            "purpose": "validation", "claim": {"primary": "distance explains error"},
            "data_bindings": {"distance": "synthetic", "error": "synthetic"},
            "roles": {"distance": "numeric", "error": "numeric"},
            "required_relationship": {"id": "distance_to_error", "x_role": "distance", "y_role": "error"},
            "required_data_roles": ["distance", "error"],
            "pairing_requirement": "paired", "relationship_representation": "paired_observations",
            "provenance": {"source_id": "synthetic"},
        }
        self.assertEqual(validate_contract(payload)["required_relationship"]["id"], "distance_to_error")
        for bad in (
            {"id": "unknown", "x_role": "distance", "y_role": "error"},
            {"id": "distance_to_error", "x_role": "distance", "y_role": "wrong"},
        ):
            with self.subTest(bad=bad):
                with self.assertRaises(ContractError):
                    validate_contract({**payload, "required_relationship": bad})


if __name__ == "__main__":
    unittest.main()
