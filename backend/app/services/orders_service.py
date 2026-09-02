from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import update
from sqlalchemy.orm import selectinload
from app.models.cart import Cart, CartItem
from app.models.product import Product
from app.models.order import Order, OrderItem
from app.models.users import Address
from app.schemas.orders import AddressRequest, CartItemRequest, CheckoutRequest
from app.core.exceptions import AppError
import uuid

class OrdersService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_or_create_cart(self, user_id: uuid.UUID) -> Cart:
        result = await self.db.execute(
            select(Cart)
            .filter(Cart.user_id == user_id)
            .options(selectinload(Cart.items).selectinload(CartItem.product).selectinload(Product.images))
        )
        cart = result.scalars().first()
        if not cart:
            cart = Cart(user_id=user_id, total_price=0.0)
            self.db.add(cart)
            await self.db.flush()
            
            # Expire to force reload of relationships
            cart_id = cart.id
            self.db.expire(cart)
            
            result = await self.db.execute(
                select(Cart)
                .filter(Cart.id == cart_id)
                .options(selectinload(Cart.items).selectinload(CartItem.product).selectinload(Product.images))
            )
            cart = result.scalars().first()
        return cart

    async def recalculate_cart(self, cart_id: uuid.UUID):
        result = await self.db.execute(
            select(Cart)
            .filter(Cart.id == cart_id)
            .options(selectinload(Cart.items))
            .execution_options(populate_existing=True)
        )
        cart = result.scalars().first()
        if not cart: return
        total = 0.0
        for item in cart.items:
            total += (item.quantity * item.price)
        cart.total_price = total
        await self.db.commit()

    async def add_to_cart(self, user_id: uuid.UUID, payload: CartItemRequest):
        cart = await self.get_or_create_cart(user_id)
        
        # Check product
        result = await self.db.execute(select(Product).filter(Product.id == payload.product_id))
        product = result.scalars().first()
        if not product or product.status != "approved":
            raise AppError("Product not found or unavailable", code="PRODUCT_UNAVAILABLE")
        if product.stock < payload.quantity:
            raise AppError("Insufficient stock", code="OUT_OF_STOCK")

        # Check if already in cart
        existing_item = next((i for i in cart.items if i.product_id == payload.product_id), None)
        if existing_item:
            existing_item.quantity += payload.quantity
        else:
            new_item = CartItem(
                cart_id=cart.id,
                product_id=product.id,
                quantity=payload.quantity,
                price=product.price
            )
            self.db.add(new_item)
            
        await self.db.commit()
        await self.recalculate_cart(cart.id)

    async def update_cart_item(self, user_id: uuid.UUID, payload: CartItemRequest):
        cart = await self.get_or_create_cart(user_id)
        item = next((i for i in cart.items if i.product_id == payload.product_id), None)
        if not item:
            raise AppError("Item not in cart", code="NOT_FOUND")
            
        if payload.quantity <= 0:
            await self.db.delete(item)
        else:
            # Check stock
            result = await self.db.execute(select(Product).filter(Product.id == payload.product_id))
            product = result.scalars().first()
            if product.stock < payload.quantity:
                raise AppError("Insufficient stock", code="OUT_OF_STOCK")
            item.quantity = payload.quantity
            
        await self.db.commit()
        await self.recalculate_cart(cart.id)

    async def remove_from_cart(self, user_id: uuid.UUID, product_id: uuid.UUID):
        cart = await self.get_or_create_cart(user_id)
        item = next((i for i in cart.items if i.product_id == product_id), None)
        if item:
            await self.db.delete(item)
            await self.db.commit()
            await self.recalculate_cart(cart.id)

    async def get_addresses(self, user_id: uuid.UUID):
        result = await self.db.execute(select(Address).filter(Address.user_id == user_id))
        return result.scalars().all()

    async def add_address(self, user_id: uuid.UUID, payload: AddressRequest):
        address = Address(
            user_id=user_id,
            **payload.model_dump()
        )
        self.db.add(address)
        await self.db.commit()
        await self.db.refresh(address)
        return address

    async def checkout(self, user_id: uuid.UUID, payload: CheckoutRequest):
        cart = await self.get_or_create_cart(user_id)
        if not cart.items:
            raise AppError("Cart is empty", code="CART_EMPTY")

        # Basic transaction
        try:
            # Check address
            addr_res = await self.db.execute(select(Address).filter(Address.id == payload.address_id, Address.user_id == user_id))
            if not addr_res.scalars().first():
                raise AppError("Invalid address", code="INVALID_ADDRESS")

            order = Order(
                user_id=user_id,
                status="pending",
                total_amount=cart.total_price,
                shipping_address_id=payload.address_id
            )
            self.db.add(order)
            await self.db.flush()

            for item in cart.items:
                # Deduct stock atomically
                stmt = (
                    update(Product)
                    .where(Product.id == item.product_id)
                    .where(Product.stock >= item.quantity)
                    .values(stock=Product.stock - item.quantity)
                )
                res = await self.db.execute(stmt)
                if res.rowcount == 0:
                    raise AppError(f"Insufficient stock for {item.product.name.get('uz', item.product.name.get('en', 'mahsulot'))}", code="OUT_OF_STOCK")
                    
                order_item = OrderItem(
                    order_id=order.id,
                    product_id=item.product_id,
                    quantity=item.quantity,
                    price=item.price
                )
                self.db.add(order_item)
                await self.db.delete(item) # clear cart item

            cart.total_price = 0.0
            await self.db.commit()
            return order
        except Exception as e:
            await self.db.rollback()
            raise e

    async def get_orders(self, user_id: uuid.UUID):
        result = await self.db.execute(
            select(Order)
            .filter(Order.user_id == user_id)
            .order_by(Order.created_at.desc())
        )
        return result.scalars().all()

    async def get_order_detail(self, user_id: uuid.UUID, order_id: uuid.UUID):
        result = await self.db.execute(
            select(Order)
            .filter(Order.id == order_id, Order.user_id == user_id)
            .options(
                selectinload(Order.shipping_address),
                selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.images)
            )
        )
        order = result.scalars().first()
        if not order:
            raise AppError("Order not found", code="NOT_FOUND", status_code=404)
        return order
