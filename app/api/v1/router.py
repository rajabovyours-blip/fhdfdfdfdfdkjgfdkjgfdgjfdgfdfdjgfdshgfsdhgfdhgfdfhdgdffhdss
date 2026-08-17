from fastapi import APIRouter
from app.api.v1.auth import router as auth_router
from app.api.v1.home import router as home_router
from app.api.v1.categories import router as categories_router
from app.api.v1.products import router as products_router
from app.api.v1.wishlist import router as wishlist_router
from app.api.v1.cart import cart_router, address_router
from app.api.v1.orders import checkout_router, orders_router
from app.api.v1.payments import router as payments_router
from app.api.v1.admin import router as admin_router
api_router = APIRouter()
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(home_router, prefix="/home", tags=["home"])
api_router.include_router(categories_router, prefix="/categories", tags=["categories"])
api_router.include_router(products_router, prefix="/products", tags=["products"])
api_router.include_router(wishlist_router, prefix="/wishlist", tags=["wishlist"])
api_router.include_router(cart_router, prefix="/cart", tags=["cart"])
api_router.include_router(address_router, prefix="/addresses", tags=["addresses"])
api_router.include_router(checkout_router, prefix="/checkout", tags=["checkout"])
api_router.include_router(orders_router, prefix="/orders", tags=["orders"])
api_router.include_router(payments_router, prefix="/payment", tags=["payments"])
api_router.include_router(admin_router, prefix="/admin", tags=["admin"])
