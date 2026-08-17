from pydantic import BaseModel, EmailStr
from typing import Optional

class LoginRequest(BaseModel):
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None # Make optional since we use OTP

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RegisterRequest(BaseModel):
    full_name: Optional[str] = None
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    phone: str

class RequestOtpRequest(BaseModel):
    phone: str

class VerifyOtpRequest(BaseModel):
    phone: str
    otp: str

class SocialLoginRequest(BaseModel):
    provider: str # 'google', 'apple'
    token: str # ID token from provider

class RefreshRequest(BaseModel):
    refresh_token: str

