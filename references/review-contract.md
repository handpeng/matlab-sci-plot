# Review Contract

Review records use `record_version=1.0` and verdict `accept|repair|reject`. Scientific correctness is a hard PASS/FAIL gate. The allow-list in `review.py` contains presentation-only repairs; unknown ids and scientific mutations fail closed. Accepted exports include a SHA-256 output hash and contract/skill versions.

Native manifests additionally bind the actual runtime `typography` state from
`mpApplyTypography`: CJK presence, requested/resolved font and policy/route.
The evidence schema and Python validator reject malformed state; the native
writer checks policy consistency. Existing evidence callers may omit this
additive state. The Python synthetic exporter does not claim native font use.

The historical `qualification_timestamp` field records export time. Neither
that field nor an accepted synthetic smoke review establishes independent CJK
qualification. PNG appearance and vector-PDF glyph correctness require Stage 3
review; see [typography](typography.md).
