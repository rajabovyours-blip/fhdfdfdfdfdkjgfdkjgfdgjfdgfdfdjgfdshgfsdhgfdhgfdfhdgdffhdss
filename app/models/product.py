from sqlalchemy import Column, String, ForeignKey, Boolean, Integer, Numeric, DateTime, text
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid as Uuid, JSON, String
import uuid
from datetime import datetime

class Product(Base):
    __tablename__ = "products"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sku = Column(String, nullable=True, unique=True, index=True)
    name = Column(JSON, nullable=False)
    description = Column(JSON, nullable=False)
    images = Column(String, default="[]")
    videos = Column(String, default="[]")
    brand = Column(String, nullable=True)
    
    category_id = Column(Uuid(as_uuid=True), ForeignKey("categories.id"), nullable=False)
    subcategoryId = Column(Uuid(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    seller_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    price = Column(Numeric(12, 2), nullable=False)
    oldPrice = Column(Numeric(12, 2), nullable=True)
    currency = Column(String(10), default="UZS")
    unit = Column(String(20), default="pcs")
    moq = Column(Integer, default=1)
    stock = Column(Integer, default=0)
    stockStatus = Column(String(50), default="in_stock")
    
    rating = Column(Numeric(3, 2), default=0.0)
    reviewCount = Column(Integer, default=0)
    discount = Column(Numeric(5, 2), nullable=True)
    
    specifications = Column(JSON, nullable=True)
    certificates = Column(String, nullable=True)
    deliveryInformation = Column(String, nullable=True)
    location = Column(String, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    category = relationship("Category", foreign_keys=[category_id], back_populates="products")
    reviews = relationship("Review", back_populates="product")
