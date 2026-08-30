import re
import os

replacements = {
    r"lib[\\/]features[\\/]catalog[\\/]presentation[\\/]views[\\/]category_products_screen\.dart": [
        (r'"Bu toifada hozircha mahsulotlar yo\'q"', r'context.l10n.noSuchProductFound'),
        (r'"Boshqa toifalarni ko\'rish"', r'context.l10n.catalog')
    ],
    r"lib[\\/]features[\\/]checkout[\\/]presentation[\\/]views[\\/]address_list_screen\.dart": [
        (r"'Sizda hozircha manzillar yo\'q'", r'context.l10n.noAddressesSaved')
    ],
    r"lib[\\/]features[\\/]checkout[\\/]presentation[\\/]views[\\/]add_address_screen\.dart": [
        (r"'Xatolik yuz berdi'", r'context.l10n.errorOccurred'),
        (r"'Iltimos, viloyat va tumanni tanlang'", r'context.l10n.pleaseSelectRegionDistrict')
    ],
    r"lib[\\/]features[\\/]profile[\\/]presentation[\\/]views[\\/]personal_information_screen\.dart": [
        (r"'Rasm yuklashda xatolik yuz berdi'", r'context.l10n.imageUploadError')
    ],
    r"lib[\\/]features[\\/]profile[\\/]presentation[\\/]views[\\/]security_privacy_screen\.dart": [
        (r"'Biometrik xatolik: \$e'", r"'''${context.l10n.biometricError}: $e'''")
    ]
}

def apply_replacements(filepath, file_replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in file_replacements:
        content = re.sub(old, new, content)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        
for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            for pattern, reps in replacements.items():
                if re.search(pattern, filepath):
                    apply_replacements(filepath, reps)

print("Replaced hardcoded strings.")
