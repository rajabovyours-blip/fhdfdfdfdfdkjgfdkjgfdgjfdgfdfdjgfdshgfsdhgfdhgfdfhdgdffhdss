import asyncio
from app.db.session import SessionLocal
from app.models.order import Order, OrderItem
from app.schemas.order import OrderModel
from sqlalchemy import select
from sqlalchemy.orm import joinedload

async def main():
    async with SessionLocal() as db:
        result = await db.execute(
            select(Order)
            .options(joinedload(Order.user), joinedload(Order.items).joinedload(OrderItem.product))
        )
        orders = result.unique().scalars().all()
        for o in orders:
            try:
                om = OrderModel.model_validate(o)
                print('Success:', o.id)
            except Exception as e:
                print('Error on', o.id, ':', e)

if __name__ == "__main__":
    asyncio.run(main())
