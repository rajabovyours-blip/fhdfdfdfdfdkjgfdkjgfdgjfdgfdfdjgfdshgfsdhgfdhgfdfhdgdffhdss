from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
from typing import Optional
from app.core.database import get_db
from app.api.dependencies import get_locale
from app.schemas.marketplace import ProductSummary, ProductDetail
from app.services.marketplace_service import MarketplaceService

router = APIRouter()

@router.get("", response_model=dict)
async def get_products(
    query: Optional[str] = Query(None),
    category_id: Optional[uuid.UUID] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    lang: str = Depends(get_locale)
):
    service = MarketplaceService(db)
    offset = (page - 1) * limit
    products = await service.get_products(query, category_id, limit, offset)
    
    res = [ProductSummary.model_validate(p, context={'lang': lang}).model_dump(mode='json') for p in products]
    
    return {
        "data": res,
        "meta": {
            "page": page,
            "limit": limit
            # total could be fetched with a count query
        }
    }

@router.get("/{product_id}", response_model=dict)
async def get_product_detail(product_id: uuid.UUID, db: AsyncSession = Depends(get_db), lang: str = Depends(get_locale)):
    service = MarketplaceService(db)
    product = await service.get_product_detail(product_id)
    return {"data": ProductDetail.model_validate(product, context={'lang': lang}).model_dump(mode='json')}
