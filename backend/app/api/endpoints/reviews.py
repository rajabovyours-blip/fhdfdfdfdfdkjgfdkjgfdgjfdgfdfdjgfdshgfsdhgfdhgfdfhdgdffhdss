from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID

from app.db.session import get_db
from app.models.user import User
from app.models.review import Review
from app.schemas.common import APIResponse
from app.api.dependencies import get_current_admin
from sqlalchemy.orm import selectinload

router = APIRouter()

@router.get("", response_model=APIResponse[list])
async def list_all_reviews(db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    result = await db.execute(
        select(Review)
        .options(selectinload(Review.user), selectinload(Review.product))
        .order_by(Review.created_at.desc())
    )
    reviews = result.scalars().all()
    
    return APIResponse(data=[
        {
            "id": str(r.id),
            "user_id": str(r.user_id),
            "user_name": r.user.full_name if r.user else "Noma'lum",
            "product_id": str(r.product_id),
            "product_name": r.product.name if r.product else "Noma'lum",
            "rating": float(r.rating) if r.rating else 0,
            "comment": r.comment,
            "created_at": r.created_at.isoformat() if r.created_at else None
        }
        for r in reviews
    ])

@router.delete("/{id}", response_model=APIResponse[dict])
async def delete_review(id: UUID, db: AsyncSession = Depends(get_db), admin: User = Depends(get_current_admin)):
    result = await db.execute(select(Review).where(Review.id == id))
    review = result.scalar_one_or_none()
    
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
        
    await db.delete(review)
    await db.commit()
    
    return APIResponse(data={"message": "Sharh o'chirildi"})
