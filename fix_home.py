import sys

file_path = r'lib/features/home/presentation/views/home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('context.l10n.categoriesSection', 'context.l10n.categories')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
