from fastapi import Depends, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.core.exceptions import AppError
from app.security.jwt import decode_token
from app.models.user import User
from typing import List, Callable
import uuid

security = HTTPBearer(auto_error=False)

def get_locale(request: Request) -> str:
    lang = request.headers.get("Accept-Language", "uz")
    return lang[:2].lower() if lang else "uz"

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    if not credentials:
        raise AppError("Authentication required", code="AUTH_REQUIRED", status_code=401)
        
    token = credentials.credentials
    payload = decode_token(token)
    user_id = payload.get("sub")
    
    if not user_id:
        raise AppError("Invalid token payload", code="TOKEN_INVALID", status_code=401)
        
    if payload.get("type") != "access":
        raise AppError("Invalid token type", code="TOKEN_INVALID", status_code=401)
        
    try:
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        raise AppError("Invalid user ID format", code="TOKEN_INVALID", status_code=401)
        
    result = await db.execute(
        select(User).filter(User.id == user_uuid)
    )
    user = result.scalars().first()
    
    if not user:
        raise AppError("User not found", code="USER_NOT_FOUND", status_code=401)
    if not user.is_active:
        raise AppError("User is inactive", code="USER_INACTIVE", status_code=403)
        
    return user

def require_roles(allowed_roles: List[str]) -> Callable:
    async def role_checker(current_user: User = Depends(get_current_user)) -> User:
        user_role = current_user.role
        # Handle both string enum value and enum .name
        role_value = user_role.value if hasattr(user_role, 'value') else str(user_role)
        if role_value not in allowed_roles:
            raise AppError(f"Requires one of roles: {', '.join(allowed_roles)}", code="FORBIDDEN", status_code=403)
        return current_user
    return role_checker

async def get_current_admin(current_user: User = Depends(require_roles(["ADMIN", "OWNER"]))) -> User:
    return current_user

async def get_current_owner(current_user: User = Depends(require_roles(["OWNER"]))) -> User:
    return current_user
