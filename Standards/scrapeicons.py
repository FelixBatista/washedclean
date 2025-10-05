#!/usr/bin/env python3
"""
Download all SVG files from the Wikimedia Commons category:
  Category:Laundry_symbols

This uses the MediaWiki API (more robust than scraping HTML),
filters to SVGs, and saves them locally with safe filenames.

Usage:
  python download_commons_svg_category.py

Requirements:
  pip install requests
"""

import os
import time
import re
import sys
import json
from pathlib import Path
from urllib.parse import quote

import requests

CATEGORY_NAME = "Laundry_symbols"  # Category without "Category:" prefix
DOWNLOAD_DIR = Path("laundry_symbols_svgs")
SLEEP_BETWEEN_REQUESTS = 0.4  # seconds, be polite to the API
MAX_RETRIES = 4
TIMEOUT = 30

API_ENDPOINT = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "LaundrySymbolsFetcher/1.0 (contact: your.email@example.com)"

def safe_filename(name: str) -> str:
    # Keep it simple and deterministic
    name = name.strip()
    # Replace unsafe chars and collapse spaces
    name = re.sub(r"[\\/:*?\"<>|]+", "_", name)
    name = re.sub(r"\s+", "_", name)
    return name

def request_with_retries(params: dict) -> dict:
    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = session.get(API_ENDPOINT, params=params, timeout=TIMEOUT)
            resp.raise_for_status()
            return resp.json()
        except Exception as e:
            if attempt == MAX_RETRIES:
                raise
            sleep_time = SLEEP_BETWEEN_REQUESTS * attempt
            print(f"[warn] API error ({e}), retrying in {sleep_time:.1f}s...", file=sys.stderr)
            time.sleep(sleep_time)
    return {}

def get_category_files(category: str):
    """
    Yield titles of files (namespace 6) in the given category.
    """
    cmcontinue = None
    while True:
        params = {
            "action": "query",
            "list": "categorymembers",
            "cmtitle": f"Category:{category}",
            "cmtype": "file",            # only files
            "cmlimit": "500",           # max per request
            "format": "json"
        }
        if cmcontinue:
            params["cmcontinue"] = cmcontinue

        data = request_with_retries(params)
        members = data.get("query", {}).get("categorymembers", [])
        for m in members:
            yield m["title"]  # e.g., "File:Some_name.svg"

        cmcontinue = data.get("continue", {}).get("cmcontinue")
        if not cmcontinue:
            break

        time.sleep(SLEEP_BETWEEN_REQUESTS)

def get_fileinfo_urls(titles):
    """
    Given up to 50 file titles, return a dict {title: (url, mime, size)}.
    """
    params = {
        "action": "query",
        "prop": "imageinfo",
        "titles": "|".join(titles),
        "iiprop": "url|size|mime",
        "format": "json"
    }
    data = request_with_retries(params)
    pages = data.get("query", {}).get("pages", {})
    results = {}
    for _, page in pages.items():
        title = page.get("title")
        info = page.get("imageinfo", [{}])
        if info and isinstance(info, list):
            ii = info[0]
            results[title] = (ii.get("url"), ii.get("mime"), ii.get("size"))
    return results

def batched(iterable, n=50):
    batch = []
    for item in iterable:
        batch.append(item)
        if len(batch) >= n:
            yield batch
            batch = []
    if batch:
        yield batch

def download_file(url: str, out_path: Path):
    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            with session.get(url, stream=True, timeout=TIMEOUT) as r:
                r.raise_for_status()
                with open(out_path, "wb") as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
            return
        except Exception as e:
            if attempt == MAX_RETRIES:
                raise
            sleep_time = SLEEP_BETWEEN_REQUESTS * attempt
            print(f"[warn] Download error ({e}), retrying in {sleep_time:.1f}s...", file=sys.stderr)
            time.sleep(sleep_time)

def main():
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)

    print(f"[info] Fetching files from Category:{CATEGORY_NAME} ...")
    all_titles = list(get_category_files(CATEGORY_NAME))
    print(f"[info] Found {len(all_titles)} files in the category.")

    total_downloaded = 0
    total_skipped = 0

    # Process in batches to respect API limits (max 50 titles/query)
    for batch in batched(all_titles, n=50):
        info_map = get_fileinfo_urls(batch)

        for title, (url, mime, size) in info_map.items():
            if not url:
                print(f"[skip] No URL for {title}")
                total_skipped += 1
                continue

            # Only SVGs (either by .svg in url or mime type)
            is_svg = (mime == "image/svg+xml") or url.lower().endswith(".svg")
            if not is_svg:
                print(f"[skip] Not SVG ({mime}): {title}")
                total_skipped += 1
                continue

            # Create safe filename
            # Title is like "File:Something.svg" — strip "File:" prefix
            base = title.split(":", 1)[-1]
            safe = safe_filename(base)
            out_path = DOWNLOAD_DIR / safe

            if out_path.exists():
                print(f"[keep] Already exists: {out_path.name}")
                total_skipped += 1
                continue

            print(f"[get] {title} -> {out_path.name}")
            try:
                download_file(url, out_path)
                total_downloaded += 1
            except Exception as e:
                print(f"[error] Failed to download {title}: {e}", file=sys.stderr)

        time.sleep(SLEEP_BETWEEN_REQUESTS)

    print(f"[done] Downloaded: {total_downloaded}, Skipped: {total_skipped}")
    print(f"[out] Saved to: {DOWNLOAD_DIR.resolve()}")

if __name__ == "__main__":
    main()
