import codecs

lines = codecs.open('categories_list.txt', 'r', 'utf-16le').readlines()
dart_code = '  static final List<CategoryEntity> _hardcodedCategories = [\n'

for line in lines:
    if not line.strip(): continue
    parts = line.strip().split('|')
    if len(parts) == 2:
        cat_id, name = parts
        name = name.replace("'", "\\'")
        dart_code += f"    const CategoryEntity(id: '{cat_id}', name: LocalizedString(uz: '{name}', ru: '{name}', en: '{name}'), imageUrl: 'assets/images/categories/{cat_id}.webp'),\n"

dart_code += '  ];\n'

with open('dart_categories.txt', 'w', encoding='utf-8') as f:
    f.write(dart_code)
