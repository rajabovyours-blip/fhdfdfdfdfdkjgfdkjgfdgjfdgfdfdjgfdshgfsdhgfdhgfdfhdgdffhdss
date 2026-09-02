import json
import os

files = {
    'uz': 'lib/l10n/app_uz.arb',
    'ru': 'lib/l10n/app_ru.arb',
    'en': 'lib/l10n/app_en.arb'
}

new_strings = {
    'uz': {
        'filterSpecialOffers': 'Maxsus takliflar',
        'filterHasDiscount': 'Chegirma mavjud',
        'filterSmallWholesale': 'Kichik miqdorda sotib olish mumkin',
        'filterCertified': 'Sertifikatlangan',
        'filterHasDelivery': 'Yetkazib berish mavjud',
        'filterUnitLabel': 'O\'lchov birligi',
        'filterRatingLabel': 'Reyting',
        'priceFrom': 'dan',
        'priceTo': 'gacha',
        'unitDona': 'dona',
        'unitKg': 'kg',
        'unitMetr': 'metr',
        'unitKvm': 'kv.m',
        'unitLitr': 'litr',
        'unitKomplekt': 'komplekt',
        'unitM3': 'm3',
        'unitTonna': 'tonna',
        'unitRulon': 'rulon',
        'unitQop': 'qop'
    },
    'ru': {
        'filterSpecialOffers': 'Специальные предложения',
        'filterHasDiscount': 'Со скидкой',
        'filterSmallWholesale': 'Возможен мелкий опт',
        'filterCertified': 'Сертифицирован',
        'filterHasDelivery': 'Есть доставка',
        'filterUnitLabel': 'Единица измерения',
        'filterRatingLabel': 'Рейтинг',
        'priceFrom': 'от',
        'priceTo': 'до',
        'unitDona': 'шт',
        'unitKg': 'кг',
        'unitMetr': 'метр',
        'unitKvm': 'кв.м',
        'unitLitr': 'литр',
        'unitKomplekt': 'комплект',
        'unitM3': 'м3',
        'unitTonna': 'тонна',
        'unitRulon': 'рулон',
        'unitQop': 'мешок'
    },
    'en': {
        'filterSpecialOffers': 'Special offers',
        'filterHasDiscount': 'Has discount',
        'filterSmallWholesale': 'Small wholesale available',
        'filterCertified': 'Certified',
        'filterHasDelivery': 'Delivery available',
        'filterUnitLabel': 'Unit',
        'filterRatingLabel': 'Rating',
        'priceFrom': 'from',
        'priceTo': 'to',
        'unitDona': 'pcs',
        'unitKg': 'kg',
        'unitMetr': 'meter',
        'unitKvm': 'sq.m',
        'unitLitr': 'liter',
        'unitKomplekt': 'set',
        'unitM3': 'm3',
        'unitTonna': 'ton',
        'unitRulon': 'roll',
        'unitQop': 'bag'
    }
}

for lang, filepath in files.items():
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, val in new_strings[lang].items():
        if key not in data:
            data[key] = val
            
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
