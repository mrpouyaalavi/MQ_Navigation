#!/usr/bin/env python3
"""Apply meaning-reviewed onboarding strings from web-verified facts.

- Transport for NSW (TfNSW) coordinates NSW transport; Sydney Metro operates metro rail.
  Copy now names Sydney Metro + trains + buses (see app_en.arb).
- \"Dual-mode campus map\": two display modes (Google vs illustrated), not a duplicate map.
- Sinhala \"satellite\" map label: use චන්ද්‍රිකා (standard term vs ad-hoc transliteration).

Google Maps types (hybrid = satellite + labels; terrain = physical relief) stay short in UI menus.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
JSON_PATH = ROOT / "scripts" / "onboarding_google_map_arb_translations.json"

PATCHES: dict[str, dict[str, str]] = {
    "ar": {
        "onboardingMapTitle": "خريطة الحرم الجامعي ثنائية الوضع",
        "onboardingTransitBody": "تابع مغادرات مترو سيدني والقطارات والحافلات في الوقت الفعلي من الشاشة الرئيسية.",
    },
    "bn": {
        "onboardingMapTitle": "দ্বৈত মোডের ক্যাম্পাস মানচিত্র",
        "onboardingTransitBody": "হোম স্ক্রিন থেকে সিডনি মেট্রো, ট্রেন ও বাসের রিয়েল-টাইম ছাড়ার সময় ট্র্যাক করুন।",
    },
    "cs": {
        "onboardingMapTitle": "Mapa kampusu ve dvou režimech",
        "onboardingTransitBody": "Sledujte odjezdy Sydney Metro, vlaků a autobusů v reálném čase přímo z domovské obrazovky.",
    },
    "da": {
        "onboardingMapTitle": "Campuskort med to tilstande",
        "onboardingTransitBody": "Følg Sydney Metro, tog og busser i realtid fra startskærmen.",
    },
    "de": {
        "onboardingMapTitle": "Campuskarte mit zwei Modi",
        "onboardingTransitBody": "Verfolgen Sie Sydney Metro, Züge und Busse in Echtzeit vom Startbildschirm aus.",
    },
    "el": {
        "onboardingMapTitle": "Χάρτης πανεπιστημιούπολης σε διπλή λειτουργία",
        "onboardingTransitBody": "Παρακολουθήστε σε πραγματικό χρόνο τις αναχωρήσεις του Sydney Metro, τρένων και λεωφορείων από την αρχική οθόνη.",
    },
    "es": {
        "onboardingMapTitle": "Mapa del campus en dos modos",
        "onboardingTransitBody": "Consulta en tiempo real las salidas del metro de Sydney, trenes y autobuses desde la pantalla de inicio.",
    },
    "fa": {
        "onboardingMapTitle": "نقشهٔ پردیس با دو حالت",
        "onboardingTransitBody": "زمان حرکت مترو سیدنی، قطارها و اتوبوس‌ها را به‌صورت بلادرنگ از صفحهٔ خانه دنبال کنید.",
    },
    "fi": {
        "onboardingMapTitle": "Kahden tilan kampuskartta",
        "onboardingTransitBody": "Seuraa Sydney Metron, junien ja bussien lähtöjä reaaliajassa kotinäytöltä.",
    },
    "fr": {
        "onboardingMapTitle": "Carte du campus à deux modes",
        "onboardingTransitBody": "Suivez en temps réel les départs du métro de Sydney, des trains et des bus depuis l’écran d’accueil.",
    },
    "he": {
        "onboardingMapTitle": "מפת קמפוס בשתי מצבים",
        "onboardingTransitBody": "עקבו אחר יציאות מטרו סידני, רכבות ואוטובוסים בזמן אמת ממסך הבית.",
    },
    "hi": {
        "onboardingMapTitle": "दोहरा मोड वाला कैंपस मानचित्र",
        "onboardingTransitBody": "होम स्क्रीन से सिडनी मेट्रो, ट्रेनों और बसों की रीयल-टाइम प्रस्थान जानकारी देखें।",
    },
    "hu": {
        "onboardingMapTitle": "Kampusztérkép két módban",
        "onboardingTransitBody": "Kövesse élőben a Sydney Metro, a vonatok és a buszok indulását a kezdőképernyőről.",
    },
    "id": {
        "onboardingMapTitle": "Peta kampus dua mode",
        "onboardingTransitBody": "Pantau keberangkatan Sydney Metro, kereta, dan bus secara real time dari layar beranda.",
    },
    "it": {
        "onboardingMapTitle": "Mappa del campus a doppia modalità",
        "onboardingTransitBody": "Segui in tempo reale le partenze della metro di Sydney, treni e autobus dalla schermata principale.",
    },
    "ja": {
        "onboardingMapTitle": "キャンパスマップ（2つのモード）",
        "onboardingTransitBody": "ホーム画面から、シドニー・メトロ、電車、バスのリアルタイム発車情報を確認できます。",
    },
    "ko": {
        "onboardingMapTitle": "두 가지 모드 캠퍼스 지도",
        "onboardingTransitBody": "홈 화면에서 시드니 메트로, 기차, 버스의 실시간 출발 정보를 확인하세요.",
    },
    "ms": {
        "onboardingMapTitle": "Peta kampus dwi mod",
        "onboardingTransitBody": "Jejak masa berlepas Sydney Metro, kereta api dan bas secara masa nyata dari skrin utama.",
    },
    "ne": {
        "onboardingMapTitle": "दुई मोडको क्याम्पस नक्सा",
        "onboardingTransitBody": "गृह स्क्रिनबाट सिड्नी मेट्रो, रेल र बसका प्रस्थान समय वास्तविक समयमा ट्र्याक गर्नुहोस्।",
    },
    "nl": {
        "onboardingMapTitle": "Campuskaart met twee weergaven",
        "onboardingTransitBody": "Volg vertrekken van Sydney Metro, treinen en bussen in realtime vanaf het startscherm.",
    },
    "no": {
        "onboardingMapTitle": "Campuskart med to moduser",
        "onboardingTransitBody": "Følg avganger for Sydney Metro, tog og busser i sanntid fra startskjermen.",
    },
    "pl": {
        "onboardingMapTitle": "Mapa kampusu z dwoma trybami",
        "onboardingTransitBody": "Śledź w czasie rzeczywistym odjazdy Sydney Metro, pociągów i autobusów z ekranu głównego.",
    },
    "pt": {
        "onboardingMapTitle": "Mapa do campus em dois modos",
        "onboardingTransitBody": "Acompanhe em tempo real as partidas do Metrô de Sydney, trens e ônibus na tela inicial.",
    },
    "ro": {
        "onboardingMapTitle": "Hartă campus în două moduri",
        "onboardingTransitBody": "Urmăriți în timp real plecările pentru Sydney Metro, trenuri și autobuze de pe ecranul principal.",
    },
    "ru": {
        "onboardingMapTitle": "Карта кампуса в двух режимах",
        "onboardingTransitBody": "Следите за отправлением Sydney Metro, поездов и автобусов в реальном времени с главного экрана.",
    },
    "si": {
        "onboardingMapTitle": "ද්වි-මාදිලි කැම්පස් සිතියම",
        "onboardingTransitBody": "මුල් තිරයෙන් සිඩ්නි මෙට්‍රෝ, දුම්රිය සහ බස් රථ පිටත්වීම් සජීවීව ලුහුබැඳෙන්න.",
        "googleMapTypeSatellite": "චන්ද්‍රිකා",
    },
    "sv": {
        "onboardingMapTitle": "Campuskarta med två lägen",
        "onboardingTransitBody": "Följ avgångar för Sydney Metro, tåg och bussar i realtid från startskärmen.",
    },
    "ta": {
        "onboardingMapTitle": "இரட்டை முறை வளாக வரைபடம்",
        "onboardingTransitBody": "முகப்புத் திரையில் சிட்னி மெட்ரோ, இரயில்கள் மற்றும் பேருந்துகளின் நிகழ்நேர புறப்பாடுகளைக் கண்காணிக்கவும்.",
    },
    "th": {
        "onboardingMapTitle": "แผนที่วิทยาเขตสองโหมด",
        "onboardingTransitBody": "ติดตามเวลาออกของรถไฟใต้ดินซิดนีย์ รถไฟ และรถโดยสารแบบเรียลไทม์จากหน้าจอหลัก",
    },
    "tr": {
        "onboardingMapTitle": "İki modlu kampüs haritası",
        "onboardingTransitBody": "Ana ekrandan Sydney Metro, tren ve otobüs kalkışlarını gerçek zamanlı takip edin.",
    },
    "uk": {
        "onboardingMapTitle": "Карта кампусу у двох режимах",
        "onboardingTransitBody": "Відстежуйте відправлення Sydney Metro, потягів і автобусів у реальному часі з головного екрана.",
    },
    "ur": {
        "onboardingMapTitle": "دو موڈ والا کیمپس نقشہ",
        "onboardingTransitBody": "ہوم اسکرین سے سڈنی میٹرو، ٹرینوں اور بسوں کی روانگیوں کو حقیقی وقت میں ٹریک کریں۔",
    },
    "vi": {
        "onboardingMapTitle": "Bản đồ khuôn viên hai chế độ",
        "onboardingTransitBody": "Theo dõi giờ khởi hành của Sydney Metro, tàu và xe buýt theo thời gian thực từ màn hình chính.",
    },
    "zh": {
        "onboardingMapTitle": "双模式校园地图",
        "onboardingTransitBody": "在主屏幕实时查看悉尼地铁、火车与巴士发车信息。",
    },
}


def main() -> None:
    data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    for locale, keys in PATCHES.items():
        if locale not in data:
            raise SystemExit(f"Missing locale {locale} in JSON")
        for k, v in keys.items():
            if k not in data[locale]:
                raise SystemExit(f"{locale}: missing key {k}")
            data[locale][k] = v
    JSON_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Patched {len(PATCHES)} locales in {JSON_PATH.name}")


if __name__ == "__main__":
    main()
