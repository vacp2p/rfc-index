#!/usr/bin/env python3
"""
Run all generators in sequence.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = [
    "scripts/validate_metadata.py",
    "scripts/gen_history.py",
    "scripts/gen_rfc_index.py",
    "scripts/gen_summary.py",
]


def run(script: str) -> None:
    path = ROOT / script
    print(f"[INFO] Running {path}")
    result = subprocess.run([sys.executable, str(path)], cwd=ROOT)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def main() -> None:
    for script in SCRIPTS:
        run(script)


if __name__ == "__main__":
    main()
