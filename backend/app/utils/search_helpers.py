"""Qidiruv uchun matn normalizatsiyasi.

TAMOYIL: bu faylda HECH QANDAY qo'lda yozilgan sinonim ro'yxati yo'q
va bo'lmasligi kerak. Sinonimlarni sanab chiqib bo'lmaydi — mijoz
istalgan so'zni yozishi mumkin. Shuning uchun bu yerda faqat
ALGORITM turadi:

  1. Matnni bir ko'rinishga keltirish (registr, apostrof, bo'shliq)
  2. Kirill <-> lotin ikki tomonlama o'girish
  3. Mahsulot uchun yig'ma qidiruv matnini qurish

Mahsulotga xos so'zlar (masalan mijozlar shu tovarni qanday atashi)
admin panelda har bir mahsulotning o'z maydoniga kiritiladi —
kodga emas. Xato yozilgan so'zlar esa bazadagi trigram
o'xshashligi (pg_trgm) orqali topiladi.
"""

import re
import unicodedata

# ── Kirill -> lotin ───────────────────────────────────────────────
CYR_TO_LAT = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo',
    'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
    'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
    'ф': 'f', 'х': 'x', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch',
    'ъ': '', 'ы': 'i', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
    # o'zbek kirill harflari
    'қ': 'q', 'ғ': 'g', 'ҳ': 'h', 'ў': 'o', 'ң': 'ng',
}

# ── Lotin -> kirill ──────────────────────────────────────────────
# Uzun birikmalar avval kelishi SHART, aks holda "sh" -> "сh" bo'lib qoladi.
LAT_TO_CYR_PAIRS = [
    ('shch', 'щ'), ('yo', 'ё'), ('yu', 'ю'), ('ya', 'я'),
    ('ch', 'ч'), ('sh', 'ш'), ('ts', 'ц'), ('ng', 'нг'),
    ('a', 'а'), ('b', 'б'), ('v', 'в'), ('g', 'г'), ('d', 'д'),
    ('e', 'е'), ('j', 'ж'), ('z', 'з'), ('i', 'и'), ('y', 'й'),
    ('k', 'к'), ('l', 'л'), ('m', 'м'), ('n', 'н'), ('o', 'о'),
    ('p', 'п'), ('r', 'р'), ('s', 'с'), ('t', 'т'), ('u', 'у'),
    ('f', 'ф'), ('x', 'х'), ('h', 'ҳ'), ('q', 'қ'), ('c', 'к'),
    ('w', 'в'),
]

# Turli apostrof va tirnoq belgilari — hammasi olib tashlanadi.
# O'zbek tilida o' / oʻ / o‘ / o` bir xil o'qiladi, lekin bayt darajasida
# har xil. Normalizatsiyasiz "bo'yoq" va "boyoq" boshqa so'z bo'lib qoladi.
APOSTROPHES = "'\u2019\u2018\u02BB\u02BC\u0060\u00B4\"\u201C\u201D"


def _strip_marks(text: str) -> str:
    """Diakritik belgilarni olib tashlaydi (é -> e)."""
    nfkd = unicodedata.normalize('NFKD', text)
    return ''.join(c for c in nfkd if not unicodedata.combining(c))


def cyr_to_lat(text: str) -> str:
    if not text:
        return ''
    return ''.join(CYR_TO_LAT.get(ch, ch) for ch in text.lower())


def lat_to_cyr(text: str) -> str:
    if not text:
        return ''
    out = text.lower()
    for lat, cyr in LAT_TO_CYR_PAIRS:
        out = out.replace(lat, cyr)
    return out


def normalize(text: str) -> str:
    """Qidiruv uchun matnni yagona ko'rinishga keltiradi."""
    if not text:
        return ''
    t = str(text).lower()
    t = _strip_marks(t)
    t = cyr_to_lat(t)
    for ch in APOSTROPHES:
        t = t.replace(ch, '')
    # harf va raqamdan boshqa hamma narsa bo'shliqqa aylanadi
    t = re.sub(r'[^a-z0-9\u0400-\u04FF]+', ' ', t)
    t = re.sub(r'\s+', ' ', t).strip()
    return t


def query_variants(term: str) -> list[str]:
    """So'rovning turli yozuv variantlarini qaytaradi.

    Sinonim EMAS — faqat bir xil so'zning boshqa alifbodagi ko'rinishi.
    Shu tufayli mijoz kirillda ham, lotinda ham yoza oladi.
    """
    base = normalize(term)
    if not base:
        return []
    variants = {base, normalize(lat_to_cyr(base))}
    return [v for v in variants if v]


def _flatten(value) -> str:
    """JSON (ko'p tilli) yoki oddiy qiymatdan matn yig'adi."""
    if value is None:
        return ''
    if isinstance(value, dict):
        return ' '.join(_flatten(v) for v in value.values())
    if isinstance(value, (list, tuple)):
        return ' '.join(_flatten(v) for v in value)
    return str(value)


def build_search_text(product, category_name=None) -> str:
    """Mahsulot uchun yig'ma qidiruv matnini quradi.

    Ichiga kiradi: barcha tillardagi nomi, tavsifi, brendi, SKU,
    kategoriya nomi va admin kiritgan qidiruv so'zlari. Har biri
    HAM lotin, HAM kirill ko'rinishida yoziladi — shuning uchun
    mijoz qaysi alifboda yozishidan qat'i nazar topiladi.
    """
    parts = [
        _flatten(getattr(product, 'name', None)),
        _flatten(getattr(product, 'brand', None)),
        _flatten(getattr(product, 'sku', None)),
        _flatten(getattr(product, 'unit', None)),
        _flatten(getattr(product, 'search_keywords', None)),
        _flatten(category_name),
    ]
    # Tavsif uzun bo'ladi — faqat boshini olamiz, indeks shishmasin
    desc = _flatten(getattr(product, 'description', None))
    if desc:
        parts.append(desc[:400])

    raw = ' '.join(p for p in parts if p)
    lat = normalize(raw)
    cyr = normalize(lat_to_cyr(lat))
    return f'{lat} {cyr}'.strip()


# ── Eskicha nomlar (mos kelishi uchun saqlangan) ──────────────────

def transliterate(text: str) -> str:
    return cyr_to_lat(text)


def normalize_search_term(term: str) -> str:
    return normalize(term)
