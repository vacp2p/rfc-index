#!/usr/bin/env python3
"""
Run all generators in sequence.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HISTORY_SCRIPT = "scripts/gen_history.py"
SCRIPTS = [
    "scripts/validate_metadata.py",
    "scripts/validate_rendering.py",
    HISTORY_SCRIPT,
    "scripts/gen_rfc_index.py",
    "scripts/gen_summary.py",
    "scripts/validate_generated_outputs.py",
]


def should_generate_history() -> bool:
    if os.environ.get("LIPS_GENERATE_HISTORY") in {"1", "true", "TRUE", "yes", "YES"}:
        return True

    ci_markers = ("CI", "GITHUB_ACTIONS", "JENKINS_URL", "BUILD_ID", "BUILD_NUMBER")
    return any(os.environ.get(name) for name in ci_markers)


def run(script: str) -> None:
    parts = script.split()
    path = ROOT / parts[0]
    args = parts[1:]
    print(f"[INFO] Running {path} {' '.join(args)}".rstrip())
    result = subprocess.run([sys.executable, str(path), *args], cwd=ROOT)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def main() -> None:
    for script in SCRIPTS:
        if script == HISTORY_SCRIPT and not should_generate_history():
            print("[INFO] Skipping history generation outside CI")
            continue
        run(script)


if __name__ == "__main__":
    main()
