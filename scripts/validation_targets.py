#!/usr/bin/env python3
"""List changed Markdown files under docs/ for scoped validation."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from lint_targets import changed_files


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-sha", required=True, help="Base commit SHA")
    parser.add_argument("--head-sha", required=True, help="Head commit SHA")
    parser.add_argument("--output", help="Write targets to this file")
    return parser.parse_args()


def log(message: str) -> None:
    print(message, file=sys.stderr)


def validation_targets(base_sha: str, head_sha: str) -> list[str]:
    targets = []
    for rel_path in changed_files(base_sha, head_sha):
        path = Path(rel_path)
        if not rel_path.startswith("docs/"):
            continue
        if path.suffix.lower() != ".md":
            continue
        targets.append(rel_path)
        if path.exists():
            log(f"SELECT {rel_path}")
        else:
            log(f"SELECT {rel_path} (deleted or missing in working tree)")

    unique_targets = sorted(set(targets))
    log(f"Summary: selected={len(unique_targets)}")
    return unique_targets


def main() -> int:
    args = parse_args()
    targets = validation_targets(args.base_sha, args.head_sha)
    output = "\n".join(targets)

    if args.output:
        Path(args.output).write_text((output + "\n") if output else "", encoding="utf-8")
        log(f"Wrote {len(targets)} validation target(s) to {args.output}")
    else:
        print(output)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
