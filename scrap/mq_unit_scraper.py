"""
MQ Unit Handbook Scraper — 2026
---------------------------------
Phase 1 : CourseLoop API  -> discover all 2026 unit codes   (~2 328 units)
Phase 2 : requests + BS4  -> fetch each unit page, extract __NEXT_DATA__ JSON
Phase 3 : concurrent pool -> 12 workers, 0.3 s throttle per worker

Output  : mq_units_2026.csv
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
OUT_CSV = Path(__file__).parent / "mq_units_2026.csv"
CHECKPOINT = Path(__file__).parent / ".unit_scrape_checkpoint.json"
WORKERS = 4
THROTTLE = 1.0   # seconds between requests per worker
PAGE_SIZE = 100  # API hard limit

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

def _build_unit_query(from_: int, size: int) -> dict:
    query = {
        "search": {
            "es": {
                "query": {
                    "bool": {
                        "filter": [
                            {"terms": {"contenttype": ["mqProd_psubject"]}},
                            {"term": {"mqProd_psubject.implementationYear": YEAR}},
                            {"term": {"live": True}},
                        ]
                    }
                },
                "sort": [{"mqProd_psubject.title_dotraw": "asc"}],
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


def discover_units() -> list[dict]:
    """Return list of {title, code, uri, lines} for all 2026 units."""
    payload = _build_unit_query(0, 1)
    r = SESSION.post(API_URL, headers=API_HEADERS, json=payload, timeout=30)
    r.raise_for_status()
    total = r.json()["data"]["total"]
    print(f"API reports {total} units for {YEAR}")

    all_results = []
    from_ = 0
    while from_ < total:
        payload = _build_unit_query(from_, PAGE_SIZE)
        r = SESSION.post(API_URL, headers=API_HEADERS, json=payload, timeout=60)
        r.raise_for_status()
        batch = r.json()["data"]["results"]
        all_results.extend(batch)
        print(f"  Page {from_//PAGE_SIZE + 1}: {len(batch)} units (total so far: {len(all_results)})")
        from_ += PAGE_SIZE
        if len(batch) < PAGE_SIZE:
            break

    print(f"Retrieved {len(all_results)} unit entries")
    return all_results


# ---------------------------------------------------------------------------
# Phase 2 — Unit page parsing helpers
# ---------------------------------------------------------------------------

def _safe_val(obj, key="value"):
    if isinstance(obj, dict):
        return obj.get(key)
    return obj


def _strip_html(html: str | None) -> str | None:
    if not html:
        return None
    text = BeautifulSoup(html, "html.parser").get_text(" ", strip=True)
    return text or None


def _extract_ulos(ulos: list) -> str | None:
    """Unit Learning Outcomes -> pipe-separated plain text."""
    if not ulos:
        return None
    parts = []
    for lo in sorted(ulos, key=lambda x: int(x.get("order") or 0)):
        desc = _strip_html(lo.get("description"))
        code = lo.get("code", "")
        if desc:
            parts.append(f"{code}: {desc}" if code else desc)
    return " | ".join(parts) or None


def _extract_assessments(asmts: list) -> tuple[str | None, str | None]:
    """
    Returns (assessment_summary, assessment_types).
    assessment_summary: "Task 1 (40%) | Task 2 (60%)"
    assessment_types:   "Portfolio | Written Examination"
    """
    if not asmts:
        return None, None
    summaries = []
    types_ = []
    for a in asmts:
        title = a.get("assessment_title", "")
        weight = a.get("weight", "")
        atype = _safe_val(a.get("type"), "label") or ""
        if title or weight:
            summaries.append(f"{title} ({weight}%)".strip())
        if atype and atype not in types_:
            types_.append(atype)
    return (" | ".join(summaries) or None), (" | ".join(types_) or None)


def _extract_offerings(offerings: list) -> tuple[str | None, str | None, str | None]:
    """Returns (sessions, locations, attendance_modes)."""
    if not offerings:
        return None, None, None
    sessions, locs, modes = [], [], []
    for o in offerings:
        if o.get("publish") != "true":
            continue
        sess = _safe_val(o.get("teaching_period"))
        loc = _safe_val(o.get("location"))
        mode = _safe_val(o.get("attendance_mode"))
        if sess and sess not in sessions:
            sessions.append(sess)
        if loc and loc not in locs:
            locs.append(loc)
        if mode and mode not in modes:
            modes.append(mode)
    return (
        " | ".join(sessions) or None,
        " | ".join(locs) or None,
        " | ".join(modes) or None,
    )


def _extract_requisites(rules: list, requisites: list) -> tuple[str | None, str | None, str | None]:
    """
    Returns (prerequisites, corequisites, nccws) — all unit codes.
    Pulls from both enrolment_rules and requisites lists.
    """
    prereqs, coreqs, nccws = [], [], []

    def _classify(rtype: str, description: str):
        rtype = (rtype or "").lower()
        code_match = re.search(r"([A-Z]{2,6}\d{3,4}[A-Z]?)", description)
        code = code_match.group(1) if code_match else description.strip()
        if not code:
            return
        if "prerequisite" in rtype:
            if code not in prereqs:
                prereqs.append(code)
        elif "corequisite" in rtype and "anti" not in rtype:
            if code not in coreqs:
                coreqs.append(code)
        elif "nccw" in rtype or "anti" in rtype or "exclusion" in rtype:
            if code not in nccws:
                nccws.append(code)

    for rule in (rules or []):
        rtype = _safe_val(rule.get("type"), "value") or ""
        desc = rule.get("description", "")
        _classify(rtype, desc)

    for req in (requisites or []):
        rtype = _safe_val(req.get("requisite_type"), "value") or ""
        desc = req.get("description", "") or _safe_val(req.get("cl_id"), "value") or ""
        _classify(rtype, desc)

    return (
        " | ".join(prereqs) or None,
        " | ".join(coreqs) or None,
        " | ".join(nccws) or None,
    )


# ---------------------------------------------------------------------------
# Phase 2 — Main unit scraping function
# ---------------------------------------------------------------------------

FALLBACK_YEARS = [2025, 2024, 2023, 2022]


def scrape_unit(api_entry: dict) -> dict:
    """Fetch one unit page and extract all fields from __NEXT_DATA__."""
    code = api_entry.get("code", "")
    time.sleep(THROTTLE)

    # Try 2026 first, then fall back to recent years if 403
    years_to_try = [YEAR] + FALLBACK_YEARS
    r = None
    url = None
    for yr in years_to_try:
        url = f"{BASE_HANDBOOK}/{yr}/units/{code}/"
        try:
            r = SESSION.get(url, timeout=30)
            if r.status_code == 200:
                break
            # On 403, try next year
        except Exception as exc:
            return {"handbook_url": url, "error": str(exc), "code": code}

    if r is None or r.status_code != 200:
        return {"handbook_url": url, "error": f"HTTP {r.status_code if r else '?'} on all years", "code": code}

    soup = BeautifulSoup(r.text, "html.parser")
    nd_tag = soup.find("script", id="__NEXT_DATA__")
    if not nd_tag:
        return {"handbook_url": url, "error": "no __NEXT_DATA__", "code": code}

    try:
        nd = json.loads(nd_tag.string)
        pc = nd["props"]["pageProps"]["pageContent"]
    except Exception as exc:
        return {"handbook_url": url, "error": str(exc), "code": code}

    # Basic fields
    code = pc.get("code") or code
    title = pc.get("title") or api_entry.get("title")
    credit_points = pc.get("credit_points")
    level = _safe_val(pc.get("level"), "label")
    school = _safe_val(pc.get("school"))
    status = _safe_val(pc.get("status"), "label")
    unit_type = _safe_val(pc.get("type"), "label") or ""
    special_unit_type = pc.get("special_unit_type") or ""

    # Description / overview (strip HTML)
    description = _strip_html(pc.get("description"))
    overview = _strip_html(pc.get("overview"))
    # Prefer description; some units use overview instead
    desc_text = description or overview

    # Learning outcomes
    ulos_text = _extract_ulos(pc.get("unit_learning_outcomes") or [])

    # Assessments
    asmt_summary, asmt_types = _extract_assessments(pc.get("assessments") or [])

    # Offerings: sessions, locations, delivery mode
    sessions, locations, delivery = _extract_offerings(pc.get("unit_offering") or [])

    # Requisites
    prereqs, coreqs, nccws = _extract_requisites(
        pc.get("enrolment_rules") or [],
        pc.get("requisites") or [],
    )

    # Exclusions field (separate from requisites on some units)
    exclusions_raw = pc.get("exclusions") or ""
    exclusions = _strip_html(exclusions_raw) if exclusions_raw else None

    # ASCED discipline code (govt classification)
    asced_broad = _safe_val(pc.get("asced_broad"))
    asced_detail = _safe_val(pc.get("asced_detailed"))

    return {
        "year": YEAR,
        "code": code,
        "title": title,
        "credit_points": credit_points,
        "level": level,
        "school": school,
        "unit_type": unit_type,
        "special_unit_type": special_unit_type or None,
        "status": status,
        "description": desc_text,
        "learning_outcomes": ulos_text,
        "assessment_summary": asmt_summary,
        "assessment_types": asmt_types,
        "sessions": sessions,
        "locations": locations,
        "delivery_mode": delivery,
        "prerequisites": prereqs,
        "corequisites": coreqs,
        "nccws": nccws,
        "exclusions": exclusions,
        "asced_broad": asced_broad,
        "asced_detailed": asced_detail,
        "handbook_url": url,
    }


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

    # Phase 1: discover all units
    api_units = discover_units()
    to_scrape = [u for u in api_units if u["code"] not in done_codes]
    total = len(to_scrape)
    print(f"\nScraping {total} units with {WORKERS} workers...\n")

    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {pool.submit(scrape_unit, entry): entry for entry in to_scrape}
        for i, future in enumerate(as_completed(futures), 1):
            entry = futures[future]
            try:
                row = future.result()
            except Exception as exc:
                row = {"code": entry.get("code"), "error": str(exc)}

            code = row.get("code", "?")
            title = row.get("title", "?")
            err = row.get("error")

            if err:
                print(f"  [{i:4d}/{total}] ERR  {code} — {err}")
            else:
                print(f"  [{i:4d}/{total}] OK   {code} — {title}")

            all_rows.append(row)
            done_codes.add(code)

            # Checkpoint every 50 units
            if i % 50 == 0:
                save_checkpoint(done_codes, all_rows)

    # Write final CSV
    if all_rows:
        all_keys = list(dict.fromkeys(k for row in all_rows for k in row.keys()))
        with open(OUT_CSV, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=all_keys, extrasaction="ignore")
            writer.writeheader()
            for row in all_rows:
                writer.writerow({k: row.get(k, "") for k in all_keys})
        print(f"\nSaved {len(all_rows)} units to {OUT_CSV}")
        if CHECKPOINT.exists():
            CHECKPOINT.unlink()
    else:
        print("\nNo data collected.")


if __name__ == "__main__":
    main()
