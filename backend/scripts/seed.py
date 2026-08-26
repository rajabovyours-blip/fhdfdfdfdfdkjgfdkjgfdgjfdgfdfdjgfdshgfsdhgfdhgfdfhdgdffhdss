import asyncio
import sys
import os

# Add backend dir to python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select
from app.core.config import settings
from app.auth.security import get_password_hash
from app.models.user import User, RoleEnum
from app.models.category import Category
from app.models.product import Product
from app.models.extras import Banner
from app.db.base_class import Base

async def seed():
    engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI)
    AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with engine.begin() as conn:
        print("Creating tables (development only)...")
        await conn.run_sync(Base.metadata.create_all)
        
    async with AsyncSessionLocal() as db:
        print("Checking if seed data exists...")
        result = await db.execute(select(User).where(User.phone == "+998901234567"))
        if result.scalar_one_or_none():
            print("Seed data already exists. Exiting.")
            return

        print("Creating admin user...")
        admin = User(
            full_name="Admin User",
            phone="+998901234567",
            hashed_password=get_password_hash("admin123"),
            role=RoleEnum.ADMIN
        )
        db.add(admin)
        
        print("Creating 61 standard categories...")
        categories = []
        for i in range(1, 62):
            cat = Category(
                name={"uz": f"Kategoriya {i}", "ru": f"Категория {i}", "en": f"Category {i}"},
                description={"uz": f"Tavsif {i}", "ru": f"Описание {i}", "en": f"Description {i}"},
                icon_url=f"assets/images/categories/cat-{i}.webp",
                is_featured=(i <= 8)
            )
            db.add(cat)
            categories.append(cat)
            
        await db.commit() # Commit to get IDs
        
        print("Creating products...")
        prod1 = Product(
            name={"uz": "Smartfon iPhone 15", "ru": "Смартфон iPhone 15", "en": "iPhone 15 Smartphone"},
            description={"uz": "Zo'r telefon", "ru": "Отличный телефон", "en": "Great phone"},
            price=12000000.0,
            category_id=categories[0].id,
            stock=10
        )
        db.add(prod1)
        
        print("Creating banner...")
        banner = Banner(
            title="Yozgi chegirmalar!",
            image_url="https://example.com/banner.png",
        )
        db.add(banner)
        
        await db.commit()
        print("Seed data creation complete!")

if __name__ == "__main__":
    asyncio.run(seed())
