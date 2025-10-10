#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Scrape Illinois Extension "Stain Solutions" from the archived index page.
- Crawls the Wayback snapshot index to collect all stain detail links.
- Visits each archived detail page and extracts ONLY content inside #container > #content
  (with sensible fallbacks if the exact container isn't present).
- Handles multiple methods per fabric (split by an <h4> "Or").
- Saves a structured JSON Lines file and a flattened CSV (one row per method).
"""

import argparse
import csv
import json
import re
import time
from typing import List, Dict, Any, Optional
from urllib.parse import urljoin, unquote

import requests
from bs4 import BeautifulSoup, Tag

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; StainSolutionsCrawler/3.1)"}


# ----------------------------
# Utilities / HTML helpers
# ----------------------------
def text_of(node: Optional[Tag]) -> str:
    """Normalize text of a BeautifulSoup node (collapse whitespace)."""
    return re.sub(r"\s+", " ", node.get_text(" ", strip=True)) if node else ""


def list_items(lst: Optional[Tag]) -> List[str]:
    if not lst:
        return []
    return [text_of(li) for li in lst.find_all("li", recursive=False)]


def next_sibling_block(start: Tag, until_tags=("h1", "h2", "h3", "h4", "h5")) -> List[Tag]:
    """Collect sibling blocks after `start` until one of the heading tags appears."""
    out, ptr = [], start.next_sibling
    until = {t.lower() for t in until_tags}
    while ptr:
        if isinstance(ptr, Tag):
            if (ptr.name or "").lower() in until:
                break
            # Skip Wayback chrome fragments
            if (ptr.get("id") or "").startswith("wm-"):
                ptr = ptr.next_sibling
                continue
            out.append(ptr)
        ptr = ptr.next_sibling
    return out


def find_content_container(soup: BeautifulSoup) -> Optional[Tag]:
    """
    Prefer the original site's main content area: #container > #content.
    Fall back to common patterns if not present in this snapshot.
    """
    for sel in ["#container #content", "#content"]:
        node = soup.select_one(sel)
        if node:
            return node
    for sel in ["main", "[role=main]", "article", "div.container"]:
        node = soup.select_one(sel)
        if node:
            return node
    h1 = soup.find("h1")
    if h1:
        par = h1.find_parent("div")
        if par:
            return par
    return soup.body or soup


# ----------------------------
# Parsing a detail page
# ----------------------------
def parse_detail_page(html: str, archive_url: str, original_url: str) -> Optional[Dict[str, Any]]:
    soup = BeautifulSoup(html, "html.parser")
    content = find_content_container(soup)
    if not content:
        return None

    h1 = content.find("h1")
    if not h1:
        return None
    title = text_of(h1).strip()
    if not title:
        return None

    intro_notes, cautions, extra_bits = [], [], []

    # Intro blocks after H1 until the first H2
    for blk in next_sibling_block(h1, until_tags=("h2",)):
        if isinstance(blk, Tag) and blk.name in ("p", "div", "section", "blockquote"):
            t = text_of(blk)
            if not t:
                continue
            if t.lower().startswith("caution:"):
                cautions.append(t)
            else:
                intro_notes.append(t)

    sections: List[Dict[str, Any]] = []
    for h2 in content.find_all("h2"):
        section_name = text_of(h2).strip()
        if not section_name:
            continue

        blocks = next_sibling_block(h2, until_tags=("h2",))
        # Split alternative methods by H4 "Or"
        method_chunks: List[List[Tag]] = [[]]
        for blk in blocks:
            if isinstance(blk, Tag) and blk.name == "h4" and text_of(blk).strip().lower() == "or":
                method_chunks.append([])
            else:
                method_chunks[-1].append(blk)

        methods: List[Dict[str, Any]] = []
        for chunk in method_chunks:
            h3s = [n for n in chunk if isinstance(n, Tag) and n.name == "h3"]

            # If no h3s, keep raw text so nothing is lost
            if not h3s:
                raw = " ".join(text_of(n) for n in chunk if isinstance(n, Tag))
                if raw.strip():
                    methods.append({
                        "materials": [],
                        "steps": [],
                        "notes": [raw],
                        "cautions": [],
                        "extra": ""
                    })
                continue

            mats, steps, notes_local, cautions_local = [], [], [], []

            for i, h3 in enumerate(h3s):
                label = text_of(h3).strip().lower()
                start_idx = chunk.index(h3)
                end_idx = chunk.index(h3s[i + 1]) if i + 1 < len(h3s) else len(chunk)
                segment = chunk[start_idx + 1:end_idx]

                if "what you will need" in label:
                    ul = next((n for n in segment if isinstance(n, Tag) and n.name == "ul"), None)
                    mats.extend(list_items(ul))
                    # Some pages use paragraphs instead of a list
                    if not mats:
                        text_seg = " ".join(text_of(n) for n in segment if isinstance(n, Tag) and n.name == "p")
                        if text_seg.strip():
                            mats.append(text_seg.strip())

                elif "steps to clean" in label:
                    ol = next((n for n in segment if isinstance(n, Tag) and n.name == "ol"), None)
                    steps.extend(list_items(ol))
                    # Fallback to paragraphs
                    if not steps:
                        paras = [text_of(n) for n in segment if isinstance(n, Tag) and n.name == "p"]
                        steps.extend([p for p in paras if p])

                else:
                    # Other h3 sections -> notes (split out any "Caution:")
                    txt = " ".join(text_of(n) for n in segment if isinstance(n, Tag))
                    if txt.strip():
                        for line in re.split(r"(?:\n|(?<=\.)\s+)", txt):
                            if line.strip().lower().startswith("caution:"):
                                cautions_local.append(line.strip())
                            else:
                                notes_local.append(line.strip())

            # Any loose "Caution:" lines in the chunk
            for n in chunk:
                if isinstance(n, Tag):
                    t = text_of(n)
                    if t.lower().startswith("caution:") and t not in cautions_local:
                        cautions_local.append(t)

            methods.append({
                "materials": [m for m in (m.strip() for m in mats) if m],
                "steps": [s for s in (s.strip() for s in steps) if s],
                "notes": [n for n in (n.strip() for n in notes_local) if n],
                "cautions": [c for c in (c.strip() for c in cautions_local) if c],
                "extra": ""
            })

        if methods:
            sections.append({"section_name": section_name, "methods": methods})

    # Fallback if no H2 sections at all
    if not sections:
        ul = content.find("ul")
        ol = content.find("ol")
        mats = list_items(ul)
        stps = list_items(ol)
        if mats or stps or intro_notes:
            sections.append({
                "section_name": "General",
                "methods": [{
                    "materials": mats,
                    "steps": stps,
                    "notes": intro_notes,
                    "cautions": cautions,
                    "extra": ""
                }]
            })

    if not sections:
        return None

    return {
        "title": title,
        "intro_notes": intro_notes,
        "cautions": cautions,
        "sections": sections,
        "extra": extra_bits,
        "source_archive_url": archive_url,
        "source_original_url": original_url
    }


# ----------------------------
# Fetching / networking
# ----------------------------
def fetch(url: str, session: requests.Session, timeout: int = 40, retries: int = 3, backoff: float = 1.0) -> Optional[str]:
    for attempt in range(1, retries + 1):
        try:
            r = session.get(url, headers=HEADERS, timeout=timeout, allow_redirects=True)
            if r.status_code == 200 and r.text:
                return r.text
            if r.status_code in (404, 410):
                return None
        except requests.RequestException:
            pass
        time.sleep(backoff * attempt)
    return None


# ----------------------------
# Link canonicalization (Wayback)
# ----------------------------
def _fix_scheme_slash(url: str) -> str:
    # Wayback sometimes yields "https:/web.extension..." (one slash). Normalize.
    return re.sub(r'^(https?):/([^/])', r'\1://\2', url)


def _get_index_timestamp(index_url: str) -> str:
    m = re.search(r"/web/(\d{14})/", index_url)
    return m.group(1) if m else "20201127204719"


def canonicalize_from_archive(href: str, index_url: str) -> (str, str):
    """
    Return (archive_url, original_url) for ANY href on the index page:
      - /web/<ts>/https%3A//web.extension.illinois.edu/stain/staindetail.cfm?ID=3
      - https://web.archive.org/web/<ts>/https://web.extension.illinois.edu/stain/staindetail.cfm?ID=3
      - staindetail.cfm?ID=3
      - https://web.extension.illinois.edu/stain/staindetail.cfm?ID=3
    """
    if not href:
        return "", ""

    ts = _get_index_timestamp(index_url)
    href = href.strip()

    # Case A: starts with /web/<ts>/
    if href.startswith("/web/"):
        archive_url = urljoin("https://web.archive.org", href)
        m = re.match(r"^/web/\d{14}/(.+)$", href)
        original_raw = m.group(1) if m else ""
        original_url = _fix_scheme_slash(unquote(original_raw))
        return archive_url, original_url

    # Case B: absolute Wayback URL
    if href.startswith("http://web.archive.org/") or href.startswith("https://web.archive.org/"):
        archive_url = href
        m = re.match(r"^https?://web\.archive\.org/web/\d{14}/(.+)$", href)
        original_raw = m.group(1) if m else ""
        original_url = _fix_scheme_slash(unquote(original_raw))
        return archive_url, original_url

    # Case C: absolute original URL — wrap with the index timestamp
    if href.startswith("http://") or href.startswith("https://"):
        original_url = _fix_scheme_slash(href)
        archive_url = f"https://web.archive.org/web/{ts}/{original_url}"
        return archive_url, original_url

    # Case D: relative original URL (common on this index)
    base_original = "https://web.extension.illinois.edu/stain/"
    original_url = urljoin(base_original, href)
    archive_url = f"https://web.archive.org/web/{ts}/{original_url}"
    return archive_url, original_url


def is_detail_href(href: str) -> bool:
    if not href:
        return False
    dec = unquote(href)
    return ("staindetail.cfm" in href) or ("staindetail.cfm" in dec)


def collect_detail_links(index_html: str, index_url: str) -> List[Dict[str, str]]:
    """
    Parse ALL <a> tags in the index snapshot, normalize to (archive_url, original_url),
    and return de-duplicated links to stain detail pages.
    """
    soup = BeautifulSoup(index_html, "html.parser")

    links: List[Dict[str, str]] = []
    seen = set()

    # We search ALL anchors to avoid missing anything due to strict container selection.
    for a in soup.find_all("a", href=True):
        href = a["href"].strip()
        if not is_detail_href(href):
            continue

        arch, orig = canonicalize_from_archive(href, index_url)
        if not arch or not orig:
            continue

        if orig in seen:
            continue
        seen.add(orig)

        links.append({
            "name": text_of(a).strip(),
            "archive_url": arch,
            "original_url": orig
        })

    print(f"Collected {len(links)} detail links from index.")
    return links


# ----------------------------
# Output shaping
# ----------------------------
def flatten_for_csv(record: Dict[str, Any], idx: int) -> List[Dict[str, Any]]:
    """
    Flatten a single record into multiple CSV rows (one row per method).
    """
    rows = []
    title = record.get("title", "")
    intro = " | ".join(record.get("intro_notes", []) or [])
    top_cautions = " | ".join(record.get("cautions", []) or [])
    extra = " | ".join(record.get("extra", []) or [])
    src_arch = record.get("source_archive_url", "")
    src_orig = record.get("source_original_url", "")

    for sec in record.get("sections", []):
        sname = sec.get("section_name", "")
        for midx, m in enumerate(sec.get("methods", []), start=1):
            rows.append({
                "row_id": f"{idx}-{midx}",
                "stain_title": title,
                "section": sname,
                "method_index": midx,
                "materials": " ; ".join(m.get("materials", [])),
                "steps": " || ".join(m.get("steps", [])),
                "method_notes": " | ".join(m.get("notes", [])),
                "method_cautions": " | ".join(m.get("cautions", [])),
                "intro_notes": intro,
                "top_cautions": top_cautions,
                "source_archive_url": src_arch,
                "source_original_url": src_orig,
                "extra": extra or m.get("extra", "")
            })
    return rows


# ----------------------------
# Main scrape routine
# ----------------------------
def scrape_from_index(index_url: str, sleep_s: float, out_prefix: str, limit: Optional[int] = None):
    jsonl_path = f"{out_prefix}.jsonl"
    csv_path = f"{out_prefix}.csv"
    fieldnames = [
        "row_id", "stain_title", "section", "method_index",
        "materials", "steps", "method_notes", "method_cautions",
        "intro_notes", "top_cautions",
        "source_archive_url", "source_original_url",
        "extra"
    ]

    session = requests.Session()

    # 1) Fetch index
    idx_html = fetch(index_url, session)
    if not idx_html:
        raise SystemExit(f"Could not fetch index: {index_url}")

    # 2) Collect links
    detail_links = collect_detail_links(idx_html, index_url)
    if not detail_links:
        raise SystemExit("No detail links found on the index page.")

    if limit is not None:
        detail_links = detail_links[:limit]

    print(f"Found {len(detail_links)} stain links on index.")

    total_ok = 0
    with open(jsonl_path, "w", encoding="utf-8") as jf, \
         open(csv_path, "w", newline="", encoding="utf-8") as cf:

        writer = csv.DictWriter(cf, fieldnames=fieldnames)
        writer.writeheader()

        for i, link in enumerate(detail_links, start=1):
            arch = link["archive_url"]
            orig = link["original_url"]
            html = fetch(arch, session)
            if not html:
                print(f"[MISS] {i}/{len(detail_links)} {orig}")
                time.sleep(sleep_s)
                continue

            record = parse_detail_page(html, arch, orig)
            if not record:
                print(f"[SKIP] {i}/{len(detail_links)} {orig} (no structured content)")
                time.sleep(sleep_s)
                continue

            # JSONL: one full record per stain
            jf.write(json.dumps(record, ensure_ascii=False) + "\n")

            # CSV: one row per method
            rows = flatten_for_csv(record, i)
            if not rows:
                # Minimal fallback row
                rows = [{
                    "row_id": f"{i}-1",
                    "stain_title": record.get("title", ""),
                    "section": "",
                    "method_index": 1,
                    "materials": "",
                    "steps": "",
                    "method_notes": " | ".join(record.get("intro_notes", [])),
                    "method_cautions": " | ".join(record.get("cautions", [])),
                    "intro_notes": " | ".join(record.get("intro_notes", [])),
                    "top_cautions": " | ".join(record.get("cautions", [])),
                    "source_archive_url": arch,
                    "source_original_url": orig,
                    "extra": " | ".join(record.get("extra", []))
                }]
            for row in rows:
                writer.writerow(row)

            total_ok += 1
            print(f"[OK]  {i}/{len(detail_links)} {record.get('title','(no title)')} -> {len(rows)} row(s)")
            time.sleep(sleep_s)

    print(f"Done. Parsed {total_ok} stains with content.")
    print(f"Wrote: {jsonl_path} and {csv_path}")


# ----------------------------
# CLI
# ----------------------------
def main():
    ap = argparse.ArgumentParser(description="Scrape Illinois Extension Stain Solutions via archived index.")
    ap.add_argument("--index", type=str, required=True,
                    help="Wayback snapshot URL of the index page, e.g. "
                         "https://web.archive.org/web/20201127204719/https://web.extension.illinois.edu/stain/index.cfm")
    ap.add_argument("--sleep", type=float, default=0.6, help="Seconds to sleep between requests")
    ap.add_argument("--out-prefix", type=str, default="stain_solutions", help="Output filename prefix")
    ap.add_argument("--limit", type=int, default=None, help="Optional limit for quick tests")
    args = ap.parse_args()

    scrape_from_index(args.index, args.sleep, args.out_prefix, args.limit)


if __name__ == "__main__":
    main()
