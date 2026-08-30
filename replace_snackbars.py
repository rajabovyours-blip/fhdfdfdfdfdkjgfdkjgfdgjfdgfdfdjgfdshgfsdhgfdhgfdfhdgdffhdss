import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    modified = False
    
    # 1. danger / error
    pattern_error = r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*context\.colors\.danger,\s*\),\s*\);"
    new_content, count = re.subn(pattern_error, r"AppSnackBar.showError(context, \1);", content)
    if count > 0:
        modified = True
        content = new_content
        
    # 2. primary / success
    pattern_success = r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(([^)]+)\),\s*backgroundColor:\s*context\.colors\.primary(?:\.withOpacity\([^\)]+\)|\.withValues\([^)]+\))?,\s*(?:duration:\s*[^,]+,\s*)?\),\s*\);"
    new_content, count = re.subn(pattern_success, r"AppSnackBar.showSuccess(context, \1);", content)
    if count > 0:
        modified = True
        content = new_content

    if modified:
        if "AppSnackBar" not in content and "app_snackbar.dart" not in content:
            content = "import 'package:milliy_metr/shared/widgets/app_snackbar.dart';\n" + content
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
