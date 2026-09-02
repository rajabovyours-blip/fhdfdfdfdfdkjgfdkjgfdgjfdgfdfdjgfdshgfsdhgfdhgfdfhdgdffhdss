from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from typing import Generic, TypeVar, Optional, Any

T = TypeVar('T')

class APIResponse(BaseModel, Generic[T]):
    data: Optional[T] = None
    message: Optional[str] = None
    status_code: int = 200
    model_config = ConfigDict(
        populate_by_name=True,
        alias_generator=to_camel,
    )

