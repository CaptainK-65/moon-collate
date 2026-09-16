# Contributing

MoonCollate welcomes focused fixes and reusable collation features. Changes to
ordering semantics require unusually strong evidence because a small local
mistake can invalidate persisted indexes or violate transitivity.

## Development loop

```text
moon update
moon fmt
moon check --target all
moon test --target all
moon info
```

When matching, normalization, implicit weights, or variable handling changes,
also run:

```text
moon run --target native cmd/conformance
moon run --target native cmd/conformance -- --shifted
```

## Generated data

Do not hand-edit `generated_ducet.mbt` or `generated_normalization.mbt`. Update
the pinned source or generator, rebuild both files, run `moon fmt`, and include
the source hash and conformance effect in the pull request.

```text
moon run tools/generate_ducet.mbtx -- third_party/unicode/uca-17.0.0/allkeys.txt generated_ducet.mbt
moon run tools/generate_normalization.mbtx -- third_party/unicode/uca-17.0.0/UnicodeData.txt generated_normalization.mbt
```

Large full conformance fixtures and the original archive are intentionally
ignored. The short fixtures are committed as reproducible release gates.

## Pull requests

- Start from an issue when behavior or public API changes.
- Keep generated changes separate from hand-written algorithm changes when
  practical.
- Add the smallest regression that fails without the fix.
- State the Unicode/UCA rule involved.
- Report exact commands and adjacent-pair totals.
- Avoid unrelated formatting or refactoring.

Public API additions need documentation and tests on all supported backends.
Locale-specific behavior belongs in future tailoring packages rather than the
root DUCET profile.
