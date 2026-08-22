from pydantic.alias_generators import to_camel
from pydantic import BaseModel, ConfigDict, UUID4
from typing import List, Optional
from datetime import datetime
from app.schemas.marketplace import ProductSummary

class CartItemRequest(BaseModel):
    product_id: UUID4
    quantity: int

class CartItemResponse(BaseModel):
    id: UUID4
    product: ProductSummary
    quantity: int
    price: float
    model_config = {"from_attributes": True}

class CartResponse(BaseModel):
    id: UUID4
    total_price: float
    items: List[CartItemResponse] = []
    model_config = {"from_attributes": True}

class AddressRequest(BaseModel):
    title: str
    address_line_1: str
    city: str
    region: str
    postal_code: Optional[str] = None
    is_default: bool = False

class AddressResponse(AddressRequest):
    id: UUID4
    model_config = {"from_attributes": True}

class CheckoutRequest(BaseModel):
    address_id: UUID4
    payment_method_id: int

class OrderItemResponse(BaseModel):
    id: UUID4
    product: ProductSummary
    quantity: int
    price: float
    model_config = {"from_attributes": True}

class OrderSummary(BaseModel):
    id: UUID4
    status: str
    total_amount: float
    created_at: datetime
    model_config = {"from_attributes": True}

class OrderDetail(OrderSummary):
    shipping_address: AddressResponse
    items: List[OrderItemResponse] = []

class PaymentProcessRequest(BaseModel):
    order_id: UUID4
    payment_method_id: int
