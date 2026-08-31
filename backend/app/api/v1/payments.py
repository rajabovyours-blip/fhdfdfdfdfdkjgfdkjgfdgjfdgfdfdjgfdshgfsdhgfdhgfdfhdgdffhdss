from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.orders import PaymentProcessRequest
from app.api.dependencies import get_current_user
from app.models.users import User

router = APIRouter()

@router.get("-methods", response_model=dict)
async def get_payment_methods(current_user: User = Depends(get_current_user)):
    # Mocking payment methods
    methods = [
        {"id": 1, "name": "Click", "type": "click"},
        {"id": 2, "name": "Payme", "type": "payme"}
    ]
    return {"data": methods}

@router.post("s/process", response_model=dict)
async def process_payment(payload: PaymentProcessRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    # In a real app this would integrate with Stripe/Payme/Click
    return {"data": {"message": "Payment processed successfully", "transaction_id": "tx_mock_123"}}
