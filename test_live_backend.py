import requests

BASE_URL = 'https://milliymetr-backend.onrender.com/api/v1'

def test_flow():
    print("1. Testing Login...")
    resp = requests.post(f"{BASE_URL}/auth/admin-login", data={"username": "admin@milliymetr.uz", "password": "admin123"})
    if resp.status_code != 200:
        print(f"Login failed: {resp.status_code} {resp.text}")
        return
    token = resp.json()["access_token"]
    print(f"Token received: {token[:20]}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    print("2. Fetching Categories...")
    cat_resp = requests.get(f"{BASE_URL}/categories")
    if cat_resp.status_code != 200:
        print(f"Failed to fetch categories: {cat_resp.text}")
        return
    categories = cat_resp.json()
    print(f"Found {len(categories)} categories")
    if len(categories) == 0:
        print("No categories found.")
        return
        
    cat_id = categories[0]["id"]
    
    print("3. Creating a product...")
    product_data = {
        "name_uz": "Test Product UZ",
        "name_ru": "Test Product RU",
        "name_en": "Test Product EN",
        "description_uz": "Desc",
        "description_ru": "Desc",
        "description_en": "Desc",
        "price": 15000,
        "stock": 10,
        "is_active": True,
        "category_id": cat_id,
        "images": ["https://example.com/image.jpg"]
    }
    
    prod_resp = requests.post(f"{BASE_URL}/admin/products", json=product_data, headers=headers)
    if prod_resp.status_code != 201 and prod_resp.status_code != 200:
        print(f"Failed to create product: {prod_resp.status_code} {prod_resp.text}")
        return
        
    product = prod_resp.json()
    prod_id = product["id"]
    print(f"Created product {prod_id}")
    
    print("4. Fetching products...")
    get_prod_resp = requests.get(f"{BASE_URL}/products/{prod_id}")
    if get_prod_resp.status_code == 200:
        print("Product retrieved successfully from public endpoint")
    else:
        print(f"Failed to get product: {get_prod_resp.status_code} {get_prod_resp.text}")
        
    print("5. Deleting product...")
    del_resp = requests.delete(f"{BASE_URL}/admin/products/{prod_id}", headers=headers)
    if del_resp.status_code == 200 or del_resp.status_code == 204:
        print("Product deleted successfully")
    else:
        print(f"Failed to delete product: {del_resp.status_code} {del_resp.text}")

if __name__ == '__main__':
    test_flow()
