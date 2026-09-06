import urllib.request
import urllib.parse
import json

data = urllib.parse.urlencode({'username': 'bekzodbek', 'password': 'rajabov'}).encode('utf-8')
req = urllib.request.Request('http://localhost:8000/api/v1/auth/admin-login', data=data)
try:
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode())
        token = res['data']['access_token']
except Exception as e:
    print('Login failed:', e)
    if hasattr(e, 'read'):
        print(e.read().decode())
    exit(1)

req2 = urllib.request.Request('http://localhost:8000/api/v1/orders', headers={'Authorization': 'Bearer ' + token})
try:
    with urllib.request.urlopen(req2) as response:
        print('Orders success!')
except urllib.error.HTTPError as e:
    print('Orders error:', e.code, e.read().decode())
