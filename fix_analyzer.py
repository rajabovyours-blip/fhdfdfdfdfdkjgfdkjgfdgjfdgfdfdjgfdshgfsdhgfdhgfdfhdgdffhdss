import os
import re

# 1. order_history_screen.dart
file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\orders\presentation\views\order_history_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove _buildStatusBadge and _showCancelDialog
badge_regex = re.compile(r'  Widget _buildStatusBadge\(.*?\n  }', re.DOTALL)
content = re.sub(badge_regex, '', content)

dialog_regex = re.compile(r'  void _showCancelDialog\(.*?\n  }', re.DOTALL)
content = re.sub(dialog_regex, '', content)

# Fix single quotes
content = content.replace('"Bekor qilingan"', "'Bekor qilingan'")
content = content.replace('"All"', "'All'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 2. home_notifier.dart
file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\home\presentation\providers\home_notifier.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('"home_data"', "'home_data'")
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 3. personal_information_screen.dart - missing await
file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\profile\presentation\views\personal_information_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('PreferencesManager.setString(', 'await PreferencesManager.setString(')
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 4. security_privacy_screen.dart - single quotes
file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\profile\presentation\views\security_privacy_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('"SMS Tasdiqlash"', "'SMS Tasdiqlash'")
content = content.replace('"Ikki bosqichli autentifikatsiyani yoqish uchun telefon raqamingizga SMS kod yuboriladi. Davom etishni xohlaysizmi?"', "'Ikki bosqichli autentifikatsiyani yoqish uchun telefon raqamingizga SMS kod yuboriladi. Davom etishni xohlaysizmi?'")
content = content.replace('"Bekor qilish"', "'Bekor qilish'")
content = content.replace('"Davom etish"', "'Davom etish'")
content = content.replace('"Ikki bosqichli autentifikatsiya yoqildi"', "'Ikki bosqichli autentifikatsiya yoqildi'")
content = content.replace('"Ikki bosqichli autentifikatsiya o\'chirildi"', "'Ikki bosqichli autentifikatsiya o\\'chirildi'")
content = content.replace('"Ma\'lumotlar maxfiyligi"', "'Ma\\'lumotlar maxfiyligi'")
content = content.replace('"Xatolik hisobotlarini yuborish"', "'Xatolik hisobotlarini yuborish'")
content = content.replace('"Ilovani yaxshilash uchun anonim xatolik ma\'lumotlarini yuborish."', "'Ilovani yaxshilash uchun anonim xatolik ma\\'lumotlarini yuborish.'")
content = content.replace('"Reklama profilini yaratish"', "'Reklama profilini yaratish'")
content = content.replace('"Sizga moslashtirilgan reklamalarni ko\'rsatish uchun."', "'Sizga moslashtirilgan reklamalarni ko\\'rsatish uchun.'")
content = content.replace('"Saqlash"', "'Saqlash'")
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 5. my_reviews_screen.dart - single quotes
file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\profile\presentation\views\my_reviews_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('"Siz hali sharh qoldirmadingiz"', "'Siz hali sharh qoldirmadingiz'")
content = content.replace('"Xarid qilish"', "'Xarid qilish'")
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 6. search_screen.dart - single quotes
file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\search\presentation\views\search_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('"-1"', "'-1'")
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# Delete test files with prints
try:
    os.remove(r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\test_parser.dart')
except: pass
try:
    os.remove(r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\test_share.dart')
except: pass
print("Fixed analyzer issues")
