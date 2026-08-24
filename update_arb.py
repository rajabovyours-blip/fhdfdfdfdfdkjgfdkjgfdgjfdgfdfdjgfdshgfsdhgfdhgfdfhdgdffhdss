import json
import os

files = {
    'lib/l10n/app_en.arb': {
        'guestModeTitle': 'Please Log In',
        'guestCartDesc': 'Log in to view and manage your cart.',
        'guestWishlistDesc': 'Log in to view your favorite products.'
    },
    'lib/l10n/app_ru.arb': {
        'guestModeTitle': 'Войдите в систему',
        'guestCartDesc': 'Войдите, чтобы просмотреть корзину.',
        'guestWishlistDesc': 'Войдите, чтобы просмотреть избранные товары.'
    },
    'lib/l10n/app_uz.arb': {
        'guestModeTitle': 'Tizimga kiring',
        'guestCartDesc': 'Savatchani ko\'rish uchun tizimga kiring.',
        'guestWishlistDesc': 'Sevimlilarni ko\'rish uchun tizimga kiring.'
    }
}

for filepath, new_data in files.items():
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        for k, v in new_data.items():
            if k not in data:
                data[k] = v
                
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

print('Arb files updated!')
