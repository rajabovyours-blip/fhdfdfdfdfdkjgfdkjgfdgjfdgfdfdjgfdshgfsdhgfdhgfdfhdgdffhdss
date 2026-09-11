from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from app.db.session import get_db
from app.core.config import settings
from app.models.user import User
from sqlalchemy import select
import jwt

security = HTTPBearer(auto_error=False)

async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: HTTPAuthorizationCredentials = Depends(security)
) -> User:
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
        )

    try:
        payload = jwt.decode(token.credentials, settings.SECRET_KEY, algorithms=["HS256"])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not validate credentials")
    
    try:
        import uuid
        parsed_id = uuid.UUID(user_id)
    except ValueError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token format")
        
    result = await db.execute(select(User).where(User.id == parsed_id))
    user = result.scalar_one_or_none()
    
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    
    return user


async def get_current_user_optional(
    db: AsyncSession = Depends(get_db),
    token: HTTPAuthorizationCredentials = Depends(security)
) -> Optional[User]:
    """Foydalanuvchi kirgan bo'lsa uni qaytaradi, aks holda None.

    Chat uchun kerak: mijoz tizimga KIRMAGAN holda ham yozishi mumkin
    (ism va telefon kiritib). Kirgan bo'lsa — suhbat uning hisobiga
    bog'lanadi va admin javob berganda bildirishnoma yuboriladi.

    Bu funksiya HECH QACHON xato tashlamaydi — token yaroqsiz bo'lsa
    ham shunchaki None qaytaradi, aks holda mehmon foydalanuvchi
    chatdan umuman foydalana olmaydi.
    """
    if not token:
        return None

    try:
        payload = jwt.decode(token.credentials, settings.SECRET_KEY, algorithms=["HS256"])
        user_id = payload.get("sub")
        if not user_id:
            return None

        import uuid
        parsed_id = uuid.UUID(user_id)

        result = await db.execute(select(User).where(User.id == parsed_id))
        return result.scalar_one_or_none()
    except Exception:
        return None


async def get_current_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    """Only allow ADMIN or OWNER roles."""
    from app.models.user import RoleEnum
    if current_user.role not in [RoleEnum.ADMIN, RoleEnum.OWNER]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return current_user
