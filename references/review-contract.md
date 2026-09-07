# Review Contract

Review records use `record_version=1.0` and verdict `accept|repair|reject`. Scientific correctness is a hard PASS/FAIL gate. The allow-list in `review.py` contains presentation-only repairs; unknown ids and scientific mutations fail closed. Accepted exports include a SHA-256 output hash and contract/skill versions.
