# Changelog

All notable changes follow semantic versioning.

## 0.2.0 — 2026-09-18

- Separate ordinary sort-key generation from diagnostic trace allocation.
- Add half-open `CollationIndex::range` queries and allocation-free
  `CollationIndex::count_equal` lookups.
- Add opt-in Unicode 17 full-profile conformance validation for both
  non-ignorable and shifted modes.
- Expand behavioral coverage for configuration, public accessors, CLI parsing,
  browser boundaries, and quaternary/identical comparisons.
- Validate native, JavaScript, WebAssembly, and Wasm GC across Linux, macOS,
  and Windows, with public API drift and browser-adapter gates.
- Audit and minimize the Mooncakes publication payload.

## 0.1.0 — 2026-09-16

- Implement Unicode 17.0.0 DUCET singleton, expansion, contraction,
  discontiguous-contraction, and implicit-weight processing.
- Add version-aligned canonical decomposition and combining-class ordering.
- Add primary through identical strengths, shifted alternate handling,
  case-first options, backwards secondary comparison, and numeric mode.
- Add structured sort keys, explanation traces, detailed comparison reports,
  stable collection helpers, and cached `CollationIndex` searches.
- Add CLI commands and a static browser Collation Lab backed by MoonBit.
- Validate official non-ignorable and shifted short conformance profiles.
