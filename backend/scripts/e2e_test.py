import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, delete
from app.core.config import settings
from app.models.category import Category
from app.models.product import Product
import uuid
import requests
import json

async def run_test():
    engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI)
    AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    test_id = uuid.uuid4()
    
    async with AsyncSessionLocal() as db:
        # Get a category
        cat = await db.execute(select(Category).limit(1))
        category = cat.scalar_one_or_none()
        if not category:
            print("FAIL: No categories in DB")
            return
            
        print("PASS: Categories exist.")
        
        # 1. Admin creates product (Simulated by DB insert)
        test_product = Product(
            id=test_id,
            name={"uz": "E2E Test Product", "ru": "E2E Test Product", "en": "E2E Test Product"},
            description={"uz": "Test Desc", "ru": "Test Desc", "en": "Test Desc"},
            category_id=category.id,
            price=99999,
            stock=100,
            images=["assets/images/placeholder.webp"]
        )
        db.add(test_product)
        await db.commit()
        print("PASS: Product created in DB by Admin.")
        
    # 2. Check API (Customer App simulation)
    res = requests.get("http://127.0.0.1:8000/api/v1/home/featured-products")
    if res.status_code == 200:
        data = res.json().get("data", [])
        found = False
        for p in data:
            if p["id"] == str(test_id):
                found = True
                print("PASS: Product successfully retrieved via Customer API.")
                break
        if not found:
            print("FAIL: Product not found in Customer API.")
    else:
        print(f"FAIL: Customer API error {res.status_code}")
        
    # 3. Clean up
    async with AsyncSessionLocal() as db:
        await db.execute(delete(Product).where(Product.id == test_id))
        await db.commit()
        print("PASS: Product deleted successfully.")

if __name__ == "__main__":
    asyncio.run(run_test())
