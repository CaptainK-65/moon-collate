# v0.2.1 final acceptance map

This document maps each final-acceptance requirement to public repository
evidence. Hosted run URLs are also attached to the v0.2.1 GitHub Release.

| Requirement | Evidence |
| --- | --- |
| MoonBit implementation and `moonc >= 0.10.14` | MoonBit is the dominant repository language; `tools/verify_toolchain.mbtx` rejects older compilers in CI |
| Public repository and clear history | Public [repository](https://github.com/CaptainK-65/moon-collate), milestone-scoped Issues, reviewable commits, and pull requests |
| Clear structure and declared core behavior | Root library package, `cmd/`, `examples/`, `playground/`, generated Unicode tables, and architecture documentation |
| Reproducible README | Goal, minimum toolchain, Mooncakes install, source build, API examples, CLI, expected quickstart output, and validation commands |
| Continuous integration | [CI](https://github.com/CaptainK-65/moon-collate/actions/workflows/ci.yml) explicitly runs check, build, and test across all backends on Linux, macOS, and Windows |
| Runnable example | `moon run examples/quickstart`, plus the native CLI and hosted Collation Lab |
| Core tests | Four-backend behavioral suite, coverage audit, generated-data drift gate, browser contract, and official Unicode 17 short/full conformance |
| Mooncakes publication | `moon add CaptainK-65/moon-collate@0.2.1` and the [published package](https://mooncakes.io/docs/CaptainK-65/moon-collate@0.2.1) |
| OSI license and third-party compliance | Apache-2.0 `LICENSE`, Unicode License v3, and `THIRD_PARTY_NOTICES.md` |

## Traceability

- [#14 — qualifying toolchain and build gates](https://github.com/CaptainK-65/moon-collate/issues/14)
- [#15 — runnable reviewer quickstart](https://github.com/CaptainK-65/moon-collate/issues/15)
- [#16 — refreshed test evidence](https://github.com/CaptainK-65/moon-collate/issues/16)
- [#17 — public acceptance evidence](https://github.com/CaptainK-65/moon-collate/issues/17)
- [#18 — v0.2.1 publication](https://github.com/CaptainK-65/moon-collate/issues/18)

## Release gates

The release commit must satisfy all of the following:

```text
moon run tools/verify_toolchain.mbtx
moon fmt --check
moon check --target all
moon build --target all
moon test --target all
moon run examples/quickstart
moon coverage analyze
moon info
```

Both official Unicode 17 full profiles must report zero failed adjacent pairs.
The generated JavaScript adapter contract, generated Unicode table drift check,
package dry run, and a clean downstream consumer must also pass.
