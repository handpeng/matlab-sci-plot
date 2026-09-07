import copy
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from jsonschema import Draft202012Validator

from src.matlab_sci_plot.contracts import ContractError, validate_contract
from src.matlab_sci_plot.review import export_evidence, review_record
from src.matlab_sci_plot.typography import load_font_policy, resolve_font
from tests.test_review import plan


class TypographyEvidenceTests(unittest.TestCase):
    def setUp(self):
        root = Path(__file__).parents[1]
        self.schema = json.loads((root / "schemas/evidence_manifest.schema.json").read_text())
        Draft202012Validator.check_schema(self.schema)
        self.validator = Draft202012Validator(self.schema)
        self.base = {"manifest_type": "figure_evidence", "manifest_version": "1.0", "skill_version": "1.1.1",
                     "contract_versions": {"figure_plan": "1.0"}, "outputs": [],
                     "candidate_sha": "synthetic-sha", "qualification_timestamp": "2026-09-08T00:00:00Z",
                     "renderer_identity": ["mpRenderRelationshipScatter"], "family_id": "relationship.scatter"}

    def test_legacy_english_evidence_and_hashes(self):
        with tempfile.TemporaryDirectory() as directory:
            manifest = export_evidence(plan(), review_record("accept", "PASS"), directory)
            self.validator.validate(manifest)
            self.assertNotIn("typography", manifest)  # Python synthetic exporter makes no native font claim.
            artifact = Path(directory) / manifest["outputs"][0]["path"]
            self.assertEqual(manifest["outputs"][0]["sha256"], hashlib.sha256(artifact.read_bytes()).hexdigest())

    def test_native_shape_and_additive_typography(self):
        candidates = load_font_policy()["candidates"]
        states = [resolve_font("Arial", False, []), resolve_font(candidates[-1], True, candidates),
                  resolve_font("Arial", True, candidates)]
        for state in states:
            manifest = {**self.base, "typography": state}
            snapshot = copy.deepcopy(manifest)
            self.validator.validate(manifest)
            self.assertEqual(validate_contract(manifest), snapshot)
        self.validator.validate(self.base)
        validate_contract(self.base)

    def test_malformed_state_fails_schema_and_python(self):
        good = resolve_font("Arial", True, load_font_policy()["candidates"])
        controls = [{"contains_cjk": "true"}, {"requested_font": ""}, {"resolved_font": 3},
                    {"resolved_font": ""}, {"font_policy_id": None}, {"resolution": "qualified"},
                    {"pdf_font_embedding": "PASS"}]
        for control in controls:
            payload = {**self.base, "typography": {**good, **control}}
            self.assertFalse(self.validator.is_valid(payload))
            with self.assertRaises(ContractError):
                validate_contract(payload)
        for key in good:
            state = dict(good); del state[key]
            payload = {**self.base, "typography": state}
            self.assertFalse(self.validator.is_valid(payload))
            with self.assertRaises(ContractError):
                validate_contract(payload)

    def test_semantically_inconsistent_state_fails_closed(self):
        good = resolve_font("Arial", True, load_font_policy()["candidates"])
        for control in ({"resolved_font": "Arial"}, {"font_policy_id": "invented-policy"},
                        {"policy_version": "99.0"}, {"resolution": "requested_english"},
                        {"resolution": "requested_cjk"}, {"contains_cjk": False}):
            with self.assertRaises(ContractError):
                validate_contract({**self.base, "typography": {**good, **control}})


if __name__ == "__main__":
    unittest.main()
