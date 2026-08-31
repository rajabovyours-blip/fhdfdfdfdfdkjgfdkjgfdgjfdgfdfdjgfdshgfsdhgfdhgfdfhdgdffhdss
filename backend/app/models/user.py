from sqlalchemy import Column, String, Boolean, DateTime, Enum, text
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid
import uuid
import enum
from datetime import datetime

class RoleEnum(str, enum.Enum):
    USER = "USER"
    ADMIN = "ADMIN"
    OWNER = "OWNER"

class User(Base):
    __tablename__ = "users"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(255), unique=True, index=True, nullable=True)
    full_name = Column(String(255), nullable=False)
    phone = Column(String(20), unique=True, index=True, nullable=True)
    email = Column(String(255), unique=True, index=True, nullable=True)
    hashed_password = Column(String, nullable=False)
    avatar_url = Column(String, nullable=True)
    role = Column(Enum(RoleEnum, native_enum=False, length=50), default=RoleEnum.USER, nullable=False)
    is_active = Column(Boolean, default=True)
    provider = Column(String, nullable=True)
    provider_id = Column(String, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    orders = relationship("Order", back_populates="user")
    reviews = relationship("Review", back_populates="user")
    cart_items = relationship("CartItem", back_populates="user")
    addresses = relationship("Address", back_populates="user")
