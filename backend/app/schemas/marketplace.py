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

    @model_validator(mode='after')
    def set_localized_name(self, info: ValidationInfo):
        lang = info.context.get("lang", "uz") if info.context else "uz"
        self.name = getattr(self, f"name_{lang}", self.name_uz)
        return self

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
    images: List[ProductImageResponse] = []
    model_config = {"from_attributes": True}

    @model_validator(mode='after')
    def set_localized_name(self, info: ValidationInfo):
        lang = info.context.get("lang", "uz") if info.context else "uz"
        self.name = getattr(self, f"name_{lang}", self.name_uz)
        return self

class ProductDetail(ProductSummary):
    description: str = ""
    description_uz: Optional[str] = Field(default=None, exclude=True)
    description_ru: Optional[str] = Field(default=None, exclude=True)
    description_en: Optional[str] = Field(default=None, exclude=True)
    stock: int
    category_id: UUID4

    @model_validator(mode='after')
    def set_localized_desc(self, info: ValidationInfo):
        lang = info.context.get("lang", "uz") if info.context else "uz"
        desc = getattr(self, f"description_{lang}", self.description_uz)
        self.description = desc if desc else ""
        return self

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
    stock: int
    category_id: UUID4

class ReviewResponse(BaseModel):
    id: UUID4
    user_name: str
    rating: float
    comment: Optional[str] = None
    created_at: datetime
    model_config = {"from_attributes": True}

class WishlistResponse(BaseModel):
    products: List[ProductSummary] = []
