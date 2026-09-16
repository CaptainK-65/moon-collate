# Algorithm notes

This document connects the implementation layout to UTS #10. It is an
engineering guide, not a replacement for the Unicode specification.

## 1. Version-aligned NFD

UCA begins from Normalization Form D. Mixing UCA 17 tables with Unicode 16
canonical combining classes produced observable conformance failures for new
Unicode 17 marks, so MoonCollate pins `UnicodeData.txt` alongside `allkeys.txt`.

`tools/generate_normalization.mbtx` extracts only canonical decomposition and
non-zero combining-class records. At runtime, Hangul syllables use the
algorithmic decomposition from the Unicode Standard; other mappings use a
binary-searched table. A stable insertion pass reorders non-starters without
moving them across starters.

The implementation intentionally omits compatibility decomposition,
composition, and the other normalization forms. Those operations are outside
the collation core and remain the responsibility of a general normalization
library.

## 2. Longest table matching

The DUCET generator separates singleton mappings from contractions. Singleton
keys use binary search. At each input position the matcher considers the
longest contraction whose first scalar matches.

NFD can place a lower-combining-class mark between a starter and a later mark
that participates in a contraction. MoonCollate therefore implements UCA
discontiguous matching. A candidate can skip only non-starters with a lower
canonical combining class than the next contraction component. Multi-scalar
extensions also require each intermediate prefix to exist in the table, which
implements the incremental rule in UTS #10 S2.1 rather than accepting arbitrary
subsequences.

Skipped characters remain in the collation-element stream. The explanation
trace labels these decisions as `DUCET discontiguous contraction` so regressions
can be diagnosed without inspecting generated arrays.

## 3. Expansions and elements

A DUCET mapping can emit multiple collation elements. Generated arrays store
element starts and lengths, followed by parallel primary, secondary, tertiary,
and variable arrays. This representation avoids allocating a nested object
graph at module initialization while keeping generation deterministic.

Zero weights are omitted from each key level. As a result, arrays compare with
ordinary lexicographic rules and an absent trailing weight behaves like the
UCA level separator.

## 4. Implicit weights

Code points absent from DUCET receive two derived collation elements. The
implementation distinguishes:

- special Siniform ranges declared by `@implicitweights`;
- core Han ideographs;
- other assigned Han extension ranges;
- unassigned and all remaining code points.

Special ranges use their script base and an offset from the range family's
shared origin. Han and unassigned values split the scalar into high and low
15-bit portions. Exact assigned range endpoints matter: treating the first
unassigned scalar after an extension as Han reverses order at a conformance
boundary.

## 5. Variable weighting

In non-ignorable mode all non-zero table weights enter their ordinary levels.
In shifted mode a variable primary moves to quaternary and its secondary and
tertiary weights become zero. Primary-ignorable elements following a shifted
variable are suppressed until a non-variable primary resets the run.
Non-variable primary elements receive the quaternary sentinel.

The shifted official fixture is tested separately because errors in this state
machine can remain invisible in the non-ignorable profile.

## 6. Sort keys and comparison

MoonCollate retains levels as separate arrays instead of exposing one binary
blob. This makes diagnostics and JSON output readable. `SortKey::flatten`
provides the conventional representation with zero level separators when a
flat key is needed.

`compare` and collection operations use the same level comparison helper. The
selected strength stops comparison after the corresponding level. Identical
strength compares the NFD scalar sequence after quaternary equality.

`compare_detailed` walks the same arrays and reports the first decisive index;
it does not run a second semantic comparison.

## 7. Numeric extension

Numeric mode groups ASCII digit runs before DUCET lookup. Leading zeroes are
removed while preserving at least one significant digit. The synthetic key
contains a numeric marker, significant length, and digit weights. Comparing
length before digits implements arbitrary-precision positive integer ordering
without parsing into a fixed-width machine number.

This extension intentionally starts with ASCII digits. General `Nd` grouping,
decimal-system boundaries, signs, fractions, and locale formatting need a
separate specification before inclusion.

## 8. Complexity

For an input of `n` scalars, normalization and key construction are linear
apart from local canonical reordering and contraction lookup. Singleton and
normalization table lookup are logarithmic in table size. The v0.1 contraction
set is small enough for a bounded scan, with longest candidates preferred.

Collection sorting computes one key per value, then performs `O(m log m)` key
comparisons for `m` values. `CollationIndex` stores these keys and answers lower
and upper bounds in `O(log m)` comparisons.

## 9. Invariants

Changes to the core must preserve:

1. canonical equivalents have identical keys;
2. comparison is antisymmetric and transitive;
3. `compare(a, b)` agrees with configured key comparison;
4. stable collection sorting preserves input order among equal keys;
5. generated data is a deterministic function of pinned Unicode inputs;
6. both committed official short profiles have zero inversions;
7. every public result is portable across supported MoonBit backends.

The CI jobs separate unit tests, generated-data reproducibility, and official
conformance so a failure identifies the affected contract.
