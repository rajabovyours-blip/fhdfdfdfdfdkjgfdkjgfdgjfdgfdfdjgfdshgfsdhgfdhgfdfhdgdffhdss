import httpx
import uuid
import asyncio

BASE_URL = "http://127.0.0.1:8000/api/v1"

async def run_tests():
    async with httpx.AsyncClient() as client:
        print("=== E2E Integration Tests ===")

        # 1. AUTHENTICATION
        email = f"test_{uuid.uuid4().hex[:6]}@example.com"
        password = "securepassword"
        
        phone = f"+1{uuid.uuid4().int % 10000000000:010d}"
        print("\nTesting Registration...")
        res = await client.post(f"{BASE_URL}/auth/register", json={
            "name": "John Doe",
            "email": email,
            "password": password,
            "phone": phone
        })
        print(f"Register status: {res.status_code}")
        assert res.status_code == 200

        print("\nTesting Login...")
        res = await client.post(f"{BASE_URL}/auth/login", json={
            "email": email,
            "password": password
        })
        print(f"Login status: {res.status_code}")
        assert res.status_code == 200
        token_data = res.json()["data"]
        access_token = token_data["access_token"]

        headers = {"Authorization": f"Bearer {access_token}"}

        print("\nTesting /auth/me...")
        res = await client.get(f"{BASE_URL}/auth/me", headers=headers)
        print(f"Me status: {res.status_code}")
        assert res.status_code == 200
        
        # 2. MARKETPLACE
        print("\nTesting /home/banners...")
        res = await client.get(f"{BASE_URL}/home/banners")
        print(f"Banners status: {res.status_code}")
        assert res.status_code == 200

        print("\nTesting /categories...")
        res = await client.get(f"{BASE_URL}/categories")
        print(f"Categories status: {res.status_code}")
        assert res.status_code == 200
        
        # Products / Marketplace Test
        print("\nTesting /products...")
        res = await client.get(f"{BASE_URL}/products")
        print(f"Products status: {res.status_code}")
        assert res.status_code == 200
        products = res.json()["data"]
        assert len(products) > 0, "No products found in DB. Seed failed?"
        
        product_id = products[0]["id"]
        
        # Cart E2E Test
        print("\nAdding to Cart...")
        res = await client.post(f"{BASE_URL}/cart/add", json={
            "product_id": product_id,
            "quantity": 2
        }, headers=headers)
        print(f"Add to Cart status: {res.status_code}")
        assert res.status_code == 200
        
        print("\nFetching Cart...")
        res = await client.get(f"{BASE_URL}/cart", headers=headers)
        print(f"Get Cart status: {res.status_code}")
        assert res.status_code == 200
        cart_items = res.json()["data"]["items"]
        assert len(cart_items) > 0, "Cart is empty after adding item"
        
        # Add Address
        print("\nAdding Address...")
        res = await client.post(f"{BASE_URL}/addresses", json={
            "title": "Home",
            "address_line_1": "Tashkent, Chilonzor 1-2-3",
            "city": "Tashkent",
            "region": "Chilonzor"
        }, headers=headers)
        assert res.status_code == 200
        address_id = res.json()["data"]["id"]

        # Checkout E2E Test
        print("\nTesting Checkout...")
        res = await client.post(f"{BASE_URL}/checkout/order", json={
            "address_id": address_id,
            "payment_method_id": 1
        }, headers=headers)
        print(f"Checkout status: {res.status_code}")
        assert res.status_code == 200
        order_id = res.json()["data"]["id"]
        
        print("\nFetching Orders...")
        res = await client.get(f"{BASE_URL}/orders", headers=headers)
        print(f"Get Orders status: {res.status_code}")
        assert res.status_code == 200
        
        # Admin E2E Test
        # Not easily testable unless we login as Admin, which we can do because seed.py created admin@milliymetr.uz (admin123)
        print("\nLogin as Admin...")
        res = await client.post(f"{BASE_URL}/auth/login", json={
            "email": "admin@milliymetr.uz",
            "password": "admin123"
        })
        print(f"Admin Login status: {res.status_code}")
        assert res.status_code == 200
        admin_token = res.json()["data"]["access_token"]
        admin_headers = {"Authorization": f"Bearer {admin_token}"}
        
        print("\nAdmin Fetch Users...")
        res = await client.get(f"{BASE_URL}/admin/users", headers=admin_headers)
        print(f"Admin Users status: {res.status_code}")
        assert res.status_code == 200

        print("\n=== All E2E Scenarios Passed Successfully ===")

if __name__ == "__main__":
    asyncio.run(run_tests())
