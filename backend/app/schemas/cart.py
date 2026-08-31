from pydantic.alias_generators import to_camel
from pydantic import BaseModel, ConfigDict
from typing import Optional
from uuid import UUID
from .product import ProductModel

class CartItemModel(BaseModel):
    id: UUID
    product: ProductModel
    quantity: int = 1
    is_selected: bool = True
    is_saved_for_later: bool = False
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)

class CartItemCreate(BaseModel):
    product_id: UUID
    quantity: int = 1

class CartItemUpdate(BaseModel):
    quantity: int
