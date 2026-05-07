#!/usr/bin/env python3
"""Merge translated onboarding + Google map strings from JSON into locale ARBs."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TRANSLATIONS_PATH = ROOT / "scripts" / "onboarding_google_map_arb_translations.json"
ARB_DIR = ROOT / "lib" / "app" / "l10n"


def main() -> None:
    translations = json.loads(TRANSLATIONS_PATH.read_text(encoding="utf-8"))
    for locale, strings in sorted(translations.items()):
        arb_path = ARB_DIR / f"app_{locale}.arb"
        if not arb_path.is_file():
            raise SystemExit(f"Missing ARB: {arb_path}")
        data = json.loads(arb_path.read_text(encoding="utf-8"))
        for key, value in strings.items():
            if key not in data:
                raise SystemExit(f"{arb_path}: missing key {key}")
            data[key] = value
        arb_path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    print(f"Patched {len(translations)} locale ARB files.")


if __name__ == "__main__":
    main()
