import re

file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\home\presentation\widgets\home_header.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
if 'flutter_riverpod' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:milliy_metr/core/providers/location_provider.dart';\nimport 'package:milliy_metr/core/constants/uzbekistan_regions.dart';")

content = content.replace('class HomeHeader extends StatelessWidget {', 'class HomeHeader extends ConsumerWidget {')
content = content.replace('Widget build(BuildContext context) {', 'Widget build(BuildContext context, WidgetRef ref) {\n    final locationState = ref.watch(locationProvider);\n')

location_widget = '''
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // Open modal sheet for manual selection or trigger GPS
              ref.read(locationProvider.notifier).determineLocation();
            },
            child: Row(
              children: [
                Icon(Icons.location_on, color: context.colors.primary, size: 20),
                const SizedBox(width: 4),
                if (locationState.isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Expanded(
                    child: Text(
                      locationState.district != null && locationState.region != null
                          ? ', '
                          : 'Manzilni aniqlash',
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: context.colors.textMedium, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),'''

# insert before '// Search Bar'
content = content.replace('          const SizedBox(height: 16);\n          // Search Bar', location_widget + '\n          // Search Bar')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
