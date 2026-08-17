from pydantic import BaseModel, EmailStr, UUID4
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    phone: str | None = None

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: UUID4
    is_active: bool
    role_id: UUID4 | None = None
    created_at: datetime
    
    model_config = {"from_attributes": True}
