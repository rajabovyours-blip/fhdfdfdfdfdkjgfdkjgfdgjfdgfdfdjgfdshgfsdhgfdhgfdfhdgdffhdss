import json
from uuid import uuid4
from pydantic import BaseModel, ConfigDict, field_validator
from typing import Optional
from pydantic.alias_generators import to_camel

class BannerResponse(BaseModel):
    id: str
    title: Optional[str] = None
    image_url: str
    link_url: str = ""
    is_active: bool
    order_index: int
    
    @field_validator("link_url", mode="before")
    def empty_string_for_none(cls, v):
        return v if v is not None else ""
    
    model_config = ConfigDict(from_attributes=True, populate_by_name=True, alias_generator=to_camel)

banner = BannerResponse(id=str(uuid4()), title="Promo", image_url="http://test.com/img.png", link_url=None, is_active=True, order_index=1)
print(banner.model_dump_json(by_alias=True))
