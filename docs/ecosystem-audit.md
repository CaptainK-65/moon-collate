# MoonCollate ecosystem overlap audit

Audit timestamp: 2026-09-16 10:27 UTC.

## Decision

Proceed with MoonCollate. No public MoonBit implementation of the Unicode
Collation Algorithm, DUCET, a Unicode `Collator`, or reusable Unicode sort keys
was found in the checked sources.

## Sources checked

- GitHub repository search, restricted to MoonBit, using `collation`,
  `collate`, `Unicode Collation Algorithm`, `UTS10`, `DUCET`, and
  `sortkey unicode`: zero repository results for every query.
- Mooncakes registry snapshot: 2,502 modules; zero name, description, or keyword
  matches for `collation`, `collator`, `DUCET`, `Unicode collation`, `sort key`,
  or `UTS #10`.
- Repository tree inspection of the most plausible adjacent projects:
  `moonbit-community/tonyfettes-unicode`, `lampclaw/moonbit-i18n`, and
  `moonbit-community/moon_cosmic`.

## Adjacent projects and boundaries

| Project | Existing responsibility | MoonCollate responsibility |
| --- | --- | --- |
| `moonbit-community/normalization` | NFC/NFD/NFKC/NFKD | consumes NFD; does not reimplement it |
| `moonbit-community/ucd` | Unicode properties and case mapping | DUCET mapping and multilevel comparison |
| `moonbit-community/bidi` | bidirectional display ordering | linguistic sorting and sort keys |
| `kawaz/grapheme` | grapheme cluster segmentation | collation elements and comparison |
| `lampclaw/i18n` | MF2 formatting and message catalogs | reusable text ordering primitives |
| `moonbit-community/moon_cosmic` | shaping, layout, editing, line breaking | standalone UCA implementation |

## Previously rejected candidates

The following candidates were rejected before implementation because maintained
or recent MoonBit equivalents were found: WARC, robots.txt, multipart/form-data,
Unicode line breaking, Unicode bidi, PCAP/PCAPNG, RDF/Turtle, JSON Patch,
JSON Schema, JSON canonicalization, iCalendar/RRULE, HTTP Structured Fields,
content negotiation, and MessageFormat.

## Ongoing gate

This audit describes public indexed code, not private or undiscoverable work.
Before the `v0.1.0` release, the same searches must be repeated and this file
updated. Any newly discovered maintained equivalent blocks release until the
relationship and non-overlapping scope are documented.
