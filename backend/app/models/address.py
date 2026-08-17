from sqlalchemy import Column, String, ForeignKey, Boolean, Float, DateTime, text
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid
import uuid
from datetime import datetime

class Address(Base):
    __tablename__ = "addresses"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    label = Column(String(50), nullable=True) # Home, Work, etc.
    address_line = Column(String, nullable=False)
    lat = Column(Float, nullable=True)
    lng = Column(Float, nullable=True)
    is_default = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="addresses")
