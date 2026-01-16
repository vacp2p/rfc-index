#!/usr/bin/env python3
import subprocess
from typing import List, Tuple, Optional, Dict
from pathlib import Path
import re


def log(msg: str):
    print(f"[INFO] {msg}", flush=True)


def run_git(args: list) -> str:
    cmd = ["git"] + args
    log("Running: " + " ".join(cmd))

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding="utf-8",
    )

    if result.returncode != 0:
        print("[ERROR] Command failed:", " ".join(cmd))
        print(result.stderr)
        raise subprocess.CalledProcessError(
            result.returncode, cmd, result.stdout, result.stderr
        )

    return result.stdout.strip()


def get_repo_https_url() -> Optional[str]:
    try:
        url = run_git(["config", "--get", "remote.origin.url"]).strip()
    except subprocess.CalledProcessError:
        return None

    if url.startswith("git@github.com:"):
        path = url[len("git@github.com:"):]
        if path.endswith(".git"):
            path = path[:-4]
        return f"https://github.com/{path}"

    if url.startswith("https://github.com/"):
        path = url[len("https://github.com/"):]
        if path.endswith(".git"):
            path = path[:-4]
        return f"https://github.com/{path}"

    return None


def get_repo_file_path(path: str) -> str:
    log(f"Resolving file path via git: {path}")
    try:
        out = run_git(["ls-files", "--full-name", path])
    except subprocess.CalledProcessError:
        raise SystemExit(f"[ERROR] {path!r} is not tracked by git")

    if not out:
        raise SystemExit(f"[ERROR] {path!r} is not tracked by git")

    resolved = out.splitlines()[0]
    log(f"Resolved path inside repo: {resolved}")
    return resolved


def get_file_commits(path: str) -> List[Tuple[str, str, str, str]]:
    log(f"Collecting commit history for: {path}")

    log_output = run_git([
        "log",
        "--follow",
        "--format=%H%x09%ad%x09%s",
        "--date=short",
        "--name-only",
        "--",
        path,
    ])

    if not log_output:
        log("No history found.")
        return []

    commits: List[Tuple[str, str, str, str]] = []
    current: Optional[Dict[str, str]] = None
    for line in log_output.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t", 2)
        # Detect commit line
        if len(parts) == 3 and len(parts[0]) >= 7 and all(c in "0123456789abcdef" for c in parts[0].lower()):
            if current:
                commits.append((current["commit"], current["date"], current["subject"], current.get("path", path)))
            current = {"commit": parts[0], "date": parts[1], "subject": parts[2]}
            continue

        # If we are in a commit block and we see a path, record the first one
        if current and "path" not in current:
            current["path"] = line.strip()

    if current:
        commits.append((current["commit"], current["date"], current["subject"], current.get("path", path)))

    commits.reverse()
    log(f"Found {len(commits)} commits.")
    return commits


def build_markdown_history(
    repo_url: str,
    file_path: str,
    commits: List[Tuple[str, str, str, str]],
) -> str:
    log(f"Generating markdown history...")
    entries = []

    # newest first
    for commit, date, subject, path_at_commit in reversed(commits):
        blob_url = f"{repo_url}/blob/{commit}/{path_at_commit}"
        entries.append((date, commit, subject, blob_url))

    lines: List[str] = []
    lines.append("## Timeline\n")

    for date, commit, subject, blob_url in entries:
        lines.append(f"- **{date}** — [`{commit[:7]}`]({blob_url}) — {subject}")

    return "\n".join(lines).rstrip() + "\n"


def find_metadata_table_end(lines: List[str]) -> Optional[int]:
    header_idx = None
    for idx, line in enumerate(lines[:80]):
        if line.strip() == "| Field | Value |":
            header_idx = idx
            break
    if header_idx is None:
        return None

    if header_idx + 1 >= len(lines):
        return None

    if not lines[header_idx + 1].strip().startswith("|"):
        return None

    end_idx = header_idx + 2
    while end_idx < len(lines) and lines[end_idx].strip().startswith("|"):
        end_idx += 1

    return end_idx


def inject_timeline(file_path: Path, timeline_md: str) -> bool:
    """
    Insert or replace a timeline block near the top of the file.
    Returns True if the file was modified.
    """
    content = file_path.read_text(encoding="utf-8")
    start_marker = "<!-- timeline:start -->"
    end_marker = "<!-- timeline:end -->"
    block = (
        f"{start_marker}\n\n"
        f"{timeline_md.strip()}\n\n"
        f"{end_marker}\n"
    )

    if start_marker in content and end_marker in content:
        pattern = re.compile(
            re.escape(start_marker) + r".*?" + re.escape(end_marker),
            re.DOTALL,
        )
        new_content, count = pattern.subn(block, content, count=1)
        if count and new_content != content:
            file_path.write_text(new_content, encoding="utf-8")
            return True
        return False

    lines = content.splitlines()
    insert_pos = 0
    table_end = find_metadata_table_end(lines)
    if table_end is not None:
        insert_pos = len("\n".join(lines[:table_end]))
    else:
        for idx, line in enumerate(lines):
            if line.startswith("# "):
                insert_pos = len("\n".join(lines[: idx + 1]))
                break

    new_content = content[:insert_pos] + "\n\n" + block + "\n" + content[insert_pos:]
    if new_content != content:
        file_path.write_text(new_content, encoding="utf-8")
        return True
    return False


def is_rfc_file(path: Path) -> bool:
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False

    if "# " not in text:
        return False

    if "| Field | Value |" not in text:
        return False

    return True


def find_rfc_files(root: Path) -> List[Path]:
    candidates: List[Path] = []
    for path in root.rglob("*.md"):
        if path.name in {"README.md", "SUMMARY.md", "template.md"}:
            continue
        if is_rfc_file(path):
            candidates.append(path)
    return sorted(candidates)


def main():
    log("Starting history generation")

    repo_url = get_repo_https_url()
    if not repo_url:
        raise SystemExit("[ERROR] Could not determine GitHub repo URL")

    log(f"Repo URL: {repo_url}")

    root = Path("docs")
    files = find_rfc_files(root)
    if not files:
        raise SystemExit(f"[ERROR] No LIPs found under {root}")

    updated = 0
    for file_path in files:
        repo_file_path = get_repo_file_path(str(file_path))
        commits = get_file_commits(repo_file_path)
        if not commits:
            log(f"[WARN] No history found for {repo_file_path}")
            continue

        markdown = build_markdown_history(
            repo_url=repo_url,
            file_path=repo_file_path,
            commits=commits,
        )

        modified = inject_timeline(file_path, markdown)
        if modified:
            updated += 1
            log(f"Timeline injected into {file_path}")

    log(f"Timelines updated in {updated} files")


if __name__ == "__main__":
    main()
