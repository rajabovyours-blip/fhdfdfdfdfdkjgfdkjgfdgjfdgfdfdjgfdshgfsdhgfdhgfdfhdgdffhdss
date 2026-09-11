from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean, Uuid
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.db.base_class import Base


class ChatSession(Base):
    """Mijoz bilan yozishma sessiyasi.

    DIQQAT (deploy tarixi): bu jadval avval 3 marta deploy'ni qulatgan.
    Sababi — user_id ustuni String (VARCHAR) deb e'lon qilingan edi,
    users.id esa UUID. PostgreSQL VARCHAR -> UUID tashqi kalitini
    yarata olmaydi:
        "foreign key constraint chat_sessions_user_id_fkey
         cannot be implemented ... character varying and uuid"
    Shuning uchun user_id AYNAN Uuid bo'lishi shart. O'zgartirmang.
    """

    __tablename__ = "chat_sessions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False)
    phone = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_resolved = Column(Boolean, default=False)

    # users.id bilan bir xil tur bo'lishi SHART (yuqoridagi izohga qarang)
    user_id = Column(
        Uuid(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    messages = relationship(
        "ChatMessage",
        back_populates="session",
        cascade="all, delete-orphan",
        order_by="ChatMessage.created_at",
    )
    user = relationship("User")


class ChatMessage(Base):
    """Sessiya ichidagi bitta xabar (mijozdan yoki admindan)."""

    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    # chat_sessions.id String bo'lgani uchun bu yerda ham String — to'g'ri.
    session_id = Column(
        String,
        ForeignKey("chat_sessions.id", ondelete="CASCADE"),
        nullable=False,
    )

    sender = Column(String(20), nullable=False)  # 'user' yoki 'admin'
    text = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    session = relationship("ChatSession", back_populates="messages")
