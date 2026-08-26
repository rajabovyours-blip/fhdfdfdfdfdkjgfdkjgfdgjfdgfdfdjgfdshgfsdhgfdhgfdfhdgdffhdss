from fastapi import APIRouter
from app.api.endpoints import auth, products, categories, users, cart, orders, admin, admin_products, payments, notifications, checkout, addresses, home, upload, analytics, banners

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(products.router, prefix="/products", tags=["products"])
api_router.include_router(categories.router, prefix="/categories", tags=["categories"])
api_router.include_router(cart.router, prefix="/cart", tags=["cart"])
api_router.include_router(checkout.router, prefix="/checkout", tags=["checkout"])
api_router.include_router(orders.router, prefix="/orders", tags=["orders"])
api_router.include_router(addresses.router, prefix="/addresses", tags=["addresses"])

api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(admin_products.router, prefix="/admin/products", tags=["admin-products"])
api_router.include_router(payments.router, prefix="/payments", tags=["payments"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
api_router.include_router(home.router, prefix="/home", tags=["home"])
api_router.include_router(upload.router, prefix="/upload", tags=["upload"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
api_router.include_router(banners.router, prefix="/banners", tags=["banners"])
