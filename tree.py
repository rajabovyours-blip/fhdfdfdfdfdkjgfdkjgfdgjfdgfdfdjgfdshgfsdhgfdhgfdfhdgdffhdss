import os

def generate_tree(dir_path, prefix='', depth=0, max_depth=3):
    if depth > max_depth:
        return ''
    
    ignore_dirs = {'build', '.dart_tool', '.git', '__pycache__', 'venv', '.venv', 'windows', 'macos', 'linux', 'web', 'ios', 'android', 'node_modules'}
    
    try:
        entries = sorted([e for e in os.listdir(dir_path) if e not in ignore_dirs])
    except PermissionError:
        return ''
    except FileNotFoundError:
        return ''
    
    tree_str = ''
    for i, entry in enumerate(entries):
        path = os.path.join(dir_path, entry)
        is_last = (i == len(entries) - 1)
        
        connector = '└── ' if is_last else '├── '
        tree_str += f'{prefix}{connector}{entry}\n'
        
        if os.path.isdir(path):
            extension = '    ' if is_last else '│   '
            tree_str += generate_tree(path, prefix + extension, depth + 1, max_depth)
            
    return tree_str

with open('tree.txt', 'w', encoding='utf-8') as f:
    for project in ['.', 'milliy_metr_admin', '../backend']:
        f.write(f'{project}\n')
        f.write(generate_tree(project))
        f.write('\n')
