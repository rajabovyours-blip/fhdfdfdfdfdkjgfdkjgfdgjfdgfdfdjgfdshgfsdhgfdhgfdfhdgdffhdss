import os
import re

files = [
    'lib/features/admin/presentation/views/admin_settings_screen.dart',
    'lib/features/checkout/presentation/widgets/add_card_bottom_sheet.dart',
    'lib/features/notifications/presentation/views/notifications_screen.dart',
    'lib/features/profile/presentation/views/security_privacy_screen.dart'
]

for file in files:
    if os.path.exists(file):
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        content = re.sub(
            r'(ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(l10n\.requiresBackendIntegration\),.*?backgroundColor:\s*context\.colors\.primary,\s*\),\s*\);)',
            r'/* \1 */',
            content,
            flags=re.DOTALL
        )
        
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
