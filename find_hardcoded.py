import os
import re

uz_words = ['xato', "yo'q", 'qiling', 'uchun', 'bilan', 'yoki', ' va ', 'haqida', "bo'l", 'to\'lov', 'kirit', 'iltimos', 'ulanishda', 'tarmoqqa', 'toifada', 'ko\'rish', 'qoshish']
found = []

for root, _, files in os.walk('lib'):
    if 'l10n' in root: continue
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                for i, line in enumerate(lines):
                    # basic regex to find string literals
                    strings = re.findall(r"(?:'([^']*)'|\"([^\"]*)\")", line)
                    for s_tuple in strings:
                        s = s_tuple[0] or s_tuple[1]
                        s_lower = s.lower()
                        if any(w in s_lower for w in uz_words):
                            found.append(f"{filepath}:{i+1}: {s}")

print(f"Found {len(found)} hardcoded potential Uzbek strings:")
for f in found:
    print(f)
