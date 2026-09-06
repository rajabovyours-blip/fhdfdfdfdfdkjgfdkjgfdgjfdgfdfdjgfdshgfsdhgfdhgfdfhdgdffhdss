import json, os, subprocess

with open('.dart_tool/package_config.json', 'r') as f:
    packages = json.load(f)['packages']

for pkg in packages:
    uri = pkg['rootUri']
    if uri.startswith('file:///'):
        path = os.path.normpath(uri[8:])
        cmd = f'findstr /S /M "toARGB32" "{path}\\*.dart"'
        try:
            res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if res.stdout:
                print(f'FOUND in {pkg["name"]}:\n{res.stdout.strip()}')
        except Exception as e:
            pass
