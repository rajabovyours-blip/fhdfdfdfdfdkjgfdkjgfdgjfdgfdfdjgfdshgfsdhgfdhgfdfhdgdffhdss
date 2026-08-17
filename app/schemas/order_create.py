from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID

class OrderCreateItem(BaseModel):
    product_id: UUID
    quantity: int

class OrderCreate(BaseModel):
    delivery_address: str
    payment_method: str
    delivery_method: str
    customer_notes: Optional[str] = None
    items: List[OrderCreateItem]
