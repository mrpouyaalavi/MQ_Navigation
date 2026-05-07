#!/usr/bin/env python3
"""Add onboardingTransitDataAttribution to locale JSON + ARBs (TfNSW open-data credit)."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARB_DIR = ROOT / "lib" / "app" / "l10n"
JSON_PATH = ROOT / "scripts" / "onboarding_google_map_arb_translations.json"

# TfNSW = Transport for NSW; keep acronym TfNSW for brand/legal consistency.
ATTR: dict[str, str] = {
    "ar": "تستخدم مواعيد المغادرة الفورية بيانات مفتوحة من هيئة النقل في نيو ساوث ويلز (TfNSW).",
    "bn": "রিয়েল-টাইম ছাড়ার তথ্য নিউ সাউথ ওয়েলস পরিবহন কর্তৃপক্ষের (Transport for NSW, TfNSW) উন্মুক্ত ডেটা ব্যবহার করে।",
    "cs": "Odjezdy v reálném čase využívají otevřená data organizace Transport for NSW (TfNSW).",
    "da": "Afgang i realtid bruger åbne data fra Transport for NSW (TfNSW).",
    "de": "Abfahrten in Echtzeit nutzen Open Data von Transport for NSW (TfNSW).",
    "el": "Οι αναχωρήσεις σε πραγματικό χρόνο χρησιμοποιούν ανοιχτά δεδομένα από το Transport for NSW (TfNSW).",
    "es": "Las salidas en tiempo real usan datos abiertos de Transport for NSW (TfNSW).",
    "fa": "زمان‌های حرکت بلادرنگ از دادهٔ باز Transport for NSW (TfNSW) استفاده می‌کند.",
    "fi": "Reaaliaikaiset lähdöt hyödyntävät Transport for NSW:n (TfNSW) avointa dataa.",
    "fr": "Les départs en temps réel s’appuient sur les données ouvertes de Transport for NSW (TfNSW).",
    "he": "זמני יציאה בזמן אמת משתמשים בנתונים פתוחים מ-Transport for NSW (TfNSW).",
    "hi": "रीयल-टाइम प्रस्थान जानकारी Transport for NSW (TfNSW) के ओपन डेटा का उपयोग करती है।",
    "hu": "Az élő indulások a Transport for NSW (TfNSW) nyílt adatait használják.",
    "id": "Keberangkatan real time memakai data terbuka dari Transport for NSW (TfNSW).",
    "it": "Le partenze in tempo reale usano dati aperti di Transport for NSW (TfNSW).",
    "ja": "リアルタイムの発車情報は Transport for NSW（TfNSW）のオープンデータを利用しています。",
    "ko": "실시간 출발 정보는 Transport for NSW(TfNSW)의 공개 데이터를 사용합니다.",
    "ms": "Berlepas masa nyata menggunakan data terbuka daripada Transport for NSW (TfNSW).",
    "ne": "वास्तविक-समय प्रस्थानहरूले Transport for NSW (TfNSW) को खुला डाटा प्रयोग गर्छन्।",
    "nl": "Realtime vertrekken gebruiken open data van Transport for NSW (TfNSW).",
    "no": "Sanntidsavganger bruker åpne data fra Transport for NSW (TfNSW).",
    "pl": "Odjazdy w czasie rzeczywistym korzystają z otwartych danych Transport for NSW (TfNSW).",
    "pt": "Partidas em tempo real usam dados abertos da Transport for NSW (TfNSW).",
    "ro": "Plecările în timp real folosesc date deschise de la Transport for NSW (TfNSW).",
    "ru": "Отправления в реальном времени используют открытые данные Transport for NSW (TfNSW).",
    "si": "සජීවී පිටත්වීම් Transport for NSW (TfNSW) හි විවෘත දත්ත භාවිතා කරයි.",
    "sv": "Avgångar i realtid använder öppna data från Transport for NSW (TfNSW).",
    "ta": "நிகழ்நேர புறப்பாடுகள் Transport for NSW (TfNSW) இன் திறந்த தரவைப் பயன்படுத்துகின்றன.",
    "th": "เวลาออกแบบเรียลไทม์ใช้ข้อมูลเปิดจาก Transport for NSW (TfNSW)",
    "tr": "Gerçek zamanlı kalkışlar, Transport for NSW (TfNSW) açık verilerini kullanır.",
    "uk": "Відправлення в реальному часі використовують відкриті дані Transport for NSW (TfNSW).",
    "ur": "حقیقی وقت کی روانگیاں Transport for NSW (TfNSW) کے کھلے ڈیٹا کو استعمال کرتی ہیں۔",
    "vi": "Giờ khởi hành theo thời gian thực dùng dữ liệu mở từ Transport for NSW (TfNSW).",
    "zh": "实时发车信息使用新南威尔士州交通局（Transport for NSW，TfNSW）的开放数据。",
}


def main() -> None:
    en_path = ARB_DIR / "app_en.arb"
    en = json.loads(en_path.read_text(encoding="utf-8"))
    key = "onboardingTransitDataAttribution"
    if key not in en:
        raise SystemExit(f"{en_path} missing {key}")

    data_json = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    if set(ATTR) != set(data_json):
        missing = set(data_json) - set(ATTR)
        extra = set(ATTR) - set(data_json)
        raise SystemExit(f"Locale mismatch JSON vs ATTR. missing={missing} extra={extra}")

    for locale, text in ATTR.items():
        data_json[locale][key] = text

    JSON_PATH.write_text(json.dumps(data_json, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    for locale, text in ATTR.items():
        arb_path = ARB_DIR / f"app_{locale}.arb"
        loc = json.loads(arb_path.read_text(encoding="utf-8"))
        loc[key] = text
        arb_path.write_text(json.dumps(loc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"Synced {key} into {JSON_PATH.name} and {len(ATTR)} ARBs.")


if __name__ == "__main__":
    main()
