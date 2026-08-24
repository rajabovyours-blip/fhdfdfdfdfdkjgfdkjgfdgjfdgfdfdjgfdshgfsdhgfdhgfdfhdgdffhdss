import re

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r'LocalizedString\(uz:\s*([^\,]+),\s*ru:\s*([^\,]+),\s*en:\s*([^\)]+)\)', text)
for m in matches[:5]:
    print(m)
