# MoonCollate

![MoonCollate — Unicode order, made visible](docs/assets/mooncollate-cover.png)

MoonCollate is a pure MoonBit Unicode collation toolkit. It turns Unicode text
into comparable collation elements and reusable sort keys using the Unicode
Collation Algorithm (UCA) and the Default Unicode Collation Element Table
(DUCET).

> Status: active development toward `v0.1.0`. Conformance claims are made only
> for test profiles recorded in [`docs/conformance.md`](docs/conformance.md).

[![CI](https://github.com/CaptainK-65/moon-collate/actions/workflows/ci.yml/badge.svg)](https://github.com/CaptainK-65/moon-collate/actions/workflows/ci.yml)
[![Collation Lab](https://img.shields.io/badge/demo-Collation_Lab-c7ff4a?labelColor=111217)](https://captaink-65.github.io/moon-collate/)
[![Unicode 17](https://img.shields.io/badge/Unicode-17.0.0-a58cff)](https://www.unicode.org/reports/tr10/)

## Why this library exists

Code-point order is not human text order. Accents, case, punctuation,
contractions, expansions, and canonical equivalence all affect how users expect
text to sort. MoonCollate fills the collation layer between MoonBit's Unicode
property/normalization packages and higher-level internationalization, search,
table, and database software.

## Public surface

- configurable primary through identical comparison strengths;
- non-ignorable and shifted alternate handling;
- deterministic binary sort keys;
- DUCET contractions, expansions, and implicit weights;
- canonical-equivalence-safe comparison through NFD normalization;
- structured explanation traces for debugging and education;
- stable collection helpers and a cached binary-search index;
- a native CLI and a browser-based [Collation Lab](https://captaink-65.github.io/moon-collate/).

```mbt check
///|
test {
  let collator = default_collator()
  inspect(collator.compare("resume", "résumé").to_string(), content="Less")
}
```

The committed Unicode 17 short conformance profiles currently cover 208,039
non-ignorable and 229,829 shifted adjacent pairs with zero failures. See the
[user guide](docs/guide.md), [algorithm notes](docs/algorithm.md), and exact
[conformance statement](docs/conformance.md).

## Quick start

```mbt check
///|
test {
  let collator = default_collator().with_numeric(true)
  assert_eq(collator.sort(["file10", "file2", "file1"]), [
    "file1", "file2", "file10",
  ])
}
```

```text
moon run cmd/main -- compare resume résumé
moon run cmd/main -- sort --numeric file10 file2 file1
moon run cmd/main -- explain café
```

## Scope boundary

Version `0.1.0` implements the Unicode 17.0.0 default collation profile. It is
not a database, a text shaping engine, or a full ICU/CLDR locale tailoring
replacement. See [`docs/ecosystem-audit.md`](docs/ecosystem-audit.md) for the
public ecosystem overlap audit and [`docs/limitations.md`](docs/limitations.md)
for explicit non-goals.

## Development

```text
moon update
moon check --target all
moon test --target all
moon run --target native cmd/conformance
moon run --target native cmd/conformance -- --shifted
moon info
moon fmt
```

The Unicode data generator is written in MoonBit script mode and lives under
`tools/`. Generated tables are reproducible from the pinned Unicode inputs in
`third_party/unicode/` and are not counted as hand-written source.

## License

MoonCollate is licensed under Apache-2.0. Unicode data files remain subject to
the Unicode License v3; see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
