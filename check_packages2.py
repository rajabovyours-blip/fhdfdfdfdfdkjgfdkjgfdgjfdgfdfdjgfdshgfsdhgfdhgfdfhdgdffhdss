import urllib.request, tarfile, io, json

packages = [
    'cached_network_image',
    'shimmer',
    'responsive_builder',
    'logger',
    'permission_handler',
    'image_picker',
    'file_picker',
    'connectivity_plus',
    'internet_connection_checker',
    'uuid',
    'url_launcher',
    'geolocator',
    'geocoding',
    'local_auth',
    'google_fonts',
    'share_plus',
    'font_awesome_flutter',
    'google_sign_in',
    'sign_in_with_apple',
    'flutter_dotenv',
    'intl',
    'shared_preferences',
    'flutter_secure_storage',
    'hive_flutter',
    'hive',
    'json_annotation',
    'freezed_annotation'
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
