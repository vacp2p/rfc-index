#!/usr/bin/env python3
"""Shared command-line helpers for scripts that can run on selected targets."""
from __future__ import annotations

import argparse
from pathlib import Path


def add_target_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--target",
        action="append",
        default=[],
        metavar="PATH",
        help="Limit checks to this repository-relative path; may be repeated.",
    )
    parser.add_argument(
        "--targets-file",
        metavar="PATH",
        help="Read newline-separated repository-relative target paths from a file.",
    )


def load_target_paths(root: Path, args: argparse.Namespace) -> list[Path] | None:
    raw_targets: list[str] = list(getattr(args, "target", []) or [])
    targets_file = getattr(args, "targets_file", None)

    if targets_file:
        target_file_path = root / targets_file
        raw_targets.extend(
            line.strip()
            for line in target_file_path.read_text(encoding="utf-8").splitlines()
            if line.strip()
        )

    if not raw_targets:
        return None

    root_resolved = root.resolve()
    normalized: set[Path] = set()
    for raw in raw_targets:
        path = Path(raw)
        if path.is_absolute():
            try:
                rel = path.resolve().relative_to(root_resolved)
            except ValueError as exc:
                raise ValueError(f"target is outside repository: {raw}") from exc
        else:
            rel = path
            if ".." in rel.parts:
                raise ValueError(f"target must not contain '..': {raw}")
        normalized.add(rel)

    return sorted(normalized, key=lambda p: p.as_posix())
