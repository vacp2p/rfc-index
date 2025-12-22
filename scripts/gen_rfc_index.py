#!/usr/bin/env python3
"""
Generate a JSON index of RFC metadata for the landing page filters.

Scans the docs/ tree for Markdown files with YAML front matter and writes
`docs/rfc-index.json`.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List

import yaml

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
OUTPUT = DOCS / "rfc-index.json"

EXCLUDE_FILES = {"README.md", "SUMMARY.md"}
EXCLUDE_PARTS = {"previous-versions"}


def collect() -> List[Dict[str, str]]:
    entries: List[Dict[str, str]] = []
    for path in DOCS.rglob("*.md"):
        rel = path.relative_to(DOCS)

        if rel.name in EXCLUDE_FILES:
            continue
        if EXCLUDE_PARTS.intersection(rel.parts):
            continue

        text = path.read_text(encoding="utf-8", errors="ignore")
        if not text.startswith("---"):
            continue

        parts = text.split("---", 2)
        if len(parts) < 3:
            continue

        meta = yaml.safe_load(parts[1]) or {}
        slug = meta.get("slug")
        title = meta.get("title") or meta.get("name") or rel.stem
        status = meta.get("status") or "unknown"
        category = meta.get("category") or "unspecified"
        project = rel.parts[0]

        # Skip the template placeholder
        if slug == "XX":
            continue

        # mdBook renders Markdown to .html, keep links consistent
        html_path = rel.with_suffix(".html").as_posix()

        entries.append(
            {
                "project": project,
                "slug": str(slug) if slug is not None else title,
                "title": title,
                "status": status,
                "category": category,
                "path": html_path,
            }
        )

    entries.sort(key=lambda r: (r["project"], r["slug"]))
    return entries


def main() -> None:
    entries = collect()
    OUTPUT.write_text(json.dumps(entries, indent=2), encoding="utf-8")
    print(f"Wrote {len(entries)} entries to {OUTPUT}")


if __name__ == "__main__":
    main()
