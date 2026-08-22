from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.schemas.user import UserCreate, UserLogin, UserModel, OTPRequest, OTPVerify, CheckPhone, SocialLoginRequest
from app.schemas.token import TokenModel
from app.schemas.common import APIResponse
from app.auth.security import get_password_hash, verify_password, create_access_token
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from app.services.otp import otp_service
from app.services.eskiz import eskiz_service
from app.core.config import settings
import uuid

router = APIRouter()

@router.post("/register", response_model=APIResponse[dict])
async def register(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.phone == user_in.phone))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Phone number already registered")
        
    user = User(
        full_name=user_in.full_name,
        phone=user_in.phone,
        hashed_password=get_password_hash(user_in.password)
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    
    return APIResponse(message="User registered successfully")

@router.post("/check-phone", response_model=APIResponse[dict])
async def check_phone(check_in: CheckPhone, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.phone == check_in.phone))
    exists = result.scalar_one_or_none() is not None
    return APIResponse(data={"exists": exists})

@router.post("/login", response_model=APIResponse[TokenModel])
async def login(user_in: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.phone == user_in.phone))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect phone number or password")
        
    access_token = create_access_token(subject=str(user.id))
    
    token = TokenModel(
        access_token=access_token,
        refresh_token="not_implemented_yet",
        expires_in=86400
    )
    return APIResponse(data=token, message="Login successful")

from fastapi.security import OAuth2PasswordRequestForm

@router.post("/admin-login", response_model=APIResponse[TokenModel])
async def admin_login(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == form_data.username))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
        
    if user.role != RoleEnum.ADMIN:
        raise HTTPException(status_code=403, detail="Not authorized as admin")
        
    access_token = create_access_token(subject=str(user.id))
    
    token = TokenModel(
        access_token=access_token,
        refresh_token="not_implemented_yet",
        expires_in=86400
    )
    return APIResponse(data=token, message="Admin login successful")

@router.post("/request-otp", response_model=APIResponse[dict])
async def request_otp(otp_in: OTPRequest):
    # 1. Generate and store OTP securely
    otp_code = otp_service.request_otp(otp_in.phone)
    
    # 2. Prepare message
    if settings.ESKIZ_TEST_MODE:
        # Eskiz test accounts strictly require this exact string
        message = "Bu Eskiz dan test"
        
        # 3. Print the OTP to backend console so the developer can read it!
        # Do NOT log this in production
        print(f"\n=======================================================")
        print(f" *** TEST MODE OTP GENERATED for {otp_in.phone}: {otp_code} ***")
        print(f"=======================================================\n")
    else:
        # Real production message
        message = f"Milliy Metr ilovasiga kirish uchun tasdiqlash kodingiz: {otp_code}. Kodni hech kimga bermang. Milliy Metr xodimlari ham ushbu kodni so‘ramaydi."
    
    # 4. Send via Eskiz
    success = await eskiz_service.send_sms(otp_in.phone, message)
    if not success:
        raise HTTPException(status_code=500, detail="SMS sending failed. Check credentials.")
        
    return APIResponse(message="OTP requested successfully. Please check your SMS.")

@router.post("/verify-otp", response_model=APIResponse[TokenModel])
async def verify_otp(otp_in: OTPVerify, db: AsyncSession = Depends(get_db)):
    # 1. Verify OTP securely
    otp_service.verify_otp(otp_in.phone, otp_in.otp)
    
    # 2. Check if user exists, else create minimal user profile
    result = await db.execute(select(User).where(User.phone == otp_in.phone))
    user = result.scalar_one_or_none()
    
    if not user:
        # Create a new user entry for this phone number
        
        # Determine name from registration input or fallback to "New User"
        name_parts = []
        if otp_in.full_name:
            name_parts.append(otp_in.full_name.strip())
        if otp_in.surname:
            name_parts.append(otp_in.surname.strip())
            
        final_name = " ".join(name_parts) if name_parts else "New User"
        
        user = User(
            id=uuid.uuid4(),
            full_name=final_name,
            phone=otp_in.phone,
            hashed_password=get_password_hash(otp_in.phone) # Dummy password since we use OTP
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

    # 3. Issue JWT
    access_token = create_access_token(subject=str(user.id))
    
    token = TokenModel(
        access_token=access_token,
        refresh_token="not_implemented_yet",
        expires_in=86400
    )
    return APIResponse(data=token, message="Login successful")

@router.post("/social-login", response_model=APIResponse[TokenModel])
async def social_login(payload: SocialLoginRequest, db: AsyncSession = Depends(get_db)):
    if payload.provider != 'google':
        raise HTTPException(status_code=400, detail="Unsupported provider")
        
    try:
        # Verify the token against our Web Client ID
        CLIENT_ID = "5408559924-kl0rm498vdr2qo39prt5k6g5v0vjvsqt.apps.googleusercontent.com"
        id_info = id_token.verify_oauth2_token(
            payload.token, google_requests.Request(), CLIENT_ID
        )
        email = id_info.get('email')
        provider_id = id_info.get('sub')
        first_name = id_info.get('given_name', 'Google')
        last_name = id_info.get('family_name', 'User')
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid Google token: {str(e)}")

    if not email:
        raise HTTPException(status_code=400, detail="Could not extract email from Google token")

    # Check if user exists by email
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    
    if not user:
        # Create new user
        full_name = f"{first_name} {last_name}".strip()
        dummy_phone = f"google_{provider_id}"[:20] # Ensure it fits in 20 chars
        user = User(
            id=uuid.uuid4(),
            full_name=full_name,
            email=email,
            phone=dummy_phone, # Required by DB schema
            hashed_password=get_password_hash(uuid.uuid4().hex),
            provider='google',
            provider_id=provider_id
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

    access_token = create_access_token(subject=str(user.id))
    
    token = TokenModel(
        access_token=access_token,
        refresh_token="not_implemented_yet",
        expires_in=86400
    )
    return APIResponse(data=token, message="Social login successful")

from app.api.deps import get_current_user

@router.get("/me", response_model=APIResponse[UserModel])
async def read_users_me(current_user: User = Depends(get_current_user)):
    user_model = UserModel.model_validate(current_user)
    return APIResponse(data=user_model)
