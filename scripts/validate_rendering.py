#!/usr/bin/env python3
"""Validate Markdown patterns that are known to break GitHub or mdBook rendering."""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"

BLOCK_MATH_RE = re.compile(r"(?<!\\)\$\$(.+?)(?<!\\)\$\$", re.DOTALL)
ALT_BLOCK_MATH_RE = re.compile(
    r"(?<!\\)\$`\s*\n(.+?)\n\s*`\$(?!\$)",
    re.DOTALL,
)
GITHUB_INLINE_MATH_RE = re.compile(r"(?<!\\)\$`([^\n]*?)(?<!\\)`\$(?!\$)")
INLINE_CODE_RE = re.compile(r"`+[^`\n]*?`+")
STANDARD_INLINE_MATH_RE = re.compile(r"(?<!\\)\$(?![\$`])([^\n$]*?)(?<!\\)\$")

HIGH_RISK_INLINE_CHARS = set("_^{}<>")
CODE_FENCE_RE = re.compile(r"(`{3,}|~{3,})")
NOTION_URL_RE = re.compile(r"https://(?:nomos-tech\.notion\.site|www\.notion\.so)[^\s)\]<>\"']*")
MARKDOWN_LINK_TARGET_RE = re.compile(r"!?\[[^\]\n]*\]\(([^)\n]+)\)")
NOTION_PLACEHOLDER_RE = re.compile(r"[‣⁍]")
INDENTED_STANDALONE_GITHUB_MATH_RE = re.compile(r"^ {4,}\$`")
TABLE_HEADER_RE = re.compile(r"^\|.*\|\s*$")
TABLE_DELIMITER_RE = re.compile(r"^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?\s*$")
EMPTY_PIPE_TABLE_ROW_RE = re.compile(r"^\|\s*(\|\s*)?$")
DETAILS_OPEN_RE = re.compile(r"<details\b", re.IGNORECASE)
DETAILS_OPEN_TAG_RE = re.compile(r"<details\b[^>]*>", re.IGNORECASE)
DETAILS_CLOSE_RE = re.compile(r"</details>", re.IGNORECASE)
SUMMARY_RE = re.compile(r"<summary>.*?</summary>", re.IGNORECASE)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="*", help="Markdown files to validate")
    parser.add_argument("--base-sha", help="Base commit SHA for changed-file mode")
    parser.add_argument("--head-sha", help="Head commit SHA for changed-file mode")
    parser.add_argument(
        "--all",
        action="store_true",
        help="Validate every Markdown file under docs/ instead of changed files",
    )
    parser.add_argument(
        "--strict-github-inline-math",
        action="store_true",
        help="Require Markdown-sensitive inline math to use GitHub's $`...`$ form",
    )
    return parser.parse_args()


def changed_markdown_files(base_sha: str, head_sha: str) -> list[Path]:
    output = subprocess.check_output(
        ["git", "diff", "--name-only", base_sha, head_sha],
        cwd=ROOT,
        text=True,
    )
    paths = []
    for line in output.splitlines():
        rel = line.strip()
        if not rel.startswith("docs/") or not rel.endswith(".md"):
            continue
        path = ROOT / rel
        if path.exists():
            paths.append(path)
    return sorted(set(paths))


def worktree_markdown_files() -> list[Path]:
    commands = [
        ["git", "diff", "--name-only", "HEAD"],
        ["git", "ls-files", "--others", "--exclude-standard"],
    ]
    paths: list[Path] = []
    for command in commands:
        output = subprocess.check_output(command, cwd=ROOT, text=True)
        for line in output.splitlines():
            rel = line.strip()
            if not rel.startswith("docs/") or not rel.endswith(".md"):
                continue
            path = ROOT / rel
            if path.exists():
                paths.append(path)
    return sorted(set(paths))


def discover_markdown_files() -> list[Path]:
    return sorted(DOCS.rglob("*.md"))


def selected_paths(args: argparse.Namespace) -> list[Path]:
    if args.paths:
        return [Path(path).resolve() for path in args.paths]
    if args.base_sha and args.head_sha:
        return changed_markdown_files(args.base_sha, args.head_sha)
    if args.all:
        return discover_markdown_files()
    return worktree_markdown_files()


