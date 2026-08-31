import requests
import sys

BASE_URL = "http://127.0.0.1:8001/api/v1"

def print_result(name, passed, msg="", res=None):
    status = "PASS" if passed else "FAIL"
    print(f"{status} | {name} {f'- {msg}' if msg else ''}")
    if not passed:
        if res is not None:
            print("Response:", res.text)
        sys.exit(1)

def main():
    print("Starting Backend Verification...\n")

    # 1. Test invalid login
    res = requests.post(f"{BASE_URL}/auth/admin-login", data={
        "username": "manga_qaralarin",
        "password": "wrongpassword"
    })
    print_result("Invalid login", res.status_code in [400, 401], f"Status: {res.status_code}", res)

    # 2. Test missing credentials
    res = requests.post(f"{BASE_URL}/auth/admin-login", data={
        "username": "manga_qaralarin"
    })
    print_result("Missing credentials", res.status_code == 422, f"Status: {res.status_code}", res)

    # 3. Test valid login
    res = requests.post(f"{BASE_URL}/auth/admin-login", data={
        "username": "manga_qaralarin",
        "password": "achika1337"
    })
    print_result("Valid OWNER login", res.status_code == 200, f"Status: {res.status_code}", res)
    data = res.json()
    token = data.get("data", {}).get("access_token")
    print_result("JWT Returned", token is not None)

    headers = {"Authorization": f"Bearer {token}"}

    # 4. Test protected endpoint without token
    res = requests.get(f"{BASE_URL}/admin/users/")
    print_result("Protected endpoint w/o token", res.status_code in [401, 403], f"Status: {res.status_code}")

    # 5. Test protected endpoint with token
    res = requests.get(f"{BASE_URL}/admin/users/", headers=headers)
    print_result("Protected endpoint with token", res.status_code == 200, f"Status: {res.status_code}")

    # 6. Administrator management
    res = requests.post(f"{BASE_URL}/admin/users/", headers=headers, json={
        "username": "testadmin2",
        "full_name": "Test Admin",
        "password": "password123",
        "role": "ADMIN"
    })
    print_result("Create Administrator", res.status_code in [200, 201], f"Status: {res.status_code}")
    admin_data = res.json().get("data", {})
    admin_id = admin_data.get("id")

    res = requests.patch(f"{BASE_URL}/admin/users/{admin_id}/status", headers=headers, json={
        "is_active": False
    })
    print_result("Deactivate Administrator", res.status_code == 200, f"Status: {res.status_code}")
    
    print("\nBackend Authentication tests passed successfully!")

if __name__ == "__main__":
    main()
