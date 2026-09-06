import json, os, urllib.request

with open('.dart_tool/package_config.json', 'r') as f:
    packages = json.load(f)['packages']

for pkg in packages:
    uri = pkg['rootUri']
    if uri.startswith('file:///'):
        path = uri[8:] # windows path C:/...
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith('.dart'):
                    filepath = os.path.join(root, file)
                    try:
                        with open(filepath, 'r', encoding='utf-8') as df:
                            if 'toARGB32' in df.read():
                                print(f'FOUND in {pkg["name"]}: {filepath}')
                    except Exception as e:
                        pass
