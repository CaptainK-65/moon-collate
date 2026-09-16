# User guide

MoonCollate provides one immutable `Collator` value. Configuration methods
return a new value, so a shared default collator cannot be changed by a caller.
All APIs are deterministic and require no operating-system locale.

## Comparing text

```mbt check
test {
  let collator = @moon_collate.default_collator()
  assert_eq(collator.compare("apple", "banana"), @moon_collate.Ordering::Less)
}
```

`compare` returns `Less`, `Equal`, or `Greater`. Equality means equality at the
configured strength, not necessarily byte or code-point equality. The
`equivalent` helper expresses the same rule as a Boolean.

## Strength

Strength selects the last significant key level:

| Strength | Typical distinction |
| --- | --- |
| Primary | Base letters and ideographs |
| Secondary | Accents and combining marks |
| Tertiary | Case and presentation variants |
| Quaternary | Shifted punctuation and variables |
| Identical | NFD code-point sequence fallback |

For example, an unaccented and accented spelling can compare equal at primary
strength while remaining distinct at secondary strength.

```mbt check
test {
  let primary = @moon_collate.default_collator().with_strength(
    @moon_collate.Strength::Primary,
  )
  assert_true(primary.equivalent("resume", "résumé"))
}
```

Identical strength uses the normalized scalar sequence only after all UCA
levels compare equal. It gives a deterministic total ordering without making
canonically equivalent spellings different.

## Alternate handling

The default `NonIgnorable` mode gives spaces and punctuation ordinary weights.
`Shifted` moves variable primary weights to the quaternary level. It is useful
when punctuation should not decide a primary comparison.

```mbt check
test {
  let loose = @moon_collate.default_collator()
    .with_strength(@moon_collate.Strength::Primary)
    .with_alternate(@moon_collate.AlternateHandling::Shifted)
  assert_true(loose.equivalent("coop", "co-op"))
}
```

Sort keys from different alternate-handling modes must never be mixed.

## Numeric mode

Numeric mode recognizes contiguous ASCII digit runs. Leading zeroes do not
change the numeric value before identical strength, and arbitrarily long runs
do not overflow a machine integer because digits are encoded by length and
lexicographic digit weights.

```mbt check
test {
  let natural = @moon_collate.default_collator().with_numeric(true)
  assert_eq(
    natural.sort(["file10", "file2", "file1"]),
    ["file1", "file2", "file10"],
  )
}
```

Numeric mode is an extension, not part of the default DUCET conformance claim.

## Sorting collections

`sort` returns a new array and leaves the caller's input untouched. It caches a
key per value and preserves input order for strings equal at the configured
strength. `minimum`, `maximum`, `is_sorted`, `group_equal`, and `deduplicate`
cover common collection operations without making callers reproduce equality
semantics.

```mbt check
test {
  let primary = @moon_collate.default_collator().with_strength(
    @moon_collate.Strength::Primary,
  )
  let groups = primary.group_equal(["É", "e", "E", "f"])
  assert_eq(groups[0].values(), ["É", "e", "E"])
}
```

## Repeated lookup

`CollationIndex` sorts once and caches keys. Its binary-search operations are
appropriate for autocomplete dictionaries, table filters, and in-memory
indexes that execute repeated equality or insertion-position queries.

```mbt check
test {
  let collator = @moon_collate.default_collator().with_strength(
    @moon_collate.Strength::Primary,
  )
  let index = @moon_collate.CollationIndex::new(
    collator,
    ["Zulu", "é", "E", "apple"],
  )
  assert_true(index.contains("e"))
  assert_eq(index.equal_range("e"), ["é", "E"])
}
```

The index is immutable. Rebuild it when the source dataset or configuration
changes. This keeps cached keys from becoming inconsistent with their
collator.

## Inspecting decisions

`explain` returns the NFD form, every DUCET/implicit mapping step, and the final
key. `compare_detailed` additionally identifies the first weight and level
that decided a comparison. Both results derive `ToJson`, making them suitable
for logs, teaching tools, and test snapshots.

```mbt check
test {
  let report = @moon_collate.default_collator().compare_detailed("e", "é")
  guard report.difference() is Some(difference) else {
    fail("expected a difference")
  }
  assert_eq(
    difference.level(),
    @moon_collate.DifferenceLevel::SecondaryLevel,
  )
}
```

## CLI

The executable mirrors the library surface:

```text
moon run cmd/main -- compare resume résumé
moon run cmd/main -- key --strength secondary café
moon run cmd/main -- explain --shifted "co-op"
moon run cmd/main -- sort --numeric file10 file2 file1
```

Structured commands print JSON. This makes the CLI useful in shell pipelines
without turning its output into a second, incompatible API.

## Browser integration

The Collation Lab compiles the root MoonBit package to JavaScript and installs
a small string boundary at `globalThis.MoonCollate.run`. The static interface
does not use `Intl.Collator` and does not contain a second collation
implementation. A result in the lab and the same root configuration in native
code therefore share tables and semantics.

## Operational rules

- Reuse one collator for one logical index.
- Persist source strings, not sort keys alone; key formats may change by
  library or Unicode version.
- Record Unicode, UCA, library version, and configuration beside persistent
  keys.
- Do not compare keys created by different collators.
- Use official conformance profiles when modifying normalization, matching,
  implicit weights, or variable handling.
