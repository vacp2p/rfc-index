#!/usr/bin/env python3
"""
Generate a JSON index of RFC metadata for the landing page filters.

Scans the docs/ tree for Markdown files and writes
`docs/rfc-index.json`.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List, Optional
import html
import re

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
OUTPUT = DOCS / "rfc-index.json"

EXCLUDE_FILES = {"README.md", "SUMMARY.md"}
EXCLUDE_PARTS = {"previous-versions"}


def parse_meta_from_html(text: str) -> Optional[Dict[str, str]]:
    if '<div class="rfc-meta">' not in text:
        return None

    meta: Dict[str, str] = {}
    for match in re.findall(r"<tr><th>([^<]+)</th><td>(.*?)</td></tr>", text, flags=re.DOTALL):
        key = match[0].strip().lower()
        value = match[1].replace("<br>", "\n").strip()
        value = html.unescape(value)
        meta[key] = value

    return meta or None


def parse_front_matter(text: str) -> Optional[Dict[str, str]]:
    if not text.startswith("---"):
        return None

    end = text.find("\n---", 3)
    if end == -1:
        return None

    front = text[3:end].strip().splitlines()
    meta: Dict[str, str] = {}
    for line in front:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip().lower()
        value = value.strip().strip('"').strip("'")
        if key and value:
            meta[key] = value
    return meta or None


def parse_meta_from_markdown_table(text: str) -> Optional[Dict[str, str]]:
    lines = text.splitlines()
    meta: Dict[str, str] = {}
    for i in range(len(lines) - 2):
        line = lines[i].strip()
        next_line = lines[i + 1].strip()
        if not (line.startswith('|') and next_line.startswith('|') and '---' in next_line):
            continue

        # Simple two-column table parsing
        j = i + 2
        while j < len(lines) and lines[j].strip().startswith('|'):
            parts = [p.strip() for p in lines[j].strip().strip('|').split('|')]
            if len(parts) >= 2:
                key = parts[0].lower()
                value = html.unescape(parts[1])
                if key and value:
                    meta[key] = value
            j += 1
        break

    return meta or None


def parse_title_from_h1(text: str) -> Optional[str]:
    match = re.search(r"^#\\s+(.+)$", text, flags=re.MULTILINE)
    if not match:
        return None
    return match.group(1).strip()


def collect() -> List[Dict[str, str]]:
    entries: List[Dict[str, str]] = []
    for path in DOCS.rglob("*.md"):
        rel = path.relative_to(DOCS)

        if rel.name in EXCLUDE_FILES:
            continue
        if EXCLUDE_PARTS.intersection(rel.parts):
            continue

        text = path.read_text(encoding="utf-8", errors="ignore")

        meta = parse_front_matter(text)
        if meta is None:
            meta = parse_meta_from_markdown_table(text)
        if meta is None:
            meta = parse_meta_from_html(text) or {}

        slug = meta.get("slug")
        title = meta.get("title") or meta.get("name") or parse_title_from_h1(text) or rel.stem
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
