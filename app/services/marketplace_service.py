from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from app.models.marketplace import Category, Product, wishlist_table
from app.core.exceptions import AppError
import uuid

class MarketplaceService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_categories(self):
        result = await self.db.execute(
            select(Category)
            .filter(Category.parent_id == None, Category.is_active == True)
            .options(selectinload(Category.subcategories))
        )
        return result.scalars().all()

    async def get_products(self, query: str = None, category_id: uuid.UUID = None, limit: int = 20, offset: int = 0):
        stmt = select(Product).filter(Product.status == "approved").options(
            selectinload(Product.images)
        )
        
        if query:
            stmt = stmt.filter(Product.name.ilike(f"%{query}%"))
        if category_id:
            stmt = stmt.filter(Product.category_id == category_id)
            
        stmt = stmt.limit(limit).offset(offset)
        result = await self.db.execute(stmt)
        return result.scalars().all()

    async def get_product_detail(self, product_id: uuid.UUID):
        result = await self.db.execute(
            select(Product)
            .filter(Product.id == product_id, Product.status == "approved")
            .options(
                selectinload(Product.images)
            )
        )
        product = result.scalars().first()
        if not product:
            raise AppError("Product not found", code="NOT_FOUND", status_code=404)
        return product


    async def add_to_wishlist(self, user_id: uuid.UUID, product_id: uuid.UUID):
        # We manually insert into the association table
        stmt = wishlist_table.insert().values(user_id=user_id, product_id=product_id)
        try:
            await self.db.execute(stmt)
            await self.db.commit()
        except Exception:
            await self.db.rollback()
            raise AppError("Could not add to wishlist or already exists", code="WISHLIST_ERROR")

    async def remove_from_wishlist(self, user_id: uuid.UUID, product_id: uuid.UUID):
        stmt = wishlist_table.delete().where(
            wishlist_table.c.user_id == user_id,
            wishlist_table.c.product_id == product_id
        )
        await self.db.execute(stmt)
        await self.db.commit()

    async def get_wishlist(self, user_id: uuid.UUID):
        # Join product table where product is in wishlist for this user
        stmt = (
            select(Product)
            .join(wishlist_table, wishlist_table.c.product_id == Product.id)
            .filter(wishlist_table.c.user_id == user_id)
            .options(selectinload(Product.images))
        )
        result = await self.db.execute(stmt)
        return result.scalars().all()
