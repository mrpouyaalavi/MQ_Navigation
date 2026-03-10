"""
MQ Course Handbook Scraper — 2026
----------------------------------
Phase 1 : CourseLoop API  -> discover all 2026 course codes (fast, no browser)
Phase 2 : requests + BS4  -> fetch each course page, extract __NEXT_DATA__ JSON
Phase 3 : concurrent pool -> scrape all courses in parallel (10 workers)

Output  : mq_courses_2026.csv
"""

import base64
import csv
import json
import re
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import requests
from bs4 import BeautifulSoup

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
BASE_HANDBOOK = "https://coursehandbook.mq.edu.au"
API_URL = "https://api-ap-southeast-2.prod.courseloop.com/publisher/search-academic-items?"
YEAR = 2026
OUT_CSV = Path(__file__).parent / "mq_courses_2026.csv"
CHECKPOINT = Path(__file__).parent / ".scrape_checkpoint.json"
WORKERS = 8
THROTTLE = 0.5   # seconds between requests per worker

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/122.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-AU,en;q=0.9",
}

API_HEADERS = {
    **HEADERS,
    "Content-Type": "text/plain;charset=UTF-8",
    "Referer": f"{BASE_HANDBOOK}/",
}

SESSION = requests.Session()
SESSION.headers.update(HEADERS)


# ---------------------------------------------------------------------------
# Phase 1 — CourseLoop API discovery
# ---------------------------------------------------------------------------

def _build_course_query(from_: int, size: int) -> dict:
    query = {
        "search": {
            "es": {
                "query": {
                    "bool": {
                        "filter": [
                            {"terms": {"contenttype": ["mqProd_pcourse"]}},
                            {"term": {"mqProd_pcourse.implementationYear": YEAR}},
                            {"term": {"live": True}},
                        ]
                    }
                },
                "sort": [{"mqProd_pcourse.title_dotraw": "asc"}],
                "from": from_,
                "size": size,
            },
            "prefix": "mqProd_p",
        }
    }
    encoded = base64.b64encode(json.dumps(query).encode()).decode()
    return {
        "siteId": "mq-prod-pres",
        "from": from_,
        "size": size,
        "esEncodedQuery": encoded,
        "siteYear": "current",
    }


def discover_courses() -> list[dict]:
    """Return list of {title, code, uri, lines} for all 2026 courses."""
    PAGE_SIZE = 100  # API hard limit

    # First call: get total count
    payload = _build_course_query(0, 1)
    r = SESSION.post(API_URL, headers=API_HEADERS, json=payload, timeout=30)
    r.raise_for_status()
    total = r.json()["data"]["total"]
    print(f"API reports {total} courses for {YEAR}")

    # Paginate in chunks of PAGE_SIZE
    all_results = []
    from_ = 0
    while from_ < total:
        payload = _build_course_query(from_, PAGE_SIZE)
        r = SESSION.post(API_URL, headers=API_HEADERS, json=payload, timeout=60)
        r.raise_for_status()
        batch = r.json()["data"]["results"]
        all_results.extend(batch)
        from_ += PAGE_SIZE
        if len(batch) < PAGE_SIZE:
            break

    print(f"Retrieved {len(all_results)} course entries")
    return all_results


# ---------------------------------------------------------------------------
# Phase 2 — Course page scraping
# ---------------------------------------------------------------------------

def _safe(val, key=None):
    """Safely extract .value or return as-is."""
    if val is None:
        return None
    if isinstance(val, dict):
        return val.get("value") if key is None else val.get(key)
    return val


def _text_list(items: list, key="value") -> str | None:
    """Join a list of dicts into a pipe-separated string."""
    if not items:
        return None
    parts = [str(i.get(key, "")) for i in items if i.get(key)]
    return " | ".join(parts) if parts else None


def _extract_offering(offering: list) -> dict:
    """Parse offering list -> sessions and locations."""
    if not offering:
        return {"sessions": None, "locations": None}
    sessions = []
    locations = []
    for o in offering:
        if o.get("publish") != "true":
            continue
        sess = _safe(o.get("admission_calendar"))
        loc = _safe(o.get("location"))
        if sess:
            sessions.append(sess)
        if loc:
            locations.append(loc)
    return {
        "sessions": " | ".join(dict.fromkeys(sessions)) or None,
        "locations": " | ".join(dict.fromkeys(locations)) or None,
    }


