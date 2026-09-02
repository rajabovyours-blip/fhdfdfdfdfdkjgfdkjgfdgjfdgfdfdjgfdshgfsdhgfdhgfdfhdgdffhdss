from pydantic import BaseModel, UUID4, Field, model_validator, ValidationInfo
from typing import List, Optional, Any
from datetime import datetime

class CategoryBase(BaseModel):
    id: UUID4
    name: str = ""
    name_uz: str = Field(default="", exclude=True)
    name_ru: str = Field(default="", exclude=True)
    name_en: str = Field(default="", exclude=True)
    icon_url: Optional[str] = None
    is_active: bool
    model_config = {"from_attributes": True}

    @model_validator(mode='before')
    @classmethod
    def set_localized_name(cls, data: Any, info: ValidationInfo):
        lang = info.context.get("lang", "uz") if info.context else "uz"
        
        if hasattr(data, "name") and isinstance(data.name, dict):
            name_val = data.name.get(lang, data.name.get("uz", ""))
            return {
                "id": data.id,
                "name": name_val,
                "icon_url": data.icon_url,
                "is_active": data.is_active
            }
        return data

class CategoryTree(CategoryBase):
    subcategories: List['CategoryTree'] = []

class ProductImageResponse(BaseModel):
    id: UUID4
    image_url: str
    is_primary: bool
    model_config = {"from_attributes": True}


class ProductSummary(BaseModel):
    id: UUID4
    name: str = ""
    name_uz: str = Field(default="", exclude=True)
    name_ru: str = Field(default="", exclude=True)
    name_en: str = Field(default="", exclude=True)
    price: float
    old_price: Optional[float] = None
    rating: float
    images: List[str] = []
    model_config = {"from_attributes": True}

    @model_validator(mode='before')
    @classmethod
    def set_localized_name(cls, data: Any, info: ValidationInfo):
        lang = info.context.get("lang", "uz") if info.context else "uz"
        
        # SQLAlchemy model
        if hasattr(data, "name") and isinstance(data.name, dict):
            name_val = data.name.get(lang, data.name.get("uz", ""))
            images_val = [img.image_url for img in data.images] if hasattr(data, "images") and data.images else []
            return {
                "id": data.id,
                "name": name_val,
                "price": data.price,
                "old_price": data.old_price,
                "rating": data.rating,
                "images": images_val
            }
        return data

class ProductDetail(ProductSummary):
    description: str = ""
    description_uz: Optional[str] = Field(default=None, exclude=True)
    description_ru: Optional[str] = Field(default=None, exclude=True)
    description_en: Optional[str] = Field(default=None, exclude=True)
    stock: int
    category_id: UUID4

    @model_validator(mode='before')
    @classmethod
    def set_localized_desc(cls, data: Any, info: ValidationInfo):
        # We also need to call the parent validator since we are overriding it, or do we?
        # Actually Pydantic v2 calls both before validators in MRO order.
        lang = info.context.get("lang", "uz") if info.context else "uz"
        
        if isinstance(data, dict):
            return data
            
        # SQLAlchemy model
        if hasattr(data, "description") and isinstance(data.description, dict):
            desc_val = data.description.get(lang, data.description.get("uz", ""))
            
            # Reconstruct the dict that Pydantic will validate
            name_val = data.name.get(lang, data.name.get("uz", "")) if (hasattr(data, "name") and isinstance(data.name, dict)) else ""
            images_val = [img.image_url for img in data.images] if hasattr(data, "images") and data.images else []
            return {
                "id": data.id,
                "name": name_val,
                "price": data.price,
                "old_price": data.old_price,
                "rating": data.rating,
                "images": images_val,
                "description": desc_val,
                "stock": data.stock,
                "category_id": data.category_id
            }
        return data

class BannerResponse(BaseModel):
    id: int
    image_url: str
    link: str

class ProductCreate(BaseModel):
    name_uz: str
    name_ru: str = ""
    name_en: str = ""
    description_uz: Optional[str] = None
    description_ru: Optional[str] = None
    description_en: Optional[str] = None
    price: float
    old_price: Optional[float] = None
    stock: int = Field(default=0, alias="stock_quantity")
    category_id: UUID4
    has_delivery: bool = True

class ReviewResponse(BaseModel):
    id: UUID4
    user_name: str
    rating: float
    comment: Optional[str] = None
    created_at: datetime
    model_config = {"from_attributes": True}

class WishlistResponse(BaseModel):
    products: List[ProductSummary] = []
