# MoonCollate ecosystem overlap audit

Audit refreshed: 2026-09-18.

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
| `moonbit-community/normalization` | Unicode 16 NFC/NFD/NFKC/NFKD | bundles the Unicode 17 canonical subset required by UCA version alignment |
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
Before each release, the same searches must be repeated and this file updated.
The v0.2.0 review found no newly indexed MoonBit UCA/DUCET implementation. Any
newly discovered maintained equivalent blocks release until the
relationship and non-overlapping scope are documented.

## Version-alignment note

The current public normalization package uses Unicode 16.0.0 data, while UCA
17.0.0 conformance depends on canonical combining classes introduced in Unicode
17. MoonCollate therefore generates a narrow internal NFD table from the pinned
Unicode 17 `UnicodeData.txt`. This is not presented as a competing general
normalization package: it exposes no NFC/NFKC/NFKD API and exists solely to
prevent mixed-version collation results.
