import asyncio
from app.db.session import AsyncSessionLocal
from app.models.order import Order, OrderItem
from app.models.user import User
from app.models.product import Product
from sqlalchemy import select
import uuid

async def create_test_order():
    async with AsyncSessionLocal() as db:
        user = (await db.execute(select(User).limit(1))).scalar_one_or_none()
        product = (await db.execute(select(Product).limit(1))).scalar_one_or_none()
        
        if not user or not product:
            print('Need user and product')
            return
            
        order = Order(
            id=uuid.uuid4(),
            user_id=user.id,
            order_number='ORD-TEST',
            subtotal=100,
            total=100,
            delivery_address='Test',
            payment_method='cash',
            delivery_method='delivery'
        )
        db.add(order)
        await db.flush()
        
        item = OrderItem(
            id=uuid.uuid4(),
            order_id=order.id,
            product_id=product.id,
            quantity=1,
            price_at_time=100
        )
        db.add(item)
        await db.commit()
        print('Order created')

asyncio.run(create_test_order())
