from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.models.category import Category
from app.models.product import Product

router = APIRouter()

@router.get("/banners", response_model=APIResponse[list])
async def get_banners():
    return APIResponse(data=[
        {
            "id": "banner-1",
            "imageUrl": "https://images.unsplash.com/photo-1541888086425-d81bb19240f5",
            "linkUrl": "/promotions/summer",
            "title": {"uz": "Qurilish uchun kerakli hamma narsa bir joyda", "ru": "Всё для строительства в одном месте", "en": "Everything for construction in one place"},
            "subtitle": {"uz": "Eng yaxshi narxlarni toping", "ru": "Найдите лучшие цены", "en": "Find the best prices"},
            "cta": {"uz": "Mahsulotlarni ko'rish", "ru": "Посмотреть товары", "en": "View products"}
        },
        {
            "id": "banner-2",
            "imageUrl": "https://images.unsplash.com/photo-1503387762-592deb58ef4e",
            "linkUrl": "/categories/new",
            "title": {"uz": "Yangi qurilish materiallari", "ru": "Новые строительные материалы", "en": "New building materials"},
            "subtitle": {"uz": "Kuzgi chegirmalar", "ru": "Осенние скидки", "en": "Autumn discounts"},
            "cta": {"uz": "Sotib olish", "ru": "Купить", "en": "Buy now"}
        }
    ])

@router.get("/popular-categories", response_model=APIResponse[list])
async def get_popular_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Category).order_by(Category.order_index).limit(10))
    categories = result.scalars().all()
    data = []
    for c in categories:
        data.append({
            "id": str(c.id),
            "name": c.name,
            "icon_url": c.icon_url,
            "is_active": True
        })
    return APIResponse(data=data)

@router.get("/featured-products", response_model=APIResponse[list])
async def get_featured_products(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).order_by(desc(Product.created_at)).limit(10))
    products = result.scalars().all()
    data = []
    for p in products:
        images_list = p.images if isinstance(p.images, list) else []
        formatted_images = [{"image_url": img} for img in images_list]
        
        data.append({
            "id": str(p.id),
            "name": p.name,
            "description": p.description,
            "categoryId": str(p.category_id) if p.category_id else "",
            "price": float(p.price) if p.price else 0.0,
            "currency": p.currency,
            "unit": p.unit,
            "moq": p.moq,
            "stock": p.stock,
            "stockStatus": p.stock_status,
            "rating": float(p.rating) if p.rating else 0.0,
            "reviewCount": p.review_count,
            "location": p.location,
            "images": formatted_images,
            "videos": []
        })
    return APIResponse(data=data)
