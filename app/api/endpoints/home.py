from fastapi import APIRouter
from app.schemas.common import APIResponse

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
async def get_popular_categories():
    return APIResponse(data=[
        {
            "id": "cat-1",
            "name": {"uz": "G'isht va Bloklar", "ru": "Кирпичи и Блоки", "en": "Bricks and Blocks"},
            "icon_url": "https://images.unsplash.com/photo-1589939705384-5185137a7f0f",
            "is_active": True
        },
        {
            "id": "cat-2",
            "name": {"uz": "Sement", "ru": "Цемент", "en": "Cement"},
            "icon_url": "https://images.unsplash.com/photo-1621501103258-3e4b77ae5573",
            "is_active": True
        },
        {
            "id": "cat-3",
            "name": {"uz": "Yog'och materiallari", "ru": "Пиломатериалы", "en": "Lumber"},
            "icon_url": "https://images.unsplash.com/photo-1517424694921-6d76bb9d29fc",
            "is_active": True
        }
    ])

@router.get("/featured-products", response_model=APIResponse[list])
async def get_featured_products():
    return APIResponse(data=[
        {
            "id": "prod-1",
            "name": {"uz": "Qizil g'isht (Standart)", "ru": "Красный кирпич (Стандарт)", "en": "Red Brick (Standard)"},
            "description": {"uz": "Yuqori sifatli pishgan qizil g'isht.", "ru": "Качественный красный кирпич.", "en": "High quality red brick."},
            "categoryId": "cat-1",
            "price": 1200.0,
            "currency": "UZS",
            "unit": "dona",
            "moq": 1000,
            "stock": 5000,
            "stockStatus": "in_stock",
            "rating": 4.8,
            "reviewCount": 120,
            "location": "Toshkent",
            "images": [{"image_url": "https://images.unsplash.com/photo-1589939705384-5185137a7f0f"}],
            "videos": []
        },
        {
            "id": "prod-2",
            "name": {"uz": "Sement M400", "ru": "Цемент М400", "en": "Cement M400"},
            "description": {"uz": "Qurilish sementi M400, 50kg qopda.", "ru": "Строительный цемент М400, 50кг.", "en": "Construction cement M400, 50kg bag."},
            "categoryId": "cat-2",
            "price": 55000.0,
            "currency": "UZS",
            "unit": "qop",
            "moq": 10,
            "stock": 500,
            "stockStatus": "in_stock",
            "rating": 4.9,
            "reviewCount": 350,
            "location": "Samarqand",
            "images": [{"image_url": "https://images.unsplash.com/photo-1621501103258-3e4b77ae5573"}],
            "videos": []
        }
    ])
