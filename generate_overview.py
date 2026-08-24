import os

files_to_read = {
    'pubspec.yaml': 'pubspec.yaml',
    'Category Entity': 'lib/features/categories/domain/entities/category_entity.dart',
    'User Entity': 'lib/features/authentication/domain/entities/user_entity.dart',
    'Category Item Widget': 'lib/features/home/presentation/widgets/category_item.dart',
    'Category Card Widget': 'lib/shared/components/category_card.dart',
    'Category Provider': 'lib/features/categories/presentation/providers/category_providers.dart',
    'Product Provider': 'lib/features/products/presentation/providers/product_providers.dart',
    'Login Screen': 'lib/features/authentication/presentation/views/login_screen.dart',
    'Auth Notifier': 'lib/core/providers/auth_provider.dart',
    'Cart Screen': 'lib/features/cart/presentation/views/cart_screen.dart',
    'Cart Notifier': 'lib/features/cart/presentation/providers/cart_notifier.dart',
    'App Localizations': 'lib/l10n/app_localizations.dart',
    'Admin Providers (Crash File)': 'milliy_metr_admin/lib/core/providers/admin_providers.dart',
    'Backend Category Model': 'backend/app/models/category.py',
    'Backend Category Schema': 'backend/app/schemas/category.py',
    'Backend Auth API': 'backend/app/api/endpoints/auth.py',
    'Backend Categories API': 'backend/app/api/endpoints/categories.py',
    'Backend Products API': 'backend/app/api/endpoints/products.py',
    'Backend Config': 'backend/app/core/config.py'
}

output_path = 'C:/Users/rajab/.gemini/antigravity-ide/brain/32fd24c2-2266-4ac2-b32d-b26c0c28e087/codebase_overview.md'

with open(output_path, 'w', encoding='utf-8') as out:
    out.write('# Codebase Overview for Audit\n\n')
    
    out.write('## 1. PROJECT STRUCTURE\n\n')
    out.write('`\n')
    try:
        with open('tree.txt', 'r', encoding='utf-8') as f:
            # only read until first empty line or full content for the root
            content = f.read()
            out.write(content.split('milliy_metr_admin\n├──')[0])
    except Exception as e:
        out.write(str(e))
    out.write('`\n\n')

    out.write('## 2. FILE CONTENTS\n\n')
    for label, filepath in files_to_read.items():
        out.write(f'### {label} ({filepath})\n')
        
        # handle missing files gracefully by checking alternative paths
        if not os.path.exists(filepath):
            # check if it exists with a slightly different path
            if 'category_providers' in filepath:
                filepath = 'lib/features/categories/presentation/providers/category_notifier.dart'
            elif 'auth_provider' in filepath:
                filepath = 'lib/features/authentication/presentation/providers/auth_notifier.dart'
            elif 'user_entity' in filepath:
                filepath = 'lib/features/auth/domain/entities/user_entity.dart'
                if not os.path.exists(filepath):
                    filepath = 'lib/core/models/user.dart'

        if os.path.exists(filepath):
            ext = os.path.splitext(filepath)[1][1:]
            if ext == 'py':
                lang = 'python'
            elif ext == 'dart':
                lang = 'dart'
            elif ext == 'yaml':
                lang = 'yaml'
            else:
                lang = ''
                
            out.write(f'`{lang}\n')
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    out.write(f.read())
            except Exception as e:
                out.write(f'Error reading file: {e}\n')
            out.write('`\n\n')
        else:
            out.write(f'*File not found at {filepath}*\n\n')

print("Artifact written!")
