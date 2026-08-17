import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from app.core.config import settings
from app.db.base_class import Base

# Import the correct models used by the endpoints
from app.models.user import User
from app.models.address import Address
from app.models.cart import CartItem
from app.models.category import Category
from app.models.order import Order, OrderItem
from app.models.product import Product
from app.models.review import Review

async def create():
    engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    print("Database recreated correctly based on user.py schema.")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(create())
