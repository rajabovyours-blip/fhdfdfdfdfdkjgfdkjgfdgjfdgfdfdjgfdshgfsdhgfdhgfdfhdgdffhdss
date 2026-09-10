from pydantic import BaseModel, ConfigDict
from typing import List, Optional
from datetime import datetime

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
    user_id: Optional[str] = None
    messages: List[ChatMessageModel] = []
    
    model_config = ConfigDict(from_attributes=True)
