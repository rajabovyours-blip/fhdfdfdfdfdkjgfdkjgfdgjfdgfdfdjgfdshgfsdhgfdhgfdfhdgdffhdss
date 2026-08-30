"""
COMPREHENSIVE PRODUCTION E2E VERIFICATION
Tests all critical flows: Categories, Products, Admin Auth, Security, Excel Import
"""
import asyncio
import uuid
import requests
import io
import json
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, delete
import sys
sys.path.insert(0, '.')
from app.core.config import settings
from app.models.user import User, RoleEnum
import jwt as pyjwt

engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

BASE_URL = "http://127.0.0.1:8000/api/v1"

def create_token(user_id):
    expire = datetime.now(timezone.utc) + timedelta(minutes=60)
    return pyjwt.encode({"exp": expire, "type": "access", "sub": str(user_id)}, settings.SECRET_KEY, algorithm="HS256")

RESULTS = []

def test(name, passed, detail=""):
    status = "PASS" if passed else "FAIL"
    RESULTS.append((name, status, detail))
    print(f"  [{status}] {name}" + (f" - {detail}" if detail else ""))

async def run():
    admin_id = uuid.uuid4()
    user_id = uuid.uuid4()
    admin_phone = f"+99891{str(uuid.uuid4().int)[:7]}"
    user_phone = f"+99892{str(uuid.uuid4().int)[:7]}"
    
    # Create test users
    async with AsyncSessionLocal() as db:
        db.add(User(id=admin_id, full_name="Test Admin", phone=admin_phone, hashed_password="x", role=RoleEnum.ADMIN))
        db.add(User(id=user_id, full_name="Test User", phone=user_phone, hashed_password="x", role=RoleEnum.USER))
        await db.commit()
    
    admin_token = create_token(admin_id)
    user_token = create_token(user_id)
    admin_h = {"Authorization": f"Bearer {admin_token}"}
    user_h = {"Authorization": f"Bearer {user_token}"}
    
    try:
        # === 1. CATEGORIES ===
        print("\n=== 1. CATEGORIES ===")
        r = requests.get(f"{BASE_URL}/categories")
        cats = r.json().get("data", [])
        test("GET /categories returns 200", r.status_code == 200)
        test("Exactly 61 categories", len(cats) == 61, f"got {len(cats)}")
        
        if cats:
            first = cats[0]
            name = first.get("name", {})
            test("Category has UZ name", bool(name.get("uz")))
            test("Category has RU name", bool(name.get("ru")))
            test("Category has EN name", bool(name.get("en")))
            test("Category has icon_url", bool(first.get("icon_url") or first.get("iconUrl")))
            cat_id = first.get("id")
        else:
            cat_id = None
        
        # === 2. HOME ENDPOINTS ===
        print("\n=== 2. HOME ENDPOINTS ===")
        r = requests.get(f"{BASE_URL}/home/popular-categories")
        test("GET /home/popular-categories returns 200", r.status_code == 200)
        pop_cats = r.json().get("data", [])
        test("Popular categories from DB (not empty)", len(pop_cats) > 0, f"got {len(pop_cats)}")
        
        r = requests.get(f"{BASE_URL}/home/featured-products")
        test("GET /home/featured-products returns 200", r.status_code == 200)
        
        # === 3. SECURITY — USER CANNOT CREATE PRODUCTS ===
        print("\n=== 3. SECURITY ===")
        product_data = {
            "name": "Security Test",
            "description": "Should fail",
            "category_id": cat_id or str(uuid.uuid4()),
            "price": 1000,
            "stock": 10,
        }
        r = requests.post(f"{BASE_URL}/products", json=product_data, headers=user_h)
        test("Normal USER blocked from POST /products", r.status_code == 403, f"got {r.status_code}")
        
        r_noauth = requests.post(f"{BASE_URL}/products", json=product_data)
        test("Unauthenticated blocked from POST /products", r_noauth.status_code == 401, f"got {r_noauth.status_code}")
        
        # === 4. ADMIN CREATE PRODUCT ===
        print("\n=== 4. ADMIN PRODUCT LIFECYCLE ===")
        create_data = {
            "name": {"uz": "Test Sement M500", "ru": "Тест Цемент М500", "en": "Test Cement M500"},
            "description": {"uz": "Test mahsulot", "ru": "Тестовый продукт", "en": "Test product"},
            "category_id": cat_id or str(uuid.uuid4()),
            "price": 85000,
            "unit": "dona",
            "stock": 500,
        }
        r = requests.post(f"{BASE_URL}/products", json=create_data, headers=admin_h)
        test("Admin CREATE product", r.status_code in [200, 201], f"got {r.status_code}")
        
        if r.status_code in [200, 201]:
            product_id = r.json()["data"]["id"]
            
            # GET product by ID
            r = requests.get(f"{BASE_URL}/products/{product_id}")
            test("GET /products/{id} returns product", r.status_code == 200)
            if r.status_code == 200:
                p = r.json()["data"]
                test("Product price preserved", float(p.get("price", 0)) == 85000.0, f"got {p.get('price')}")
                test("Product category preserved", p.get("categoryId") == cat_id)
            
            # UPDATE product
            update_data = dict(create_data)
            update_data["name"] = {"uz": "Yangilangan Sement", "ru": "Обновленный Цемент", "en": "Updated Cement"}
            update_data["price"] = 95000
            r = requests.put(f"{BASE_URL}/products/{product_id}", json=update_data, headers=admin_h)
            test("Admin UPDATE product", r.status_code == 200, f"got {r.status_code}")
            
            if r.status_code == 200:
                up = r.json()["data"]
                test("Updated price propagated", float(up.get("price", 0)) == 95000.0)
            
            # Product appears in GET /products list
            r = requests.get(f"{BASE_URL}/products")
            test("Product appears in GET /products", any(pr["id"] == product_id for pr in r.json().get("data", [])))
            
            # DELETE product
            r = requests.delete(f"{BASE_URL}/products/{product_id}", headers=admin_h)
            test("Admin DELETE product", r.status_code == 200, f"got {r.status_code}")
            
            # Verify deleted
            r = requests.get(f"{BASE_URL}/products/{product_id}")
            test("Deleted product returns 404", r.status_code == 404)
        
        # === 5. EXCEL BULK UPLOAD ===
        print("\n=== 5. EXCEL BULK UPLOAD ===")
        try:
            import pandas as pd
            df = pd.DataFrame([{
                "name_uz": "Excel Test Product",
                "name_ru": "Excel Test Product RU", 
                "name_en": "Excel Test Product EN",
                "price": 50000,
                "stock": 200,
                "unit": "pcs",
                "category_name": "Bricks and Blocks"
            }])
            buf = io.BytesIO()
            df.to_excel(buf, index=False)
            buf.seek(0)
            files = {"file": ("test.xlsx", buf, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")}
            r = requests.post(f"{BASE_URL}/products/bulk-upload", files=files, headers=admin_h)
            test("Excel bulk upload succeeds", r.status_code == 200, f"got {r.status_code}")
            if r.status_code == 200:
                data = r.json().get("data", {})
                test("Excel imported >= 1 product", data.get("imported", 0) >= 1, f"imported={data.get('imported')}")
        except ImportError:
            test("Excel bulk upload", False, "pandas not installed")
        
        # === 6. HEALTH CHECK ===
        print("\n=== 6. HEALTH ===")
        r = requests.get("http://127.0.0.1:8000/health")
        test("Health endpoint returns OK", r.status_code == 200)
        
    finally:
        # Cleanup test data
        async with AsyncSessionLocal() as db:
            await db.execute(delete(User).where(User.id.in_([admin_id, user_id])))
            await db.commit()
    
    # === SUMMARY ===
    print("\n" + "="*60)
    print("PRODUCTION E2E VERIFICATION SUMMARY")
    print("="*60)
    passed = sum(1 for _, s, _ in RESULTS if s == "PASS")
    failed = sum(1 for _, s, _ in RESULTS if s == "FAIL")
    print(f"PASSED: {passed}/{len(RESULTS)}")
    print(f"FAILED: {failed}/{len(RESULTS)}")
    if failed:
        print("\nFailed tests:")
        for name, status, detail in RESULTS:
            if status == "FAIL":
                print(f"  - {name}: {detail}")
    
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(run())
