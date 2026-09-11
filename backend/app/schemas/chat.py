from pydantic import BaseModel, ConfigDict, field_serializer
from typing import List, Optional
from datetime import datetime
import uuid

class ChatMessageBase(BaseModel):
    text: str

class ChatMessageCreate(ChatMessageBase):
    pass

class ChatMessageModel(ChatMessageBase):
    id: str
    session_id: str
    sender: str
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ChatSessionBase(BaseModel):
    name: str
    phone: str

class ChatSessionCreate(ChatSessionBase):
    pass

class ChatSessionModel(ChatSessionBase):
    id: str
    created_at: datetime
    updated_at: datetime
    is_resolved: bool

    # users.id UUID turida, shuning uchun bu yerda ham UUID.
    # JSON'ga chiqarishda matnga o'giriladi (ilova va admin panel matn kutadi).
    user_id: Optional[uuid.UUID] = None

    messages: List[ChatMessageModel] = []

    model_config = ConfigDict(from_attributes=True)

    @field_serializer("user_id")
    def _serialize_user_id(self, value: Optional[uuid.UUID]) -> Optional[str]:
        return str(value) if value else None
