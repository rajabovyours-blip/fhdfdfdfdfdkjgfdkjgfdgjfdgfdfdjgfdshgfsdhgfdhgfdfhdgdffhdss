import json

with open('lib/l10n/app_uz.arb', encoding='utf-8') as f:
    uz = json.load(f)
with open('lib/l10n/app_ru.arb', encoding='utf-8') as f:
    ru = json.load(f)

uz_keys = set([k for k in uz.keys() if not k.startswith('@')])
ru_keys = set([k for k in ru.keys() if not k.startswith('@')])

missing_in_ru = uz_keys - ru_keys
print('Missing in RU:', missing_in_ru)
