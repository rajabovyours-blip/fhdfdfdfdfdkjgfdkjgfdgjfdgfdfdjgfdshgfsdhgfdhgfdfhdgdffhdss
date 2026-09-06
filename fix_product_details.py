import sys
import re

file_path = r'lib/features/catalog/presentation/views/product_details_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix isDesktop declaration
old1 = '''        loaded: (product) {
          final bool outOfStock = product.stock <= 0;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;'''
new1 = '''        loaded: (product) {
          final bool outOfStock = product.stock <= 0;
          final isDesktop = MediaQuery.of(context).size.width >= 900;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {'''
if old1 in content:
    content = content.replace(old1, new1, 1)
else:
    print('Failed to find first chunk')

# Fix adding bottom bar to contentWidget
old2 = '''                              const SizedBox(
                                height: 120,
                              ), // Padding to prevent content from hiding behind the sticky bottom bar
                            ],
                          ),
                        );

                        if (isDesktop) {'''
new2 = '''                              if (isDesktop) ...[
                                const SizedBox(height: 24),
                                _buildBottomBar(context, product),
                              ],
                              const SizedBox(
                                height: 120,
                              ), // Padding to prevent content from hiding behind the sticky bottom bar
                            ],
                          ),
                        );

                        if (isDesktop) {'''
if old2 in content:
    content = content.replace(old2, new2, 1)
else:
    print('Failed to find second chunk')

# Fix sticky bottom bar condition
old3 = '''              // Bottom Action Bar (Sticky)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(context, product),
              ),'''
new3 = '''              // Bottom Action Bar (Sticky)
              if (!isDesktop)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomBar(context, product),
                ),'''
if old3 in content:
    content = content.replace(old3, new3, 1)
else:
    print('Failed to find third chunk')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
