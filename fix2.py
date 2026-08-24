import os

files = [
    'lib/features/categories/data/repositories/category_repository_impl.dart',
    'milliy_metr_admin/lib/core/providers/admin_providers.dart'
]

replacements = [
    ("'Himoya ko'zoynaklari'", '"Himoya ko\'zoynaklari"'),
    ("'G'isht va Bloklar'", '"G\'isht va Bloklar"'),
    ("'Taxta va Yog'och'", '"Taxta va Yog\'och"'),
    ("'Bo'yoqlar va Laklar'", '"Bo\'yoqlar va Laklar"'),
    ("'Qum va Shag'al'", '"Qum va Shag\'al"'),
    ("'Oyna va Ko'zgular'", '"Oyna va Ko\'zgular"'),
    ("'Montaj ko'pigi'", '"Montaj ko\'pigi"'),
    ("'O'lchov asboblari'", '"O\'lchov asboblari"'),
    ("'Qo'l asboblari'", '"Qo\'l asboblari"'),
    ("'Bolg'alar'", '"Bolg\'alar"'),
    ("'Qumqog'oz (Shkurka)'", '"Qumqog\'oz (Shkurka)"'),
    ("'Qo'lqoplar'", '"Qo\'lqoplar"'),
    ("'Zambilg'achlar (Tachkalar)'", '"Zambilg\'achlar (Tachkalar)"'),
    ("'Qurilish to'rlari'", '"Qurilish to\'rlari"')
]

for file_path in files:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Remove BOM / Zero-width characters
        content = content.replace('\ufeff', '')
        content = content.replace('\u200b', '')

        for bad, good in replacements:
            content = content.replace(bad, good)
            
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

print('Done fixing strings!')
