import unittest
from pathlib import Path


class MatlabSurfaceTests(unittest.TestCase):
    def test_required_native_surfaces_exist(self):
        root = Path(__file__).parents[1]
        required = [
            "matlab/core/mpPlanFigure.m", "matlab/core/mpFamilyRegistry.m", "matlab/core/mpRenderFigure.m",
            "matlab/core/mpBuildLayout.m", "matlab/core/mpApplyStyle.m", "matlab/core/mpAudit.m", "matlab/core/mpExport.m",
            "matlab/core/mpWriteEvidence.m",
            "matlab/core/mpTypographyPolicy.m", "matlab/core/mpContainsCJK.m",
            "matlab/core/mpResolveFont.m", "matlab/core/mpApplyTypography.m",
            "matlab/core/mpAxisLabel.m", "matlab/core/mpDescriptiveMetrics.m", "matlab/core/mpReviewAccepted.m",
            "matlab/families/prediction/mpRenderPredictionParity.m", "matlab/families/relationship/mpRenderRelationshipScatter.m",
            "matlab/families/comparison/mpRenderComparisonMetricPanels.m", "matlab/families/distribution/mpRenderDistributionHistogram.m",
            "matlab/families/trend/mpRenderTrendLine.m", "matlab/families/explainability/mpRenderExplainability.m",
            "matlab/metallurgy/mpMetallurgyPattern.m",
            "matlab/tests/run_matlab_smoke.m", "matlab/tests/run_matlab_qualification.m",
            "matlab/tests/run_matlab_typography_smoke.m",
        ]
        for relative in required:
            self.assertTrue((root / relative).exists(), relative)

    def test_native_dispatch_is_manifest_entrypoint_based(self):
        root = Path(__file__).parents[1]
        registry = (root / "matlab/core/mpFamilyRegistry.m").read_text(encoding="utf-8")
        renderer = (root / "matlab/core/mpRenderFigure.m").read_text(encoding="utf-8")
        self.assertIn("jsondecode", registry)
        self.assertIn("entry = struct()", registry)
        self.assertIn("cellstr(string(payload.communication_tasks))", registry)
        self.assertIn("str2func", renderer)
        self.assertIn("mpWriteEvidence", renderer)
        self.assertIn("ReviewGate", renderer)
        self.assertNotIn("switch plan.family_id", renderer)
        smoke = (root / "matlab/tests/run_matlab_smoke.m").read_text(encoding="utf-8")
        self.assertNotIn("switch plan.family_id", smoke)

    def test_planner_excludes_unimplemented_matlab_entrypoints(self):
        root = Path(__file__).parents[1]
        planner = (root / "matlab/core/mpPlanFigure.m").read_text(encoding="utf-8")
        self.assertIn("hasNativeRenderer", planner)
        self.assertIn("mpRenderUnsupportedFamily", planner)
        self.assertIn("layoutId = 'single'", planner)

    def test_native_scientific_and_evidence_gates_are_complete(self):
        root = Path(__file__).parents[1]
        audit = (root / "matlab/core/mpAudit.m").read_text(encoding="utf-8")
        for code in ["QUANTITATIVE_RAINBOW_FORBIDDEN", "UNIT_UNDECLARED", "SAMPLE_SIZE_UNDISCLOSED",
                     "INDEPENDENT_SCALE_UNDISCLOSED", "COMMON_SAMPLE_UNDISCLOSED",
                     "MISLEADING_TRUNCATED_AXIS", "CATEGORICAL_OVERPOPULATION"]:
            self.assertIn(code, audit)
        evidence = (root / "matlab/core/mpWriteEvidence.m").read_text(encoding="utf-8")
        for field in ["candidate_sha", "qualification_timestamp", "renderer_identity", "family_id"]:
            self.assertIn(field, evidence)
        renderer = (root / "matlab/core/mpRenderFigure.m").read_text(encoding="utf-8")
        self.assertIn("plan.panels", renderer)
        self.assertIn("mpReviewAccepted", renderer)
        self.assertIn("mpExport", renderer)


if __name__ == "__main__":
    unittest.main()
