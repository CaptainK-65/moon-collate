# Collation Lab

The lab is a zero-framework static interface backed by the same MoonBit package
as the CLI. Build the JavaScript adapter and copy the emitted module into
`site/moon-collate.js`, then serve the directory over HTTP.

```text
moon build --target js --release playground/app
python -m http.server --directory playground/site 8080
```

The GitHub Pages workflow performs the artifact copy automatically.
