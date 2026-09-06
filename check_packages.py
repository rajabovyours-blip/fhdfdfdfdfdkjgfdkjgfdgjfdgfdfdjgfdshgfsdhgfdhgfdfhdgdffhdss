import urllib.request, tarfile, io, json

packages = [
    'google_sign_in_web', 'url_launcher_web', 'shared_preferences_web', 
    'image_picker_for_web', 'flutter_svg', 'sign_in_with_apple_web', 'geolocator_web', 'local_auth_web'
]

for p in packages:
    try:
        url = f'https://pub.dev/api/packages/{p}'
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            latest_version = data['latest']['version']
            archive_url = data['latest']['archive_url']
            print(f'Fetching {p} {latest_version}...')
            with urllib.request.urlopen(archive_url) as arc_resp:
                tar = tarfile.open(fileobj=io.BytesIO(arc_resp.read()), mode='r:gz')
                for member in tar.getmembers():
                    if member.name.endswith('.dart'):
                        f = tar.extractfile(member)
                        if f:
                            content = f.read().decode('utf-8', errors='ignore')
                            if 'toARGB32' in content:
                                print(f'FOUND toARGB32 in {p}/{member.name}')
    except Exception as e:
        print(f'Error on {p}: {e}')
