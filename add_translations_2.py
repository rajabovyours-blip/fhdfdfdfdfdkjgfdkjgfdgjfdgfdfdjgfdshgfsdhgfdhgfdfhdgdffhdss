import json
import os

keys = {
    'noAddressesSaved': {
        'uz': "Sizda hozircha manzillar yo'q",
        'ru': "У вас пока нет сохраненных адресов",
        'en': "You don't have any saved addresses yet"
    },
    'pleaseSelectRegionDistrict': {
        'uz': "Iltimos, viloyat va tumanni tanlang",
        'ru': "Пожалуйста, выберите область и район",
        'en': "Please select a region and district"
    }
}

for lang in ['uz', 'ru', 'en']:
    path = f'lib/l10n/app_{lang}.arb'
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for k, v in keys.items():
        data[k] = v[lang]
        
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Translations added successfully.")
