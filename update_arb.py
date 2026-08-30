import json
import os

files = ['lib/l10n/app_en.arb', 'lib/l10n/app_ru.arb', 'lib/l10n/app_uz.arb']
additions = {
    'en': {
        'networkError': 'No internet connection or server error.',
        'serverError': 'Server is temporarily down for maintenance. Please try again later.'
    },
    'ru': {
        'networkError': 'Нет подключения к интернету или ошибка сервера.',
        'serverError': 'Сервер временно недоступен для обслуживания. Пожалуйста, повторите попытку позже.'
    },
    'uz': {
        'networkError': 'Internet aloqasi mavjud emas yoki server bilan ulanishda xatolik yuz berdi.',
        'serverError': 'Serverda vaqtinchalik profilaktika. Birozdan so\'ng urinib ko\'ring.'
    }
}

for file in files:
    lang = file.split('_')[1].split('.')[0]
    with open(file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data['networkError'] = additions[lang]['networkError']
    data['serverError'] = additions[lang]['serverError']

    with open(file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated arb files.")
