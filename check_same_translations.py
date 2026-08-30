import json

with open('lib/l10n/app_uz.arb', encoding='utf-8') as f:
    uz = json.load(f)
with open('lib/l10n/app_ru.arb', encoding='utf-8') as f:
    ru = json.load(f)

same_keys = []
for k in uz.keys():
    if not k.startswith('@') and k in ru:
        if uz[k] == ru[k]:
            same_keys.append((k, uz[k]))

print('Same translations in RU as in UZ:')
for k, v in same_keys:
    print(f'{k}: {v}')
