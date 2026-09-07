"""Independent schema/runtime agreement; jsonschema is a test dependency only."""
import copy
import json
import tempfile
import unittest
from pathlib import Path

from jsonschema import Draft202012Validator

from src.matlab_sci_plot.contracts import ContractError, load_json, validate_contract

ROOT = Path(__file__).parents[1]


class ContractSchemaTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        schema = json.loads((ROOT / "schemas/figure_contract.schema.json").read_text(encoding="utf-8"))
        Draft202012Validator.check_schema(schema)
        cls.validator = Draft202012Validator(schema)
        cls.chinese = load_json(ROOT / "examples/chinese_temperature_property.json")

    def check_agreement(self, payload, valid):
        self.assertEqual(self.validator.is_valid(payload), valid, list(self.validator.iter_errors(payload)))
        if valid:
            self.assertEqual(validate_contract(payload), payload)
        else:
            with self.assertRaises(ContractError):
                validate_contract(payload)

    def test_utf8_roundtrip_and_all_existing_examples(self):
        for path in (ROOT / "examples").glob("*.json"):
            with self.subTest(path=path.name):
                self.check_agreement(load_json(path), True)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "contract.json"
            path.write_text(json.dumps(self.chinese, ensure_ascii=False), encoding="utf-8")
            self.assertIn("热导率".encode("utf-8"), path.read_bytes())
            self.assertEqual(load_json(path), self.chinese)

    def test_native_qualified_composite_shape(self):
        p1 = copy.deepcopy(self.chinese)
        p1.update(panel_label="(a)", labels={"x": "Temperature", "y": "Conductivity"},
                  units={"x": "degC", "y": "W/(m K)"})
        p2 = copy.deepcopy(p1)
        p2.update(panel_label="(b)", communication_task="distribution", roles={"value": "numeric"},
                  data_bindings={"value": "synthetic"}, labels={"value": "Error"},
                  units={"value": "W/(m K)"}, required_unit_roles=["value"])
        composite = copy.deepcopy(p1)
        composite.update(data_bindings={}, communication_task="composite", layout="paired",
                         final_size={"width_mm": 178, "height_mm": 90}, panels=[p1, p2])
        composite["provenance"]["candidate_sha"] = "test-sha"
        self.check_agreement(composite, True)
        composite["panels"][1]["unknown"] = "未知"
        self.check_agreement(composite, False)

    def test_existing_scientific_audit_surfaces_are_structurally_valid(self):
        # These are scientific negative controls, not malformed JSON contracts.
        controls = [{"palette_id": "jet"}, {"category_count": 16, "max_categories": 12},
                    {"scale_policy": "independent"}, {"sample_size_required": True},
                    {"required_unit_roles": ["x", "y"], "units": {"x": "degC"}},
                    {"encoding": "bar", "zero_baseline": True, "axis_limits": {"y": [0.5, 1.5]}},
                    {"n": 3, "n_common": 2, "n_by_model": {"baseline": 2},
                     "claim": {"primary": "sample disclosure", "n_common": 2}}]
        for control in controls:
            with self.subTest(control=control):
                self.check_agreement({**self.chinese, **control}, True)

    def test_unknown_and_invalid_fields_fail_closed(self):
        controls = [{"unknown": "未知"}, {"title": "not consumed by runtime"},
                    {"labels": {"x": 12}}, {"units": {"x": None}}, {"roles": []},
                    {"claim": {"primary": "test", "unexpected": True}},
                    {"purpose": 3}, {"communication_task": []}, {"panel_label": []},
                    {"data_bindings": {}}, {"panels": []}, {"panels": [{}]},
                    {"final_size": {"width_mm": -1, "height_mm": 90}},
                    {"final_size": {"width_mm": 178, "height_mm": 90, "dpi": 300}},
                    {"required_unit_roles": [1]}, {"panel_count": True},
                    {"contract_version": "1.1"}, {"n": -1},
                    {"zero_baseline": "true"}, {"axis_limits": {"y": [1]}},
                    {"analysis_authorization": {"class_c": "yes"}}]
        for control in controls:
            with self.subTest(control=control):
                self.check_agreement({**self.chinese, **control}, False)


if __name__ == "__main__":
    unittest.main()
