import asyncio
import sys
import os

# Add backend dir to python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from app.models.category import Category

async def seed_categories():
    engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI)
    AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    categories_data = [
        {
            "id": "sement",
            "name": {"uz": "Sement va qorishmalar", "ru": "Цемент и смеси", "en": "Cement & Mixes"},
            "icon_url": "assets/icons/cement.svg",
            "is_featured": True
        },
        {
            "id": "gisht",
            "name": {"uz": "G'isht va bloklar", "ru": "Кирпичи и блоки", "en": "Bricks & Blocks"},
            "icon_url": "assets/icons/brick.svg",
            "is_featured": True
        },
        {
            "id": "armatura",
            "name": {"uz": "Armatura va metall", "ru": "Арматура и металл", "en": "Rebar & Metal"},
            "icon_url": "assets/icons/metal.svg",
            "is_featured": True
        },
        {
            "id": "yogoch",
            "name": {"uz": "Qurilish yog'ochlari", "ru": "Пиломатериалы", "en": "Lumber"},
            "icon_url": "assets/icons/wood.svg",
            "is_featured": True
        },
        {
            "id": "tom",
            "name": {"uz": "Tom yopish materiallari", "ru": "Кровельные материалы", "en": "Roofing"},
            "icon_url": "assets/icons/roof.svg",
            "is_featured": True
        },
        {
            "id": "izolyatsiya",
            "name": {"uz": "Issiqlik izolyatsiyasi", "ru": "Теплоизоляция", "en": "Thermal Insulation"},
            "icon_url": "assets/icons/insulation.svg",
            "is_featured": True
        },
        {
            "id": "boyoq",
            "name": {"uz": "Bo'yoq va pardozlash", "ru": "Краски и отделка", "en": "Paints & Finishes"},
            "icon_url": "assets/icons/paint.svg",
            "is_featured": True
        },
        {
            "id": "elektr",
            "name": {"uz": "Elektr jihozlari", "ru": "Электротовары", "en": "Electrical equipment"},
            "icon_url": "assets/icons/electric.svg",
            "is_featured": True
        },
        {
            "id": "santexnika",
            "name": {"uz": "Santexnika", "ru": "Сантехника", "en": "Plumbing"},
            "icon_url": "assets/icons/plumbing.svg",
            "is_featured": True
        },
        {
            "id": "asboblar",
            "name": {"uz": "Qurilish asboblari", "ru": "Строительные инструменты", "en": "Construction Tools"},
            "icon_url": "assets/icons/tools.svg",
            "is_featured": True
        }
    ]

    async with AsyncSessionLocal() as db:
        print("Inserting categories...")
        for cat in categories_data:
            c = Category(
                id=cat["id"],
                name=cat["name"],
                description=cat["name"],
                icon_url=cat["icon_url"],
                is_featured=cat["is_featured"]
            )
            try:
                db.add(c)
                await db.commit()
            except Exception as e:
                await db.rollback()
                print(f"Failed or already exists: {cat['id']}")
        
        print("Done.")

if __name__ == "__main__":
    asyncio.run(seed_categories())
