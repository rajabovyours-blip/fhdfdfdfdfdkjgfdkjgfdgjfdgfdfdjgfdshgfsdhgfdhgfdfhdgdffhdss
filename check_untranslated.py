import json

with open('lib/l10n/app_ru.arb', encoding='utf-8') as f:
    ru = json.load(f)

uz_words = ['xato', 'yo\'q', 'qiling', 'uchun', 'bilan', 'yoki', ' va ', 'haqida', 'bo\'', 'to\'lov', 'kirit', 'iltimos']
bad_keys = []
for k, v in ru.items():
    if isinstance(v, str) and k != '@@locale':
        v_lower = v.lower()
        if any(w in v_lower for w in uz_words) and k not in ['uzcard']:
            bad_keys.append(k)

print('Possible untranslated keys:', bad_keys)
