with open('dart_categories.txt', 'r', encoding='utf-8') as f:
    hardcoded = f.read().replace('\ufeff', '') # remove BOM if present

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re
# Replace the getCategories body with hardcoded return
pattern = r'  Future<Either<Failure, List<CategoryEntity>>> getCategories\(\{[\s\S]*?\} async \{[\s\S]*?  \}'
replacement = """  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  }) async {
    return Right(_hardcodedCategories);
  }

""" + hardcoded

content = re.sub(pattern, replacement, content)

# Need to add LocalizedString import if not present
if 'import \'package:milliy_metr/core/localization/localized_string.dart\';' not in content:
    content = content.replace("import 'package:milliy_metr/core/errors/failures.dart';", "import 'package:milliy_metr/core/errors/failures.dart';\nimport 'package:milliy_metr/core/localization/localized_string.dart';")

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'w', encoding='utf-8') as f:
    f.write(content)
