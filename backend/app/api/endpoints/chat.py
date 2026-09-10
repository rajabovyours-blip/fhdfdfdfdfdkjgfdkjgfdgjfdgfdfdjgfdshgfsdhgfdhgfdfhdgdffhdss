from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from typing import List, Optional
import uuid

from app.db.session import get_db
from app.models.chat import ChatSession, ChatMessage
from app.schemas.chat import ChatSessionCreate, ChatSessionModel, ChatMessageCreate, ChatMessageModel
from app.schemas.common import APIResponse
from app.api.deps import get_current_user_optional, get_current_admin

router = APIRouter()

# ----------------- Customer Endpoints -----------------

@router.post("/start", response_model=APIResponse[ChatSessionModel])
async def start_chat_session(
    payload: ChatSessionCreate,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user_optional)
):
    """Start a new chat session."""
    session = ChatSession(
        id=str(uuid.uuid4()),
        name=payload.name,
        phone=payload.phone,
        user_id=current_user.id if current_user else None
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return APIResponse(data=ChatSessionModel.model_validate(session))


@router.get("/{session_id}/messages", response_model=APIResponse[List[ChatMessageModel]])
async def get_chat_messages(
    session_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get all messages for a specific chat session."""
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
    )
    messages = result.scalars().all()
    return APIResponse(data=[ChatMessageModel.model_validate(m) for m in messages])


@router.post("/{session_id}/messages", response_model=APIResponse[ChatMessageModel])
async def send_chat_message(
    session_id: str,
    payload: ChatMessageCreate,
    db: AsyncSession = Depends(get_db)
):
    """Send a message as a user."""
    # Verify session exists
    result = await db.execute(select(ChatSession).where(ChatSession.id == session_id))
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
        
    message = ChatMessage(
        id=str(uuid.uuid4()),
        session_id=session_id,
        sender="user",
        text=payload.text
    )
    db.add(message)
    await db.commit()
    await db.refresh(message)
    return APIResponse(data=ChatMessageModel.model_validate(message))


# ----------------- Admin Endpoints -----------------

@router.get("/admin/sessions", response_model=APIResponse[List[ChatSessionModel]])
async def admin_get_sessions(
    is_resolved: Optional[bool] = None,
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_current_admin)
):
    """Get all chat sessions (Admin only)."""
    query = select(ChatSession).options(selectinload(ChatSession.messages)).order_by(ChatSession.updated_at.desc())
    if is_resolved is not None:
        query = query.where(ChatSession.is_resolved == is_resolved)
        
    result = await db.execute(query)
    sessions = result.scalars().all()
    return APIResponse(data=[ChatSessionModel.model_validate(s) for s in sessions])


@router.post("/admin/{session_id}/messages", response_model=APIResponse[ChatMessageModel])
async def admin_send_message(
    session_id: str,
    payload: ChatMessageCreate,
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_current_admin)
):
    """Send a message as an admin."""
    # Verify session exists
    result = await db.execute(select(ChatSession).where(ChatSession.id == session_id))
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
        
    message = ChatMessage(
        id=str(uuid.uuid4()),
        session_id=session_id,
        sender="admin",
        text=payload.text
    )
    db.add(message)
    
    # Update session's updated_at
    from datetime import datetime
    session.updated_at = datetime.utcnow()
    session.is_resolved = False # automatically unresolve if admin replies
    
    await db.commit()
    await db.refresh(message)
    return APIResponse(data=ChatMessageModel.model_validate(message))
    

@router.put("/admin/{session_id}/resolve", response_model=APIResponse[dict])
async def admin_resolve_session(
    session_id: str,
    db: AsyncSession = Depends(get_db),
    admin_user = Depends(get_current_admin)
):
    """Mark a chat session as resolved."""
    result = await db.execute(select(ChatSession).where(ChatSession.id == session_id))
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
        
    session.is_resolved = True
    await db.commit()
    return APIResponse(message="Session marked as resolved")
