from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.core.database import get_db
from app.api.dependencies import get_locale
from app.schemas.marketplace import BannerResponse, CategoryTree, ProductSummary
from app.services.marketplace_service import MarketplaceService

router = APIRouter()

@router.get("/banners", response_model=dict)
async def get_banners():
    # In a real app this might come from the DB, but for now we can mock some banners
    banners = [
        {"id": "1", "imageUrl": "https://example.com/banner1.jpg", "linkUrl": "/promo1"},
        {"id": "2", "imageUrl": "https://example.com/banner2.jpg", "linkUrl": "/promo2"}
    ]
    return {"data": banners}

@router.get("/popular-categories", response_model=dict)
async def get_popular_categories(db: AsyncSession = Depends(get_db), lang: str = Depends(get_locale)):
    service = MarketplaceService(db)
    categories = await service.get_categories()
    res = []
    for c in list(categories)[:4]:
        res.append(CategoryTree.model_validate(c, context={'lang': lang}).model_dump(mode='json'))
    return {"data": res}

@router.get("/featured-products", response_model=dict)
async def get_featured_products(db: AsyncSession = Depends(get_db), lang: str = Depends(get_locale)):
    service = MarketplaceService(db)
    products = await service.get_products(limit=10)
    res = []
    for p in products:
        res.append(ProductSummary.model_validate(p, context={'lang': lang}).model_dump(mode='json'))
    return {"data": res}
