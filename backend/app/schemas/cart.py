from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from .product import ProductModel

class CartItemModel(BaseModel):
    id: UUID
    product: ProductModel
    quantity: int = 1
    is_selected: bool = True
    is_saved_for_later: bool = False
    
    class Config:
        from_attributes = True

class CartItemCreate(BaseModel):
    product_id: UUID
    quantity: int = 1
