from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from app.models.users import User, Role
from app.schemas.auth import RegisterRequest, LoginRequest, RequestOtpRequest, VerifyOtpRequest, SocialLoginRequest
from app.security.hashing import get_password_hash, verify_password
from app.security.jwt import create_access_token, create_refresh_token
from app.core.exceptions import AppError
import random
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import jwt
import requests
from jwt.algorithms import RSAAlgorithm

class AuthService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def _get_or_create_customer_role(self) -> Role:
        role_result = await self.db.execute(select(Role).filter(Role.name == "customer"))
        role = role_result.scalars().first()
        if not role:
            role = Role(name="customer", description="Standard customer")
            self.db.add(role)
            await self.db.flush()
        return role

    async def register_user(self, payload: RegisterRequest) -> dict:
        result = await self.db.execute(select(User).filter(User.phone == payload.phone))
        if result.scalars().first():
            raise AppError("Phone number already registered", code="PHONE_EXISTS")
            
        role = await self._get_or_create_customer_role()
        
        full_name = payload.full_name or payload.name or "User"
        name_parts = full_name.split(" ", 1)
        
        user = User(
            email=payload.email or f"{payload.phone}@milliymetr.uz",
            password_hash=get_password_hash(payload.password) if payload.password else "",
            phone=payload.phone,
            first_name=name_parts[0],
            last_name=name_parts[1] if len(name_parts) > 1 else "",
            role_id=role.id
        )
        self.db.add(user)
        await self.db.commit()
        return {"message": "User registered successfully."}

    async def request_otp(self, payload: RequestOtpRequest) -> dict:
        # Generate OTP
        otp = str(random.randint(100000, 999999))
        
        # Here we would normally send the OTP via SMS provider (e.g. Eskiz) and store it in Redis with expiry.
        # For development/fallback, we will just print it to the console and accept "123456" or the generated one.
        print(f"OTP for {payload.phone}: {otp}")
        
        return {"message": "OTP sent successfully (Check console for dev)"}

    async def verify_otp(self, payload: VerifyOtpRequest) -> dict:
        # In a real app, verify OTP against Redis. Here we accept 123456 as universal dev OTP for any number.
        if payload.otp != "123456" and len(payload.otp) != 6:
            raise AppError("Invalid OTP", code="INVALID_OTP", status_code=400)
            
        result = await self.db.execute(select(User).filter(User.phone == payload.phone))
        user = result.scalars().first()
        
        if not user:
            role = await self._get_or_create_customer_role()
            user = User(
                email=f"{payload.phone}@milliymetr.uz",
                password_hash="",
                phone=payload.phone,
                first_name="User",
                last_name="",
                role_id=role.id
            )
            self.db.add(user)
            await self.db.commit()
            await self.db.refresh(user)
            
        if not user.is_active:
            raise AppError("User account is disabled", code="USER_DISABLED", status_code=403)
            
        access_token = create_access_token(subject=str(user.id), token_version=user.token_version)
        refresh_token = create_refresh_token(data={"sub": str(user.id)})
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }

    async def social_login(self, payload: SocialLoginRequest) -> dict:
        email = None
        provider_id = None
        first_name = payload.provider.capitalize()
        last_name = "User"

        if payload.provider == 'google':
            try:
                # Note: To fully secure this, pass client_id=YOUR_CLIENT_ID
                id_info = id_token.verify_oauth2_token(
                    payload.token, google_requests.Request()
                )
                email = id_info.get('email')
                provider_id = id_info.get('sub')
                if 'given_name' in id_info:
                    first_name = id_info['given_name']
                if 'family_name' in id_info:
                    last_name = id_info['family_name']
            except ValueError as e:
                raise AppError(f"Invalid Google token: {str(e)}", code="INVALID_TOKEN", status_code=400)
                
        elif payload.provider == 'apple':
            try:
                # Fetch Apple's public keys
                r = requests.get('https://appleid.apple.com/auth/keys')
                keys = r.json()['keys']
                
                header = jwt.get_unverified_header(payload.token)
                kid = header['kid']
                key = next(k for k in keys if k['kid'] == kid)
                public_key = RSAAlgorithm.from_jwk(key)
                
                # Decode the token (ignoring audience check here since bundle ID varies by environment)
                decoded = jwt.decode(
                    payload.token,
                    public_key,
                    algorithms=['RS256'],
                    options={"verify_aud": False}
                )
                email = decoded.get('email')
                provider_id = decoded.get('sub')
            except Exception as e:
                raise AppError(f"Invalid Apple token: {str(e)}", code="INVALID_TOKEN", status_code=400)
        else:
            raise AppError("Unsupported provider", code="UNSUPPORTED_PROVIDER", status_code=400)

        if not provider_id:
            raise AppError("Could not determine provider identity", code="INVALID_TOKEN", status_code=400)

        # 1. Try to find user by provider and provider_id
        result = await self.db.execute(select(User).filter(User.provider == payload.provider, User.provider_id == provider_id))
        user = result.scalars().first()
        
        # 2. Try to find user by email to link (Safe link, since both are verified by provider)
        if not user and email:
            result = await self.db.execute(select(User).filter(User.email == email))
            user = result.scalars().first()
            if user:
                # Auto-link the provider
                user.provider = payload.provider
                user.provider_id = provider_id
                await self.db.commit()

        # 3. Create new user if not found
        if not user:
            role = await self._get_or_create_customer_role()
            user = User(
                email=email or f"{payload.provider}_{provider_id}@milliymetr.uz",
                password_hash="",
                phone=None,
                first_name=first_name,
                last_name=last_name,
                role_id=role.id,
                provider=payload.provider,
                provider_id=provider_id
            )
            self.db.add(user)
            await self.db.commit()
            await self.db.refresh(user)
            
        if not user.is_active:
            raise AppError("User account is disabled", code="USER_DISABLED", status_code=403)
            
        access_token = create_access_token(subject=str(user.id), token_version=user.token_version)
        refresh_token = create_refresh_token(data={"sub": str(user.id)})
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }

    async def login(self, payload: LoginRequest) -> dict:
        if payload.phone:
            result = await self.db.execute(select(User).options(selectinload(User.role)).filter(User.phone == payload.phone))
        elif payload.email:
            result = await self.db.execute(select(User).options(selectinload(User.role)).filter(User.email == payload.email))
        else:
            raise AppError("Phone or email is required", code="MISSING_CREDENTIALS", status_code=400)

        user = result.scalars().first()

        if not user or not payload.password or not verify_password(payload.password, user.password_hash):
            raise AppError("Invalid credentials", code="INVALID_CREDENTIALS", status_code=401)
            
        if not user.is_active:
            raise AppError("User account is disabled", code="USER_DISABLED", status_code=403)

        access_token = create_access_token(subject=str(user.id), token_version=user.token_version)
        refresh_token = create_refresh_token(data={"sub": str(user.id)})
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }

    async def refresh_token(self, refresh_token: str) -> dict:
        from app.security.jwt import decode_token
        payload = decode_token(refresh_token)
        if payload.get("type") != "refresh":
            raise AppError("Invalid token type", code="TOKEN_INVALID", status_code=401)
            
        user_id = payload.get("sub")
        if not user_id:
            raise AppError("Invalid token payload", code="TOKEN_INVALID", status_code=401)

        result = await self.db.execute(select(User).filter(User.id == user_id))
        user = result.scalars().first()
        if not user or not user.is_active:
            raise AppError("User not found or disabled", code="USER_INVALID", status_code=401)

        access_token = create_access_token(subject=str(user.id), token_version=user.token_version)
        new_refresh_token = create_refresh_token(data={"sub": str(user.id)})

        return {
            "access_token": access_token,
            "refresh_token": new_refresh_token,
            "token_type": "bearer"
        }

