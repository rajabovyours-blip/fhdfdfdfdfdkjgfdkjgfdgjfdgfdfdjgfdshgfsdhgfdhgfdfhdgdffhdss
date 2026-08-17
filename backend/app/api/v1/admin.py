from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
import uuid
from app.core.database import get_db
from app.schemas.admin import AdminDashboardSummary, AdminActionRequest
from app.schemas.users import UserResponse
from app.schemas.marketplace import ProductDetail, ProductCreate
from app.services.admin_service import AdminService
from app.api.dependencies import get_current_admin
from app.models.users import User

router = APIRouter()

@router.get("/dashboard", response_model=dict)
async def dashboard(current_user: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    service = AdminService(db)
    result = await service.get_dashboard()
    return {"data": AdminDashboardSummary.model_validate(result).model_dump(mode='json')}

@router.get("/users", response_model=dict)
async def get_users(current_user: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    service = AdminService(db)
    users = await service.get_users()
    res = [UserResponse.model_validate(u).model_dump(mode='json') for u in users]
    return {"data": res}

@router.post("/products", response_model=dict)
async def create_product(payload: ProductCreate, current_user: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    service = AdminService(db)
    product = await service.create_product(payload, created_by_id=current_user.id)
    return {"data": ProductDetail.model_validate(product).model_dump(mode='json')}

@router.put("/products/{product_id}", response_model=dict)
async def update_product(product_id: uuid.UUID, payload: ProductCreate, current_user: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    service = AdminService(db)
    product = await service.update_product(product_id, payload)
    return {"data": ProductDetail.model_validate(product).model_dump(mode='json')}

@router.delete("/products/{product_id}", response_model=dict)
async def delete_product(product_id: uuid.UUID, current_user: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    service = AdminService(db)
    await service.delete_product(product_id)
    return {"data": {"message": "Product deleted successfully"}}
