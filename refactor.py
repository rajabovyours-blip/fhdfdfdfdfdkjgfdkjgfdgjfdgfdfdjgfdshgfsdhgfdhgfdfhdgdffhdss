import sys

file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\catalog\presentation\views\product_details_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if 'loaded: (product) {' in line:
        start_idx = i
        break

for i in range(start_idx, len(lines)):
    if '        },' in lines[i] and '      ),' in lines[i+1] and '    );' in lines[i+2]:
        end_idx = i
        break

if start_idx != -1 and end_idx != -1:
    loaded_block = lines[start_idx:end_idx+1]
    
    hero_start = -1
    content_start = -1
    content_end = -1
    
    for i, line in enumerate(loaded_block):
        if '// Image Gallery (Hero Section)' in line:
            hero_start = i
        if '// Content' in line:
            content_start = i
        if '// Padding to prevent content from hiding behind the sticky bottom bar' in line:
            content_end = i + 2
            
    hero_lines = loaded_block[hero_start:content_start]
    content_lines = loaded_block[content_start:content_end]
    
    hero_str = ''.join(hero_lines)
    hero_str = hero_str.replace('fit: BoxFit.cover,', 'fit: isDesktop ? BoxFit.contain : BoxFit.cover,')
    hero_str = hero_str.replace('height: MediaQuery.of(context).size.width * 0.6,', 'height: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.6,')
    
    content_str = ''.join(content_lines)
    
    new_loaded_str = '''        loaded: (product) {
          final bool outOfStock = product.stock <= 0;
          
          Widget buildImageGallery(bool isDesktop) {
            return ''' + hero_str.replace('                        ', '            ').strip() + ''';
          }
          
          Widget buildContent(bool isDesktop) {
            return ''' + content_str.replace('                        ', '            ').strip() + ''';
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              
              if (isDesktop) {
                return Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 24, bottom: 120),
                                child: buildImageGallery(isDesktop),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 7,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 24, bottom: 120, right: 24),
                                child: buildContent(isDesktop),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: _buildBottomBar(context, product),
                    ),
                  ],
                );
              }

              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildImageGallery(isDesktop),
                            buildContent(isDesktop),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: _buildBottomBar(context, product),
                  ),
                ],
              );
            },
          );
        },
'''
    new_lines = lines[:start_idx] + [new_loaded_str] + lines[end_idx+1:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print('Refactoring successful')
else:
    print('Could not find loaded block')
