# Conformance

MoonCollate targets Unicode Collation Algorithm 17.0.0 and the matching DUCET.

## Release profiles

| Profile | Fixture | Release requirement |
| --- | --- | --- |
| Non-ignorable short | `CollationTest_NON_IGNORABLE_SHORT.txt` | 100% ordered |
| Shifted short | `CollationTest_SHIFTED_SHORT.txt` | 100% ordered |
| Non-ignorable full | downloaded checksum-pinned fixture | 100% ordered |
| Shifted full | downloaded checksum-pinned fixture | 100% ordered |
| Compare/key equivalence | generated property corpus | zero mismatches |
| Canonical equivalence | focused normalization corpus | zero mismatches |
| Backend portability | native, js, wasm, wasm-gc | check and tests pass |

Latest local release-candidate run (2026-09-18):

- Non-ignorable short: **208,039 adjacent pairs, 0 failures**.
- Shifted short: **229,829 adjacent pairs, 0 failures**.
- Non-ignorable full: **208,039 adjacent pairs, 0 failures**.
- Shifted full: **229,829 adjacent pairs, 0 failures**.
- Focused tests: **54 per portable backend and 58 on native, 0 failures**.
- Coverage audit: **16 uncovered executable lines across 6 files**.

The regular CI workflow reruns both committed short profiles. The manual
`Full conformance` workflow downloads Unicode's official archive, verifies the
pinned SHA-256 before extraction, then runs both full profiles. Full fixtures
are intentionally not committed because of their size.

A release claim must state exactly which profile was executed. Known failures
may not be hidden behind a general “UCA compliant” label.

```text
moon run --target native cmd/conformance -- --short
moon run --target native cmd/conformance -- --short --shifted
moon run --target native cmd/conformance -- --full
moon run --target native cmd/conformance -- --full --shifted
```

## Pinned upstream data

- `allkeys.txt` SHA-256:
  `2503D09367C2639A4FB8FD55E81AAACB0D9FB4EA26600333329BD12456B99ECD`
- Original `CollationTest.zip` SHA-256:
  `9BA92CB7627C2D09BA537DC2035D006F44F0CAFB4E2198F147897FDD9D71BB10`
- `UnicodeData.txt` SHA-256:
  `2E1EFC1DCB59C575EEDF5CCAE60F95229F706EE6D031835247D843C11D96470C`
