from pydantic import BaseModel
from typing import Generic, TypeVar, Optional, Any

T = TypeVar('T')

class APIResponse(BaseModel, Generic[T]):
    data: Optional[T] = None
    message: Optional[str] = None
    status_code: int = 200
