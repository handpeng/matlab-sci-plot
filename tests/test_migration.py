import unittest

from src.matlab_sci_plot.migration import load_matrix, status_for


class MigrationTests(unittest.TestCase):
    def test_all_legacy_templates_are_mapped(self):
        matrix = load_matrix()
        self.assertEqual(len(matrix["entries"]), 17)
        self.assertEqual(status_for("scripts/template_scatter.m")["compatibility_status"], "mapped_with_behavior_change")

    def test_unsafe_legacy_defaults_are_explicitly_demoted(self):
        entries = load_matrix()["entries"]
        radar = [entry for entry in entries if "spider_only" in entry["source_path"]][0]
        dual = [entry for entry in entries if "dual_axis" in entry["source_path"]][0]
        self.assertEqual(radar["compatibility_status"], "legacy_only")
        self.assertEqual(dual["deprecation_status"], "deprecated")


if __name__ == "__main__":
    unittest.main()
