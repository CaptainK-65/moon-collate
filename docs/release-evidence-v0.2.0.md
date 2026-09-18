# v0.2.0 release evidence

Release milestone: [v0.2.0 — Production Hardening](https://github.com/CaptainK-65/moon-collate/milestone/2)

## Traceability

- [#7 — sort-key performance path](https://github.com/CaptainK-65/moon-collate/issues/7)
- [#8 — index range and count operations](https://github.com/CaptainK-65/moon-collate/issues/8)
- [#9 — full Unicode conformance](https://github.com/CaptainK-65/moon-collate/issues/9)
- [#10 — OS matrix and API drift](https://github.com/CaptainK-65/moon-collate/issues/10)
- [#11 — consumer and performance documentation](https://github.com/CaptainK-65/moon-collate/issues/11)
- [#12 — publication and release verification](https://github.com/CaptainK-65/moon-collate/issues/12)

## Local release-candidate gates

Recorded on 2026-09-18:

| Gate | Result |
| --- | --- |
| `moon check --target all` | passed |
| `moon test --target all` | 54 each on wasm/wasm-gc/js; 58 native; 0 failures |
| Non-ignorable FULL | 208,039 adjacent pairs; 0 failures |
| Shifted FULL | 229,829 adjacent pairs; 0 failures |
| `moon coverage analyze` | 16 uncovered executable lines across 6 files |
| Browser adapter contract | passed on the generated JavaScript target |
| `moon publish --dry-run` | registry accepted; extracted package passed `moon check` |
| Publication archive | 363,800 bytes after `.moonignore` audit |

The authoritative hosted results are the repository's
[CI](https://github.com/CaptainK-65/moon-collate/actions/workflows/ci.yml)
and [Full conformance](https://github.com/CaptainK-65/moon-collate/actions/workflows/full-conformance.yml)
workflows. Package and release URLs are added to the GitHub Release after the
same commit passes those gates.
