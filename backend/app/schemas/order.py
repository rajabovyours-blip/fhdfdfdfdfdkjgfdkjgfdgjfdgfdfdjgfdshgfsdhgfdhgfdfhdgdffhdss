from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from .cart import CartItemModel

class OrderModel(BaseModel):
    id: UUID
    order_number: str
    invoice_number: Optional[str] = None
    status: str
    payment_status: str
    delivery_status: str
    subtotal: float
    shipping_fee: float
    discount: float
    tax: float
    total: float
    delivery_address: str
    payment_method: str
    delivery_method: str
    tracking_number: Optional[str] = None
    customer_notes: Optional[str] = None
    created_at: datetime
    items: List[CartItemModel] = []
    
    class Config:
        from_attributes = True