def line_number(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def blank_match(match: re.Match) -> str:
    return "".join("\n" if char == "\n" else " " for char in match.group(0))


def text_without_blocks_or_code(text: str) -> str:
    scrubbed = BLOCK_MATH_RE.sub(blank_match, text)
    scrubbed = ALT_BLOCK_MATH_RE.sub(blank_match, scrubbed)
    scrubbed = GITHUB_INLINE_MATH_RE.sub(blank_match, scrubbed)
    return INLINE_CODE_RE.sub(blank_match, scrubbed)


def rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def validate_block_math(path: Path, text: str, errors: list[str]) -> None:
    for pattern in (BLOCK_MATH_RE, ALT_BLOCK_MATH_RE):
        for match in pattern.finditer(text):
            content = match.group(1)
            fence_match = CODE_FENCE_RE.search(content)
            if not fence_match:
                continue
            line = line_number(text, match.start(1) + fence_match.start())
            errors.append(
                f"{rel(path)}:{line}: math block contains `{fence_match.group(1)}`; "
                "use semantic LaTeX spacing/alignment so mdBook does not treat it as a code fence"
            )


def validate_github_inline_math(path: Path, text: str, errors: list[str]) -> None:
    for match in GITHUB_INLINE_MATH_RE.finditer(text):
        content = match.group(1)
        if "<" not in content and ">" not in content:
            continue
        line = line_number(text, match.start(1))
        errors.append(
            f"{rel(path)}:{line}: GitHub inline math contains literal `<` or `>`; "
            "use `\\lt` or `\\gt` so GitHub does not HTML-escape the expression"
        )


def validate_caption_inline_math(path: Path, text: str, errors: list[str]) -> None:
    scrubbed = text_without_blocks_or_code(text)
    for match in STANDARD_INLINE_MATH_RE.finditer(scrubbed):
        line_start = scrubbed.rfind("\n", 0, match.start()) + 1
        line_end = scrubbed.find("\n", match.end())
        if line_end == -1:
            line_end = len(scrubbed)
        line_text = scrubbed[line_start:line_end]
        if not line_text.lstrip().startswith("> <sub>"):
            continue
        content = match.group(1)
        if not HIGH_RISK_INLINE_CHARS.intersection(content):
            continue
        line = line_number(scrubbed, match.start())
        errors.append(
            f"{rel(path)}:{line}: caption contains Markdown-sensitive inline math `{content}`; "
            "use GitHub's $`...`$ inline math delimiter"
        )


def validate_standard_inline_math(path: Path, text: str, errors: list[str]) -> None:
    scrubbed = text_without_blocks_or_code(text)
    for match in STANDARD_INLINE_MATH_RE.finditer(scrubbed):
        line_start = scrubbed.rfind("\n", 0, match.start()) + 1
        line_end = scrubbed.find("\n", match.end())
        if line_end == -1:
            line_end = len(scrubbed)
        line_text = scrubbed[line_start:line_end]
        if line_text.lstrip().startswith("> <sub>"):
            continue
        content = match.group(1)
        if not HIGH_RISK_INLINE_CHARS.intersection(content):
            continue
        line = line_number(scrubbed, match.start())
        errors.append(
            f"{rel(path)}:{line}: inline math `{content}` contains Markdown-sensitive syntax; "
            "use GitHub's $`...`$ inline math delimiter"
        )


def validate_indented_standalone_github_math(path: Path, text: str, errors: list[str]) -> None:
    for line_index, line_text in enumerate(text.splitlines(), start=1):
        if not INDENTED_STANDALONE_GITHUB_MATH_RE.match(line_text):
            continue
        errors.append(
            f"{rel(path)}:{line_index}: standalone GitHub inline math is indented as a code block; "
            "use fewer than four leading spaces or HTML spaces such as `&nbsp;` for visual indentation"
        )


def validate_table_spacing(path: Path, text: str, errors: list[str]) -> None:
    lines = text.splitlines()
    in_fence = False
    fence_marker = ""
    for index, line_text in enumerate(lines):
        stripped = line_text.lstrip()
        fence_match = CODE_FENCE_RE.match(stripped)
        if fence_match:
            marker = fence_match.group(1)
            if not in_fence:
                in_fence = True
                fence_marker = marker[:3]
            elif marker.startswith(fence_marker):
                in_fence = False
                fence_marker = ""
            continue
        if in_fence or index == 0 or index + 1 >= len(lines):
            continue
        previous = lines[index - 1]
        next_line = lines[index + 1]
        if not previous.strip() or previous.lstrip().startswith("|"):
            continue
        if TABLE_HEADER_RE.match(line_text) and TABLE_DELIMITER_RE.match(next_line):
            errors.append(
                f"{rel(path)}:{index + 1}: Markdown table starts immediately after text; "
                "add a blank line before the table so mdBook does not keep it in the previous paragraph"
            )


def validate_empty_pipe_table_placeholders(path: Path, text: str, errors: list[str]) -> None:
    lines = text.splitlines()
    in_fence = False
    fence_marker = ""
    for index, line_text in enumerate(lines, start=1):
        stripped = line_text.lstrip()
        fence_match = CODE_FENCE_RE.match(stripped)
        if fence_match:
            marker = fence_match.group(1)
            if not in_fence:
                in_fence = True
                fence_marker = marker[:3]
            elif marker.startswith(fence_marker):
                in_fence = False
                fence_marker = ""
            continue
        if in_fence:
            continue
        if EMPTY_PIPE_TABLE_ROW_RE.match(line_text):
            errors.append(
                f"{rel(path)}:{index}: empty Markdown table row placeholder; "
                "recover the Notion table contents or remove the placeholder"
            )


def validate_empty_details(path: Path, text: str, errors: list[str]) -> None:
    lines = text.splitlines()
    index = 0
    while index < len(lines):
        line_text = lines[index]
        if not DETAILS_OPEN_RE.search(line_text):
            index += 1
            continue
        start = index
        body_parts = [DETAILS_OPEN_TAG_RE.sub("", SUMMARY_RE.sub("", line_text))]
        index += 1
        while index < len(lines):
            if DETAILS_CLOSE_RE.search(lines[index]):
                body_parts.append(DETAILS_CLOSE_RE.sub("", lines[index]))
                break
            body_parts.append(lines[index])
            index += 1
        if index >= len(lines):
            break
        body = "\n".join(body_parts).strip()
        if not body:
            errors.append(
                f"{rel(path)}:{start + 1}: empty HTML details block; "
                "recover the missing content or remove the details wrapper"
            )
        index += 1


def blockchain_import_status(path: Path) -> str | None:
    try:
        relative = path.relative_to(ROOT)
    except ValueError:
        return None
    if len(relative.parts) < 4 or relative.parts[:2] != ("docs", "blockchain"):
        return None
    status = relative.parts[2]
    if status not in {"raw", "draft", "approved", "stable", "verified", "deprecated", "retired", "deleted"}:
        return None
    return status


def validate_blockchain_notion_links(path: Path, text: str, errors: list[str]) -> None:
    status = blockchain_import_status(path)
    if status is None:
        return
    for match in NOTION_URL_RE.finditer(text):
        line = line_number(text, match.start())
        errors.append(
            f"{rel(path)}:{line}: {status} blockchain specs should use local GitHub links/assets "
            f"instead of Notion URL `{match.group(0)}`"
        )


def validate_blockchain_shared_asset_links(path: Path, text: str, errors: list[str]) -> None:
    status = blockchain_import_status(path)
    if status is None:
        return
    relative = path.relative_to(ROOT)
    if relative.parent != Path("docs") / "blockchain" / status:
        return
    for match in MARKDOWN_LINK_TARGET_RE.finditer(text):
        target = match.group(1).strip().strip("<>")
        if target.startswith(("assets/", "images/")):
            line = line_number(text, match.start(1))
            errors.append(
                f"{rel(path)}:{line}: top-level {status} blockchain specs should keep assets "
                f"under the owning spec folder, e.g. `{path.stem}/assets/...`, not `{target}`"
            )


def validate_blockchain_notion_placeholders(path: Path, text: str, errors: list[str]) -> None:
    status = blockchain_import_status(path)
    if status is None:
        return
    for match in NOTION_PLACEHOLDER_RE.finditer(text):
        line = line_number(text, match.start())
        errors.append(
            f"{rel(path)}:{line}: unresolved Notion placeholder `{match.group(0)}`; "
            "convert the relation/equation/file reference to normal Markdown"
        )


def validate_file(path: Path, strict_github_inline_math: bool) -> list[str]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    errors: list[str] = []

    validate_block_math(path, text, errors)
    validate_github_inline_math(path, text, errors)
    validate_caption_inline_math(path, text, errors)
    validate_blockchain_notion_links(path, text, errors)
    validate_blockchain_shared_asset_links(path, text, errors)
    validate_blockchain_notion_placeholders(path, text, errors)
    validate_table_spacing(path, text, errors)
    validate_empty_pipe_table_placeholders(path, text, errors)
    validate_empty_details(path, text, errors)
    if strict_github_inline_math:
        validate_indented_standalone_github_math(path, text, errors)
        validate_standard_inline_math(path, text, errors)

    return errors


def main() -> int:
    args = parse_args()
    paths = [path for path in selected_paths(args) if path.suffix.lower() == ".md"]

    errors: list[str] = []
    for path in paths:
        if not path.exists():
            continue
        errors.extend(validate_file(path, args.strict_github_inline_math))

    for error in errors:
        print(f"[ERROR] {error}")

    if errors:
        print(f"[FAIL] rendering validation failed with {len(errors)} error(s)")
        return 1

    print(f"[OK] rendering validation passed for {len(paths)} file(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
