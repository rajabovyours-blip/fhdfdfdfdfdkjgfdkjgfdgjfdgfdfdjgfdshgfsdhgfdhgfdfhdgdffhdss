from pydantic.alias_generators import to_camel
from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Dict
from uuid import UUID
from datetime import datetime

class ProductModel(BaseModel):
    id: UUID
    sku: Optional[str] = None
    name: Dict[str, str]
    description: Dict[str, str]
    images: List[str] = []
    videos: List[str] = []
    brand: Optional[str] = None
    category_id: UUID
    subcategory_id: Optional[UUID] = None
    price: float
    old_price: Optional[float] = None
    currency: str = "UZS"
    unit: str = "pcs"
    moq: int = 1
    stock: int = 0
    stock_status: str = "in_stock"
    rating: float = 0.0
    review_count: int = 0
    discount: Optional[float] = None
    specifications: Optional[Dict[str, str]] = None
    certificates: Optional[List[str]] = None
    delivery_information: Optional[str] = None
    location: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)

class CategoryModel(BaseModel):
    id: UUID
    name: Dict[str, str]
    description: Dict[str, str]
    icon_url: Optional[str] = None
    image_url: Optional[str] = None
    parent_id: Optional[UUID] = None
    is_featured: bool = False
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)
