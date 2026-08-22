from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.category import Category
from app.models.product import Product
from app.models.user import User, RoleEnum
from app.auth.security import get_password_hash
import uuid

async def seed_data(session: AsyncSession):
    # Check if categories exist
    result = await session.execute(select(Category).limit(1))
    category = result.scalar_one_or_none()
    
    if not category:
        # Create categories
        cat1 = Category(
            name={"uz": "G'isht va Bloklar", "ru": "Кирпичи и Блоки", "en": "Bricks and Blocks"},
            description={"uz": "Qurilish g'ishtlari va bloklari", "ru": "Строительные кирпичи и блоки", "en": "Building bricks and blocks"},
            icon_url="https://images.unsplash.com/photo-1589939705384-5185137a7f0f"
        )
        cat2 = Category(
            name={"uz": "Sement", "ru": "Цемент", "en": "Cement"},
            description={"uz": "Turli markadagi sement", "ru": "Цемент разных марок", "en": "Cement of various grades"},
            icon_url="https://images.unsplash.com/photo-1621501103258-3e4b77ae5573"
        )
        session.add(cat1)
        session.add(cat2)
        await session.flush()

        # Create products
        prod1 = Product(
            name={"uz": "Qizil g'isht (Standart)", "ru": "Красный кирпич (Стандарт)", "en": "Red Brick (Standard)"},
            description={"uz": "Yuqori sifatli pishgan qizil g'isht.", "ru": "Качественный красный кирпич.", "en": "High quality red brick."},
            category_id=cat1.id,
            price=1200.0,
            currency="UZS",
            unit="dona",
            moq=1000,
            stock=5000,
            stockStatus="in_stock",
            rating=4.8,
            reviewCount=120,
            location="Toshkent",
            images="[\"https://images.unsplash.com/photo-1589939705384-5185137a7f0f\"]"
        )
        
        prod2 = Product(
            name={"uz": "Sement M400", "ru": "Цемент М400", "en": "Cement M400"},
            description={"uz": "Qurilish sementi M400, 50kg qopda.", "ru": "Строительный цемент М400, 50кг.", "en": "Construction cement M400, 50kg bag."},
            category_id=cat2.id,
            price=55000.0,
            currency="UZS",
            unit="qop",
            moq=10,
            stock=500,
            stockStatus="in_stock",
            rating=4.9,
            reviewCount=350,
            location="Samarqand",
            images="[\"https://images.unsplash.com/photo-1621501103258-3e4b77ae5573\"]"
        )
        
        session.add(prod1)
        session.add(prod2)
        await session.commit()
        print("Database seeded with mock categories and products!")

    # Check if admin user exists
    result = await session.execute(select(User).where(User.role == RoleEnum.ADMIN).limit(1))
    admin_user = result.scalar_one_or_none()
    
    if not admin_user:
        admin_user = User(
            id=uuid.uuid4(),
            full_name="Super Admin",
            phone="+998990000000",
            email="admin@milliymetr.uz",
            hashed_password=get_password_hash("AdminPassword123!"),
            role=RoleEnum.ADMIN
        )
        session.add(admin_user)
        await session.commit()
        print("Default admin user created: email='admin@milliymetr.uz', password='AdminPassword123!'")
