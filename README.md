# rfc-index

Logos LIP index built with mdBook.

## Local setup

1. Install mdBook (pick the version that matches your Rust toolchain).
2. Install Python dependencies if needed.

## Build & serve

Run the generators before building or serving:

```bash
python scripts/gen_rfc_index.py
python scripts/gen_history.py
mdbook build
```

To serve locally:

```bash
python scripts/gen_rfc_index.py
python scripts/gen_history.py
mdbook serve -p 3000 -n 0.0.0.0
```

Note: `docs/rfc-index.json` is generated and gitignored, so make sure to run
`scripts/gen_rfc_index.py` whenever RFC metadata changes.
