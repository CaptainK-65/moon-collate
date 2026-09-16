# Architecture

MoonCollate keeps the portable collation core separate from data generation,
command-line I/O, and the browser demo.

```text
String
  -> NFD normalization
  -> Unicode scalar sequence
  -> longest DUCET mapping match
  -> collation element stream
  -> alternate/case/secondary transforms
  -> level buffers
  -> SortKey or direct comparison
```

## Packages and ownership

The root package owns all public types: `Collator`, `SortKey`,
`CollationElement`, `CollationTrace`, and configuration enums. Low-level table
lookup and generated data remain implementation details. CLI and web adapters
translate external input into root-package calls without owning collation
semantics.

## Data pipeline

`tools/generate_ducet.mbtx` parses the pinned Unicode 17.0.0 `allkeys.txt` and
emits deterministic MoonBit lookup data. The generator records source hashes,
the Unicode version, single-code-point mappings, contractions, expansions, and
implicit-weight ranges. Generated files are reviewed but excluded from
hand-written source metrics.

## Comparison invariant

For any strings `a` and `b` and one `Collator` configuration, the sign of
`compare(a, b)` must equal the lexicographic comparison of `sort_key(a)` and
`sort_key(b)`. Property tests protect this invariant across deterministic
generated corpora.
