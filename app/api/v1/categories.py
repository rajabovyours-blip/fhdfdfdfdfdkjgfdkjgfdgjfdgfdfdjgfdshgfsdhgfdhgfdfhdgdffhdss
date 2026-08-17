from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.core.database import get_db
from app.api.dependencies import get_locale
from app.schemas.marketplace import CategoryTree
from app.services.marketplace_service import MarketplaceService

router = APIRouter()

@router.get("", response_model=dict)
async def get_categories(db: AsyncSession = Depends(get_db), lang: str = Depends(get_locale)):
    service = MarketplaceService(db)
    categories = await service.get_categories()
    
    # We must manually dump using Pydantic schema to handle relationships correctly
    res = []
    for c in categories:
        res.append(CategoryTree.model_validate(c, context={'lang': lang}).model_dump(mode='json'))
        
    return {"data": res}
