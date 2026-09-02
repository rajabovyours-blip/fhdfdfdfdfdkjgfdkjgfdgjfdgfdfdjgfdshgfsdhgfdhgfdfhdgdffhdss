import requests

BASE_URL = 'https://milliymetr-backend.onrender.com/api/v1'

def test_login():
    print("Testing Live API login...")
    data = {
        "username": "manga_qaralarin",
        "password": "achika1337"
    }
    resp = requests.post(f"{BASE_URL}/auth/admin-login", data=data)
    print(f"Login Status Code: {resp.status_code}")
    if resp.status_code != 200:
        return
        
    token = resp.json()["data"]["access_token"]
    
    headers = {"Authorization": f"Bearer {token}"}
    me_resp = requests.get(f"{BASE_URL}/auth/me", headers=headers)
    print(f"Me Status Code: {me_resp.status_code}")
    print(f"Me Response: {me_resp.text}")

if __name__ == '__main__':
    test_login()
