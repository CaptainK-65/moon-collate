# Performance notes

MoonCollate v0.2.0 targets predictable repeated comparison rather than a
single machine-specific headline number.

## Changes in v0.2.0

- `sort_key` now collects collation elements directly and does not allocate
  explanation `TraceStep` records. `explain` remains the explicit diagnostic
  path.
- Collection sorting still generates one key per input value and compares the
  cached keys.
- `CollationIndex::count_equal` computes the difference between binary-search
  bounds without allocating the matching values array.
- `CollationIndex::range` reuses cached keys and two lower-bound searches.

These are structural allocation reductions, not claims about a universal
speedup. Results depend on text, configuration, backend, toolchain, CPU, and
warm-up policy.

## Reproducible measurement protocol

Record the MoonBit version, operating system, backend, CPU, corpus hash,
collator options, warm-up count, measured iterations, and median elapsed time.
Compare the same corpus and command against tagged releases. At minimum use:

1. ASCII identifiers with numeric runs;
2. accented Latin text with canonical-equivalent spellings;
3. punctuation-heavy text in shifted mode;
4. contractions, expansions, and implicit-weight code points;
5. repeated equality and range queries over a prebuilt index.

Correctness gates (`moon test --target all` and both conformance profiles) must
pass before performance results are accepted. Timing output is evidence for a
specific environment only and must not replace those gates.
