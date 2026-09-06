import unittest

from src.matlab_sci_plot.registry import Registry


def family(identifier, roles, tasks):
    return {"manifest_type": "figure_family", "manifest_version": "1.0", "id": identifier,
            "communication_tasks": tasks, "data_roles_required": roles,
            "renderer_entrypoint": "tests.test_registry:dummy", "status": "active"}


def dummy(*args, **kwargs):
    return None


class RegistryTests(unittest.TestCase):
    def test_two_entries_are_discovered_without_switch(self):
        registry = Registry([family("prediction.parity", ["truth", "prediction"], ["validation"]), family("trend.line", ["ordered", "numeric"], ["trend"])])
        registry.bind_renderer("prediction.parity", dummy)
        self.assertEqual(registry.ids(), ["prediction.parity", "trend.line"])
        self.assertEqual(registry.compatible({"truth", "prediction"}, "validation")[0]["family_id"], "prediction.parity")


if __name__ == "__main__":
    unittest.main()
