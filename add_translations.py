import json
import os

keys = {
    'passwordChangedSuccessfully': {
        'uz': "Parol muvaffaqiyatli o'zgartirildi",
        'ru': "Пароль успешно изменен",
        'en': "Password changed successfully"
    },
    'passwordChangeError': {
        'uz': "Xatolik yuz berdi yoxud parol noto'g'ri",
        'ru': "Произошла ошибка или пароль неверен",
        'en': "An error occurred or password is incorrect"
    },
    'biometricError': {
        'uz': "Biometrik xatolik",
        'ru': "Биометрическая ошибка",
        'en': "Biometric error"
    }
}

for lang in ['uz', 'ru', 'en']:
    path = f'lib/l10n/app_{lang}.arb'
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for k, v in keys.items():
        data[k] = v[lang]
        
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Translations added successfully.")
