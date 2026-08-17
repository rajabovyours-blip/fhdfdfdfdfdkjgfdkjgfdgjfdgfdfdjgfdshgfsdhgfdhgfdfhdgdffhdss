from sqlalchemy import Column, String, ForeignKey, Integer, Numeric, DateTime, text
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid
import uuid
from datetime import datetime

class Review(Base):
    __tablename__ = "reviews"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id"), nullable=False)
    
    rating = Column(Numeric(3, 2), nullable=False)
    comment = Column(String, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")
