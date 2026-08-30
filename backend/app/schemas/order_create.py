from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from typing import Optional, List
from uuid import UUID

class OrderCreateItem(BaseModel):
    product_id: UUID
    quantity: int
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)

class OrderCreate(BaseModel):
    delivery_address: str
    payment_method: str
    delivery_method: str
    customer_notes: Optional[str] = None
    items: List[OrderCreateItem]
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)
