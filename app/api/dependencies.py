from fastapi import Depends, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from app.core.database import get_db
from app.core.redis import get_redis
from app.core.exceptions import AppError
from app.security.jwt import decode_token
from app.models.users import User, Role
import redis.asyncio as redis
from typing import List, Callable

security = HTTPBearer()

def get_locale(request: Request) -> str:
    lang = request.headers.get("Accept-Language", "uz")
    return lang[:2].lower() if lang else "uz"

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    token = credentials.credentials
    payload = decode_token(token)
    user_id = payload.get("sub")
    
    import uuid
    if not user_id:
        raise AppError("Invalid token payload", code="TOKEN_INVALID", status_code=401)
        
    if payload.get("type") != "access":
        raise AppError("Invalid token type", code="TOKEN_INVALID", status_code=401)
        
    try:
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        raise AppError("Invalid user ID format", code="TOKEN_INVALID", status_code=401)
        
    result = await db.execute(
        select(User).options(selectinload(User.role)).filter(User.id == user_uuid)
    )
    user = result.scalars().first()
    
    if not user:
        raise AppError("User not found", code="USER_NOT_FOUND", status_code=401)
    if not user.is_active:
        raise AppError("User is inactive", code="USER_INACTIVE", status_code=403)
        
    return user

def require_roles(allowed_roles: List[str]) -> Callable:
    async def role_checker(current_user: User = Depends(get_current_user)) -> User:
        if not current_user.role or current_user.role.name not in allowed_roles:
            raise AppError(f"Requires one of roles: {', '.join(allowed_roles)}", code="FORBIDDEN", status_code=403)
        return current_user
    return role_checker

async def get_current_admin(current_user: User = Depends(require_roles(["admin", "owner"]))) -> User:
    return current_user
