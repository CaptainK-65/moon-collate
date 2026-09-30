# Third-party notices

## Unicode data

MoonCollate includes pinned data and short conformance fixtures from Unicode
17.0.0:

- `https://www.unicode.org/Public/17.0.0/uca/allkeys.txt`
- `https://www.unicode.org/Public/17.0.0/ucd/UnicodeData.txt`
- `https://www.unicode.org/Public/17.0.0/uca/CollationTest.zip`

The full-profile workflow downloads `CollationTest.zip` and verifies its
recorded SHA-256 before use; the full fixtures and archive are not committed.

Copyright © 1991–2025 Unicode, Inc. These files are distributed under the
Unicode License v3, reproduced at `third_party/unicode/LICENSE.txt`.

## MoonBit dependencies

The native conformance runner uses `moonbitlang/async@0.20.2`, published under
Apache-2.0 at `https://github.com/moonbitlang/async`. It is resolved through
Mooncakes and is not vendored. Runtime collation and normalization are provided
by MoonCollate's own version-aligned tables; the project does not depend on
`moonbit-community/normalization`.
