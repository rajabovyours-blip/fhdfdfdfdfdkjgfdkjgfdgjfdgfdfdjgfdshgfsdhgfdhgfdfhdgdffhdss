import json
import os

paths = {
    'en': 'lib/l10n/app_en.arb',
    'uz': 'lib/l10n/app_uz.arb',
    'ru': 'lib/l10n/app_ru.arb'
}

data = {
    'en': {
        'discountsChip': 'Discounts',
        'expressDeliveryChip': 'Fast Delivery',
        'directFactoryChip': 'Direct from Factory',
        'popularChip': 'Popular',
        'servicesChip': 'Master Services',
        'qualityGuaranteeBadge': '100% Quality Guarantee',
        'fastDeliveryBadge': 'Express Shipping',
        'securePaymentBadge': 'Secure Payment',
        'orderStatusAll': 'All',
        'orderStatusPending': 'Pending',
        'orderStatusConfirmed': 'Confirmed',
        'orderStatusProcessing': 'Processing',
        'orderStatusDelivered': 'Delivered',
        'orderStatusCancelled': 'Cancelled'
    },
    'uz': {
        'discountsChip': 'Aksiyalar',
        'expressDeliveryChip': 'Tezkor yetkazish',
        'directFactoryChip': 'To\'g\'ridan-to\'g\'ri zavoddan',
        'popularChip': 'Ommabop',
        'servicesChip': 'Usta xizmati',
        'qualityGuaranteeBadge': '100% Sifat kafolati',
        'fastDeliveryBadge': 'Tezkor yetkazib berish',
        'securePaymentBadge': 'Xavfsiz to\'lov',
        'orderStatusAll': 'Barchasi',
        'orderStatusPending': 'Kutilmoqda',
        'orderStatusConfirmed': 'Tasdiqlangan',
        'orderStatusProcessing': 'Jarayonda',
        'orderStatusDelivered': 'Yetkazildi',
        'orderStatusCancelled': 'Bekor qilingan'
    },
    'ru': {
        'discountsChip': 'Скидки',
        'expressDeliveryChip': 'Быстрая доставка',
        'directFactoryChip': 'Напрямую с завода',
        'popularChip': 'Популярное',
        'servicesChip': 'Услуги мастеров',
        'qualityGuaranteeBadge': '100% Гарантия качества',
        'fastDeliveryBadge': 'Быстрая доставка',
        'securePaymentBadge': 'Безопасная оплата',
        'orderStatusAll': 'Все',
        'orderStatusPending': 'В ожидании',
        'orderStatusConfirmed': 'Подтвержден',
        'orderStatusProcessing': 'В обработке',
        'orderStatusDelivered': 'Доставлен',
        'orderStatusCancelled': 'Отменен'
    }
}

for lang, path in paths.items():
    with open(path, 'r', encoding='utf-8') as f:
        arb = json.load(f)
    arb.update(data[lang])
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(arb, f, ensure_ascii=False, indent=2)
print("Done")