def _extract_specialisations(specs) -> str | None:
    if not specs:
        return None
    if isinstance(specs, list):
        names = [s.get("title") or s.get("name") or s.get("value", "") for s in specs]
        return " | ".join(n for n in names if n) or None
    return str(specs)


def scrape_course(api_entry: dict) -> dict:
    """Fetch one course page and extract all fields from __NEXT_DATA__."""
    uri = api_entry["uri"]   # e.g. /2026/courses/C000117
    url = BASE_HANDBOOK + uri
    time.sleep(THROTTLE)

    try:
        r = SESSION.get(url, timeout=30)
        r.raise_for_status()
    except Exception as exc:
        return {"handbook_url": url, "error": str(exc), "code": api_entry.get("code")}

    soup = BeautifulSoup(r.text, "html.parser")
    nd_tag = soup.find("script", id="__NEXT_DATA__")
    if not nd_tag:
        return {"handbook_url": url, "error": "no __NEXT_DATA__", "code": api_entry.get("code")}

    try:
        nd = json.loads(nd_tag.string)
        pc = nd["props"]["pageProps"]["pageContent"]
    except Exception as exc:
        return {"handbook_url": url, "error": str(exc), "code": api_entry.get("code")}

    # Faculty / org
    level1 = pc.get("level1_org_unit_data") or []
    faculty = level1[0]["name"] if level1 else _safe(pc.get("school"))

    # Offering: sessions + locations
    offering_data = _extract_offering(pc.get("offering") or [])

    # Course type label
    course_type = _safe(pc.get("type"), "label") or " | ".join(api_entry.get("lines", []))

    # AQF level
    aqf = _safe(pc.get("aqf_level"), "label")

    # Duration — prefer explicit fields, fall back to course_duration_in_years
    ft_dur = pc.get("full_time_duration") or ""
    pt_dur = pc.get("part_time_duration") or ""
    if not ft_dur and not pt_dur:
        dur_raw = _safe(pc.get("course_duration_in_years"), "label") or ""
        ft_dur = dur_raw

    # Study modes
    modes = pc.get("study_modes") or []
    delivery = _text_list(modes, "value") if isinstance(modes, list) else str(modes)

    # Specialisations / majors
    specs = _extract_specialisations(pc.get("specialisations"))
    majors = _extract_specialisations(pc.get("majors_minors"))

    # Learning outcomes — list of {code, description (HTML)} dicts
    outcomes_raw = pc.get("learning_outcomes") or []
    if isinstance(outcomes_raw, list):
        parts = []
        for lo in sorted(outcomes_raw, key=lambda x: int(x.get("order", 0) or 0)):
            desc_html = lo.get("description") or ""
            desc = BeautifulSoup(desc_html, "html.parser").get_text(" ", strip=True)
            if desc:
                parts.append(desc)
        outcomes_text = " | ".join(parts) or None
    elif isinstance(outcomes_raw, str) and outcomes_raw:
        outcomes_text = BeautifulSoup(outcomes_raw, "html.parser").get_text(" ", strip=True) or None
    else:
        outcomes_text = None

    # Overview (strip HTML, truncate)
    overview_html = pc.get("overview_and_aims_of_the_course") or ""
    overview = BeautifulSoup(overview_html, "html.parser").get_text(" ", strip=True)[:500] if overview_html else None

    # IELTS
    ielts_overall = pc.get("ielts_overall_score")

    # Units embedded in curriculum structure
    curriculum = pc.get("curriculumStructure") or {}
    units = _extract_units(curriculum)

    return {
        "year": YEAR,
        "code": pc.get("code") or api_entry.get("code"),
        "name": pc.get("title") or api_entry.get("title"),
        "course_type": course_type,
        "aqf_level": aqf,
        "credit_points": pc.get("credit_points"),
        "full_time_duration": ft_dur or None,
        "part_time_duration": pt_dur or None,
        "faculty": faculty,
        "cricos_code": pc.get("cricos_code") or None,
        "atar_min": pc.get("atar") or None,
        "ielts_overall": ielts_overall or None,
        "sessions": offering_data["sessions"],
        "locations": offering_data["locations"],
        "delivery_mode": delivery or None,
        "specialisations": specs,
        "majors_minors": majors,
        "overview": overview,
        "learning_outcomes": outcomes_text,
        "handbook_url": url,
        "unit_codes": " | ".join(u["code"] for u in units) if units else None,
        "unit_count": len(units),
    }


