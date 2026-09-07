# Legacy Migration

`docs/LEGACY_MIGRATION_MATRIX.json` is the authoritative 17/17 mapping. Legacy scripts remain available as historical assets, but V1 planning uses family ids, semantic layouts, shared metric helpers, final-size presets, and semantic palettes. Unsafe defaults are intentionally changed: negative R2 remains negative, `jet` is not a quantitative default, generic `95% Band` is omitted without interval semantics, dual-axis/radar are exceptional, and `tight_subplot`/A4 window sizing are compatibility-only.
