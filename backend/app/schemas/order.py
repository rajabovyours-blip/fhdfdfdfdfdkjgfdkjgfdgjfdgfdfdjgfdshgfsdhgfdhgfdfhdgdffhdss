from pydantic.alias_generators import to_camel
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from .cart import CartItemModel

class OrderUserModel(BaseModel):
    id: UUID
    full_name: str
    phone_number: Optional[str] = Field(default=None, validation_alias="phone")
    email: Optional[str] = None
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)

class OrderModel(BaseModel):
    id: UUID
    order_number: str
    invoice_number: Optional[str] = None
    status: str = "Pending"
    payment_status: str = "Pending"
    delivery_status: str = "Pending"
    subtotal: Optional[float] = 0.0
    shipping_fee: Optional[float] = 0.0
    discount: Optional[float] = 0.0
    tax: Optional[float] = 0.0
    total: Optional[float] = 0.0
    delivery_address: str = ""
    payment_method: str = ""
    delivery_method: str = ""
    tracking_number: Optional[str] = None
    customer_notes: Optional[str] = None
    created_at: datetime
    items: List[CartItemModel] = []
    user: Optional[OrderUserModel] = None
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)
