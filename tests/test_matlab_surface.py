import unittest
from pathlib import Path


class MatlabSurfaceTests(unittest.TestCase):
    def test_required_native_surfaces_exist(self):
        root = Path(__file__).parents[1]
        required = [
            "matlab/core/mpPlanFigure.m", "matlab/core/mpFamilyRegistry.m", "matlab/core/mpRenderFigure.m",
            "matlab/core/mpBuildLayout.m", "matlab/core/mpApplyStyle.m", "matlab/core/mpAudit.m", "matlab/core/mpExport.m",
            "matlab/core/mpWriteEvidence.m",
            "matlab/families/prediction/mpRenderPredictionParity.m", "matlab/families/relationship/mpRenderRelationshipScatter.m",
            "matlab/families/comparison/mpRenderComparisonMetricPanels.m", "matlab/families/distribution/mpRenderDistributionHistogram.m",
            "matlab/families/trend/mpRenderTrendLine.m", "matlab/families/explainability/mpRenderExplainability.m",
            "matlab/metallurgy/mpMetallurgyPattern.m",
            "matlab/tests/run_matlab_smoke.m",
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


if __name__ == "__main__":
    unittest.main()
