#!/usr/bin/env python3
import html
import json
import re
import sys
from typing import Dict, List


FENCED_CODE_RE = re.compile(r"```[\s\S]*?```|~~~[\s\S]*?~~~")
INLINE_CODE_RE = re.compile(r"`+[^`\n]*?`+")
BLOCK_MATH_RE = re.compile(r"(?<!\\)\$\$(.+?)(?<!\\)\$\$", re.DOTALL)
INLINE_MATH_RE = re.compile(r"(?<!\\)\$(?!\$)([^\n]*?)(?<!\\)\$")
ALT_BLOCK_MATH_RE = re.compile(
    r"(?<!\\)\$`\s*\n(.+?)\n\s*`\$(?!\$)",
    re.DOTALL,
)


def protect(text: str, pattern: re.Pattern, store: List[str], prefix: str) -> str:
    def repl(match: re.Match) -> str:
        key = f"{prefix}{len(store)}@@"
        store.append(match.group(0))
        return key

    return pattern.sub(repl, text)


def restore(text: str, store: List[str], prefix: str) -> str:
    for idx, value in enumerate(store):
        text = text.replace(f"{prefix}{idx}@@", value)
    return text


def encode_attr(content: str) -> str:
    encoded = html.escape(content, quote=True)
    return encoded.replace("\n", "&#10;")


def render_block(match: re.Match) -> str:
    content = match.group(1).strip("\n")
    encoded = encode_attr(content)
    return f"<div class=\"math-block\" data-tex=\"{encoded}\"></div>"


def render_inline(match: re.Match) -> str:
    content = match.group(1)
    encoded = encode_attr(content)
    return f"<span class=\"math-inline\" data-tex=\"{encoded}\"></span>"


def transform(content: str) -> str:
    code_blocks: List[str] = []
    inline_codes: List[str] = []

    content = protect(content, FENCED_CODE_RE, code_blocks, "@@CODEBLOCK")
    content = protect(content, INLINE_CODE_RE, inline_codes, "@@INLINECODE")

    content = ALT_BLOCK_MATH_RE.sub(render_block, content)
    content = BLOCK_MATH_RE.sub(render_block, content)
    content = INLINE_MATH_RE.sub(render_inline, content)

    content = restore(content, inline_codes, "@@INLINECODE")
    content = restore(content, code_blocks, "@@CODEBLOCK")

    return content


def process_item(item: Dict) -> None:
    if "Chapter" in item:
        chapter = item["Chapter"]
        if "content" in chapter and chapter["content"]:
            chapter["content"] = transform(chapter["content"])
        for sub in chapter.get("sub_items", []):
            process_item(sub)


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "supports":
        return 0

    data = json.load(sys.stdin)
    if isinstance(data, list) and len(data) == 2:
        book = data[1]
    elif isinstance(data, dict):
        book = data.get("book", {})
    else:
        book = {}
    for section in book.get("sections", []):
        process_item(section)

    json.dump(book, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
