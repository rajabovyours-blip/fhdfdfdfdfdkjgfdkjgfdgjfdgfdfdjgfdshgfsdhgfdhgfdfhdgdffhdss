from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func
from app.models.users import User, Role
from app.models.order import Order
from app.models.category import Category
from app.models.product import Product
from app.schemas.marketplace import ProductCreate
from app.core.exceptions import AppError
import uuid

class AdminService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_dashboard(self):
        users_count = await self.db.scalar(select(func.count(User.id)))
        orders_count = await self.db.scalar(select(func.count(Order.id)))
        total_revenue = await self.db.scalar(select(func.sum(Order.total_amount))) or 0.0
        products_count = await self.db.scalar(select(func.count(Product.id)))

        return {
            "total_users": users_count,
            "total_orders": orders_count,
            "total_revenue": total_revenue
        }

    async def get_users(self):
        result = await self.db.execute(select(User).order_by(User.created_at.desc()))
        return result.scalars().all()

    async def create_product(self, data: ProductCreate, created_by_id: uuid.UUID):
        # Verify category exists
        cat_result = await self.db.execute(select(Category).filter(Category.id == data.category_id))
        if not cat_result.scalars().first():
            raise AppError("Category not found", code="NOT_FOUND", status_code=404)

        new_product = Product(
            category_id=data.category_id,
            name={"uz": data.name_uz, "ru": data.name_ru, "en": data.name_en},
            description={"uz": data.description_uz or "", "ru": data.description_ru or "", "en": data.description_en or ""},
            price=data.price,
            old_price=data.old_price,
            stock=data.stock,
            stock_status="in_stock" if data.stock > 0 else "out_of_stock",
            currency="UZS",
            unit="pcs",
            has_delivery=data.has_delivery,
        )
        self.db.add(new_product)
        await self.db.commit()
        await self.db.refresh(new_product)
        return new_product

    async def update_product(self, product_id: uuid.UUID, data: ProductCreate):
        result = await self.db.execute(select(Product).filter(Product.id == product_id))
        product = result.scalars().first()
        if not product:
            raise AppError("Product not found", code="NOT_FOUND", status_code=404)

        product.name = {"uz": data.name_uz, "ru": data.name_ru, "en": data.name_en}
        product.description = {"uz": data.description_uz or "", "ru": data.description_ru or "", "en": data.description_en or ""}
        product.price = data.price
        product.old_price = data.old_price
        product.stock = data.stock
        product.category_id = data.category_id
        product.stock_status = "in_stock" if data.stock > 0 else "out_of_stock"
        product.has_delivery = data.has_delivery

        await self.db.commit()
        await self.db.refresh(product)
        return product

    async def delete_product(self, product_id: uuid.UUID):
        from sqlalchemy.exc import IntegrityError
        result = await self.db.execute(select(Product).filter(Product.id == product_id))
        product = result.scalars().first()
        if not product:
            raise AppError("Product not found", code="NOT_FOUND", status_code=404)

        try:
            await self.db.delete(product)
            await self.db.commit()
        except IntegrityError:
            await self.db.rollback()
            raise AppError(
                "Bu mahsulot buyurtmalar yoki savatchalarda mavjud bo'lganligi sababli o'chirib bo'lmaydi. Iltimos, o'rniga zaxirani (stock) 0 qilib qo'ying.", 
                code="FOREIGN_KEY_VIOLATION", 
                status_code=400
            )
