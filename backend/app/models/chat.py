from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean, Uuid
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.db.base_class import Base

class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False)
    phone = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_resolved = Column(Boolean, default=False)

    # MUHIM: users.id ustuni Uuid turida. Agar bu yerda String qo'yilsa,
    # PostgreSQL VARCHAR -> UUID tashqi kalitini yarata olmaydi va server
    # ishga tushishda "foreign key constraint cannot be implemented"
    # xatosi bilan qulaydi. Shuning uchun tur AYNAN Uuid bo'lishi shart.
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)

    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan", order_by="ChatMessage.created_at")
    user = relationship("User")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    # chat_sessions.id String bo'lgani uchun bu yerda String to'g'ri.
    session_id = Column(String, ForeignKey("chat_sessions.id", ondelete="CASCADE"), nullable=False)

    sender = Column(String(20), nullable=False)  # 'user' or 'admin'
    text = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    session = relationship("ChatSession", back_populates="messages")