def _extract_units(curriculum: dict | list, seen: set | None = None) -> list[dict]:
    """
    Recursively pull all unit entries from the curriculum structure.
    Units appear in relationship[].child_record where type=x_f5sl_cl_subjects
    and value looks like 'Unit: ACST1052'.
    """
    if seen is None:
        seen = set()
    units = []

    if isinstance(curriculum, list):
        for item in curriculum:
            units.extend(_extract_units(item, seen))

    elif isinstance(curriculum, dict):
        # Check child_record for unit references (type=x_f5sl_cl_subjects)
        cr = curriculum.get("child_record")
        if isinstance(cr, dict) and cr.get("type") == "x_f5sl_cl_subjects":
            val = cr.get("value", "")
            # Value is like "Unit: ACST1052" or just a unit code
            m = re.search(r"([A-Z]{2,6}\d{3,4}[A-Z]?)", val)
            if m:
                code = m.group(1)
                if code not in seen:
                    seen.add(code)
                    units.append({"code": code, "name": val})

        # Recurse into container and relationship arrays
        for key in ("container", "relationship", "dynamic_relationship"):
            child = curriculum.get(key)
            if child:
                units.extend(_extract_units(child, seen))

    return units


# ---------------------------------------------------------------------------
# Checkpoint helpers
# ---------------------------------------------------------------------------

def load_checkpoint() -> tuple[set[str], list[dict]]:
    if CHECKPOINT.exists():
        data = json.loads(CHECKPOINT.read_text())
        return set(data.get("done", [])), data.get("rows", [])
    return set(), []


def save_checkpoint(done: set[str], rows: list[dict]):
    CHECKPOINT.write_text(json.dumps({"done": list(done), "rows": rows}))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    done_codes, all_rows = load_checkpoint()
    if done_codes:
        print(f"Resuming — {len(done_codes)} already done, {len(all_rows)} rows loaded")

    # Phase 1: discover
    api_courses = discover_courses()
    to_scrape = [c for c in api_courses if c["code"] not in done_codes]
    print(f"\nScraping {len(to_scrape)} courses with {WORKERS} workers...\n")

    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {pool.submit(scrape_course, entry): entry for entry in to_scrape}
        for i, future in enumerate(as_completed(futures), 1):
            entry = futures[future]
            try:
                row = future.result()
            except Exception as exc:
                row = {"code": entry.get("code"), "error": str(exc)}

            code = row.get("code", "?")
            name = row.get("name", "?")
            err = row.get("error")

            if err:
                print(f"  [{i:3d}/{len(to_scrape)}] ERR  {code} — {err}")
            else:
                print(f"  [{i:3d}/{len(to_scrape)}] OK   {code} — {name}")

            all_rows.append(row)
            done_codes.add(code)

            # Checkpoint every 10 courses
            if i % 10 == 0:
                save_checkpoint(done_codes, all_rows)

    # Write final CSV
    if all_rows:
        all_keys = list(dict.fromkeys(k for row in all_rows for k in row.keys()))
        with open(OUT_CSV, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=all_keys, extrasaction="ignore")
            writer.writeheader()
            for row in all_rows:
                writer.writerow({k: row.get(k, "") for k in all_keys})
        print(f"\nSaved {len(all_rows)} rows to {OUT_CSV}")
        if CHECKPOINT.exists():
            CHECKPOINT.unlink()
    else:
        print("\nNo data collected.")


if __name__ == "__main__":
    main()
