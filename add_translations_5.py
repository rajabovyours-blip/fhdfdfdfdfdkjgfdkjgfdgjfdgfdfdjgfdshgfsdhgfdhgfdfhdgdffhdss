import json

files = {
    'uz': 'lib/l10n/app_uz.arb',
    'ru': 'lib/l10n/app_ru.arb',
    'en': 'lib/l10n/app_en.arb'
}

new_strings = {
    'uz': {
        'calculatorTitle': 'Kalkulyator',
        'calculatorFieldLabel': "Xona / Maydon o'lchami",
        'calculatorReserve': 'Zaxira bilan (+5%):',
        'calculatorAddToCart': "Hisoblangan miqdorni savatga qo'shish",
        'calculatorAddedSnack': "dona savatga qo'shildi",
    },
    'ru': {
        'calculatorTitle': 'Калькулятор',
        'calculatorFieldLabel': 'Размер комнаты / площади',
        'calculatorReserve': 'С запасом (+5%):',
        'calculatorAddToCart': 'Добавить рассчитанное количество в корзину',
        'calculatorAddedSnack': 'шт добавлено в корзину',
    },
    'en': {
        'calculatorTitle': 'Calculator',
        'calculatorFieldLabel': 'Room / Area size',
        'calculatorReserve': 'With reserve (+5%):',
        'calculatorAddToCart': 'Add calculated amount to cart',
        'calculatorAddedSnack': 'pcs added to cart',
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

print("Done")
