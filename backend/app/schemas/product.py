from pydantic import BaseModel
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
    subcategoryId: Optional[UUID] = None
    price: float
    oldPrice: Optional[float] = None
    currency: str = "UZS"
    unit: str = "pcs"
    moq: int = 1
    stock: int = 0
    stockStatus: str = "in_stock"
    rating: float = 0.0
    reviewCount: int = 0
    discount: Optional[float] = None
    specifications: Optional[Dict[str, str]] = None
    certificates: Optional[List[str]] = None
    deliveryInformation: Optional[str] = None
    location: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class CategoryModel(BaseModel):
    id: UUID
    name: Dict[str, str]
    description: Dict[str, str]
    icon_url: Optional[str] = None
    image_url: Optional[str] = None
    parent_id: Optional[UUID] = None
    is_featured: bool = False
    
    class Config:
        from_attributes = True
