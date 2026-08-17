from sqlalchemy import Column, ForeignKey, Boolean, Integer, DateTime, text
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid
import uuid
from datetime import datetime

class CartItem(Base):
    __tablename__ = "cart_items"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id"), nullable=False)
    
    quantity = Column(Integer, default=1)
    is_selected = Column(Boolean, default=True)
    is_saved_for_later = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="cart_items")
    product = relationship("Product")
