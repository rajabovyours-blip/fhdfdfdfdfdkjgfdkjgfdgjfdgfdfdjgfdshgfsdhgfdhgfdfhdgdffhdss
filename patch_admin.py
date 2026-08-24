with open('admin_categories_provider.dart', 'r', encoding='utf-8') as f:
    new_code = f.read().replace('import \'package:flutter_riverpod/flutter_riverpod.dart\';\n\n', '')

with open('milliy_metr_admin/lib/core/providers/admin_providers.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re
pattern = r'final categoriesProvider = FutureProvider<List<dynamic>>\(\(ref\) async \{[\s\S]*?\}\);'
content = re.sub(pattern, new_code, content)

with open('milliy_metr_admin/lib/core/providers/admin_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)
