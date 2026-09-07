import unittest

from src.matlab_sci_plot.layout import LAYOUT_IDS, apply_panel_labels, build_layout


class LayoutTests(unittest.TestCase):
    def test_all_semantic_primitives(self):
        for identifier in LAYOUT_IDS:
            plan = build_layout(identifier, 4 if identifier == "small_multiples" else 1)
            self.assertEqual(plan["layout_id"], identifier)

    def test_hero_has_unequal_span_and_reading_order(self):
        plan = build_layout("hero_plus_diagnostics")
        self.assertEqual(plan["slots"][0]["row_span"], 2)
        self.assertEqual(plan["reading_order"], ["A", "B", "C"])

    def test_independent_scale_is_disclosed(self):
        plan = build_layout("small_multiples", 4, shared_scales=False, independent_scales=True)
        self.assertEqual(plan["scale_policy"], "independent")
        self.assertTrue(plan["independent_scale_disclosure"])

    def test_conflicting_scale_policy_fails(self):
        with self.assertRaises(ValueError):
            build_layout("paired", 2, shared_scales=True, independent_scales=True)

    def test_outer_labels_are_explicit(self):
        plan = apply_panel_labels(build_layout("paired"), ["A", "B"])
        self.assertIn("outer_axis_labels", plan)


if __name__ == "__main__":
    unittest.main()
