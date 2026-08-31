import hashlib
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.schemas.common import APIResponse
from app.models.order import Order
from app.models.extras import Payment
from app.core.config import settings

router = APIRouter()

@router.get("/payment-methods", response_model=APIResponse[list])
async def get_payment_methods():
    return APIResponse(data=[
        {"id": "click", "name": {"en": "Click", "ru": "Click", "uz": "Click"}},
        {"id": "payme", "name": {"en": "Payme", "ru": "Payme", "uz": "Payme"}}
    ])

@router.post("/click/webhook")
async def click_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    # Phase 14: Define webhook endpoints, validate signature, make idempotent
    # 1. Read request
    # form_data = await request.form()
    
    # 2. Validate Click signature using settings.CLICK_SECRET_KEY
    # signature = hashlib.md5(...)
    
    # 3. Prevent duplicate payment processing (Idempotency)
    # result = await db.execute(select(Payment).where(Payment.transaction_id == click_trans_id))
    # if result.scalar_one_or_none():
    #     return {"error": 0, "error_note": "Already processed"}
    
    # 4. Never trust payment status from Flutter
    # 5. Update Order status
    
    return {"error": 0, "error_note": "Success"}

@router.post("/payme/webhook")
async def payme_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    # Phase 14: Define webhook endpoints, validate signature, make idempotent
    # payload = await request.json()
    
    # Validate Payme authorization header
    # Check if payment is already processed
    
    return {"result": {"message": "Success"}}
