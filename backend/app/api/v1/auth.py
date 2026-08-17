from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, VerifyOtpRequest, RefreshRequest, RequestOtpRequest, SocialLoginRequest
from app.schemas.users import UserResponse
from app.services.auth_service import AuthService
from app.api.dependencies import get_current_user
from app.models.users import User

router = APIRouter()

@router.post("/register")
async def register(payload: RegisterRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.register_user(payload)
    return {"data": result}

@router.post("/login", response_model=dict)
async def login(payload: LoginRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.login(payload)
    return {"data": result}

@router.post("/request-otp")
async def request_otp(payload: RequestOtpRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.request_otp(payload)
    return {"data": result}

@router.post("/verify-otp")
async def verify_otp(payload: VerifyOtpRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.verify_otp(payload)
    return {"data": result}

@router.post("/social-login")
async def social_login(payload: SocialLoginRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.social_login(payload)
    return {"data": result}

@router.post("/refresh", response_model=dict)
async def refresh_token(payload: RefreshRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.refresh_token(payload.refresh_token)
    return {"data": result}

@router.get("/me", response_model=dict)
async def get_me(current_user: User = Depends(get_current_user)):
    user_response = UserResponse.model_validate(current_user)
    return {"data": user_response.model_dump(mode='json')}
