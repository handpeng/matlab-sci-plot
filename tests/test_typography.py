import copy
import unittest

from src.matlab_sci_plot.style import GENERAL_STYLE, SCIENTIFIC_CONSTRAINTS, resolve_style
from src.matlab_sci_plot.typography import (
    CJKFontUnavailable, contains_cjk, inspect_cjk_text, load_font_policy, resolve_font,
)


class TypographyTests(unittest.TestCase):
    def test_required_positive_and_negative_strings(self):
        for text in ("温度", "热导率", "实验值 A", "粒径 (μm)", "样品_A"):
            self.assertTrue(contains_cjk(text), text)
        for text in ("Temperature", "W/(m·K)", "° C μ", "R^2 = -3", "", "\\alpha", "😀"):
            self.assertFalse(contains_cjk(text), text)
        self.assertFalse(contains_cjk([float("nan"), 0x4E00]))

    def test_unicode_blocks_and_supplementary_planes(self):
        # Independent representatives: radicals, punctuation, kana, bopomofo,
        # Hangul, extension A, unified, compatibility and extensions B-I.
        for point in (0x1100, 0x2E80, 0x2F00, 0x3002, 0x3042, 0x30A2, 0x3105,
                      0x3131, 0x31A0, 0x31C0, 0x3400, 0x4E00, 0x9FFF, 0xAC00,
                      0xF900, 0xFE10, 0xFE30, 0xFF01, 0xFF66, 0x20000, 0x2A700,
                      0x2B740, 0x2B820, 0x2CEB0, 0x2EBF0, 0x2F800, 0x30000, 0x31350):
            self.assertTrue(contains_cjk(chr(point)), hex(point))
        for point in (0x10FF, 0x1200, 0x2E7F, 0x304, 0x33FF, 0x4DC0, 0xA000,
                      0x1FFFF, 0x2EE60, 0x2FA20, 0x323B0):
            self.assertFalse(contains_cjk(chr(point)), hex(point))

    def test_policy_ranges_are_ordered_and_fonts_are_unique(self):
        policy = load_font_policy()
        self.assertEqual(len(policy["candidates"]), len(set(policy["candidates"])))
        self.assertGreaterEqual(len(policy["candidates"]), 2)
        previous = -1
        for first, last in policy["unicode_ranges"]:
            self.assertTrue(previous < first <= last <= 0x10FFFF)
            previous = last
            self.assertTrue(contains_cjk(chr(first)))
            self.assertTrue(contains_cjk(chr(last)))
        policy["candidates"].clear()
        self.assertTrue(load_font_policy()["candidates"])

    def test_contract_and_runtime_visible_labels_only(self):
        self.assertFalse(inspect_cjk_text({"purpose": "博士论文", "claim": {"primary": "温度"},
                                          "data_bindings": {"x": "中文路径.csv"}}))
        self.assertTrue(inspect_cjk_text({"labels": {"x": "温度"}}))
        self.assertTrue(inspect_cjk_text({"panels": [{"panel_label": "(a) 实验"}]}))
        for visible in (["实验值", "预测值"], {"group": ["基准模型"]}, ["特征一"]):
            self.assertTrue(inspect_cjk_text({}, visible))

    def test_english_and_scientific_state_unchanged(self):
        before = copy.deepcopy((GENERAL_STYLE, SCIENTIFIC_CONSTRAINTS))
        style = resolve_style("single_column", user_overrides={"typography": {"font_name": "Arbitrary English Font"}})
        snapshot = copy.deepcopy(style)
        state = resolve_font(style["typography"]["font_name"], False, [])
        self.assertEqual(state["resolved_font"], "Arbitrary English Font")
        self.assertEqual(state["resolution"], "requested_english")
        resolve_font(style["typography"]["font_name"], True, load_font_policy()["candidates"])
        self.assertEqual(style, snapshot)
        self.assertEqual((GENERAL_STYLE, SCIENTIFIC_CONSTRAINTS), before)
        self.assertEqual(resolve_style("single_column")["typography"]["font_name"], "Arial")

    def test_governed_requested_and_ordered_fallback(self):
        candidates = load_font_policy()["candidates"]
        requested = resolve_font(candidates[-1], True, list(reversed(candidates)))
        self.assertEqual(requested["resolved_font"], candidates[-1])
        self.assertEqual(requested["resolution"], "requested_cjk")
        for preferred in ("Arial", "Arbitrary Installed Font", candidates[0]):
            result = resolve_font(preferred, True, ["Arial", "Arbitrary Installed Font", *reversed(candidates[1:])])
            self.assertEqual(result["resolved_font"], candidates[1])
            self.assertEqual(result["resolution"], "fallback_cjk")

    def test_unavailable_and_arbitrary_installed_fail_closed(self):
        for available in ([], ["DefinitelyNotInstalledA"], ["Arial", "Arbitrary Installed Font"]):
            with self.assertRaises(CJKFontUnavailable):
                resolve_font("Arbitrary Installed Font", True, available)
        first = load_font_policy()["candidates"][0]
        with self.assertRaises(CJKFontUnavailable):
            resolve_font(first.lower(), True, [first.lower()])


if __name__ == "__main__":
    unittest.main()
