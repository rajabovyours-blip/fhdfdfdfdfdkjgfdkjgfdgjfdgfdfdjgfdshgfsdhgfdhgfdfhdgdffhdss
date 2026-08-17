from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID

class UserModel(BaseModel):
    id: UUID
    full_name: str
    phone: str
    email: Optional[str] = None
    avatar_url: Optional[str] = None
    
    class Config:
        from_attributes = True

class UserCreate(BaseModel):
    full_name: str
    phone: str
    password: str

class UserLogin(BaseModel):
    phone: str
    password: str

class OTPRequest(BaseModel):
    phone: str

class OTPVerify(BaseModel):
    phone: str
    otp: str
    full_name: Optional[str] = None
    surname: Optional[str] = None

class CheckPhone(BaseModel):
    phone: str

class SocialLoginRequest(BaseModel):
    provider: str
    token: str
