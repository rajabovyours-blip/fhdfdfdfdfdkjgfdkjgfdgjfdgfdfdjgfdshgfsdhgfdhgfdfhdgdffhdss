from pydantic import BaseModel
from typing import Optional
from uuid import UUID

class TokenModel(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
