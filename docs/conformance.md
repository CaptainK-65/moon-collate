# Conformance

MoonCollate targets Unicode Collation Algorithm 17.0.0 and the matching DUCET.

## Release profiles

| Profile | Fixture | Release requirement |
| --- | --- | --- |
| Non-ignorable short | `CollationTest_NON_IGNORABLE_SHORT.txt` | 100% ordered |
| Shifted short | `CollationTest_SHIFTED_SHORT.txt` | 100% ordered |
| Compare/key equivalence | generated property corpus | zero mismatches |
| Canonical equivalence | focused normalization corpus | zero mismatches |
| Backend portability | native, js, wasm, wasm-gc | check and tests pass |

Latest local release-candidate run (2026-09-16):

- Non-ignorable short: **208,039 adjacent pairs, 0 failures**.
- Shifted short: **229,829 adjacent pairs, 0 failures**.
- Focused library and browser-model tests: **26 tests, 0 failures** on native.

The CI workflow reruns both official profiles. These figures describe the
committed `SHORT` fixtures, not the uncommitted full fixtures.

The full Unicode conformance files are retained as an extended validation
target but are not committed because of their size. A release claim must state
exactly which profile was executed. Known failures may not be hidden behind a
general “UCA compliant” label.

## Pinned upstream data

- `allkeys.txt` SHA-256:
  `2503D09367C2639A4FB8FD55E81AAACB0D9FB4EA26600333329BD12456B99ECD`
- Original `CollationTest.zip` SHA-256:
  `9BA92CB7627C2D09BA537DC2035D006F44F0CAFB4E2198F147897FDD9D71BB10`
- `UnicodeData.txt` SHA-256:
  `2E1EFC1DCB59C575EEDF5CCAE60F95229F706EE6D031835247D843C11D96470C`
