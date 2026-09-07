import subprocess
import sys
import unittest
from pathlib import Path


class IntegrationTests(unittest.TestCase):
    def test_integration_entrypoint(self):
        root = Path(__file__).parents[1]
        result = subprocess.run([sys.executable, "scripts/integration_check.py"], cwd=root, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("LEGACY_MIGRATION=17/17", result.stdout)
        self.assertIn("REVIEW_EVIDENCE_LOOP=PASS", result.stdout)


if __name__ == "__main__":
    unittest.main()
