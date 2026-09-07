# Typography

The MATLAB backend applies explicit font and size values after final-size resolution. Typography is presentation state and must not alter scientific data, labels, units, or claims.

## Current released scope

The v1.1.1 release inherits its scientific runtime qualification from the v1.1.0 Stage 3 run on MATLAB R2023b. That qualification used English text and Arial. Chinese/CJK rendering is therefore **not yet a released qualification claim**.

UTF-8 text can pass through existing contract/runtime surfaces, but final CJK font selection and vector-PDF correctness are not currently governed by a qualified fallback policy.

## Planned CJK extension

The active Stage 1 governance plan is `TODO.md`, with research basis in `docs/V1_CJK_RESEARCH_BASIS.md`.

The planned implementation must:

- preserve Unicode text without transliteration;
- discover runtime fonts rather than assume a platform font exists;
- use a centralized CJK-aware typography resolver;
- apply the resolved figure font consistently to visible text;
- fail closed for governed final export when CJK is present and no approved font is available;
- preserve current English-only behavior;
- qualify Chinese PNG and vector PDF separately in Stage 3.

Never repair overlap or font problems by hiding scientific labels, changing units, rasterizing all vector output to conceal glyph failures, or modifying scientific values.
