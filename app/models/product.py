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
    images = Column(JSON, default=list)
    videos = Column(JSON, default=list)
    brand = Column(String, nullable=True)
    
    category_id = Column(Uuid(as_uuid=True), ForeignKey("categories.id"), nullable=False)
    subcategory_id = Column(Uuid(as_uuid=True), ForeignKey("categories.id"), nullable=True)    
    price = Column(Numeric(12, 2), nullable=False)
    old_price = Column(Numeric(12, 2), nullable=True)
    currency = Column(String(10), default="UZS")
    unit = Column(String(20), default="pcs")
    moq = Column(Integer, default=1)
    stock = Column(Integer, default=0)
    stock_status = Column(String(50), default="in_stock")
    
    rating = Column(Numeric(3, 2), default=0.0)
    review_count = Column(Integer, default=0)
    discount = Column(Numeric(5, 2), nullable=True)
    
    specifications = Column(JSON, nullable=True)
    certificates = Column(String, nullable=True)
    delivery_information = Column(String, nullable=True)
    location = Column(String, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    category = relationship("Category", foreign_keys=[category_id], back_populates="products")
    reviews = relationship("Review", back_populates="product")

from sqlalchemy import Table, Column, ForeignKey, Uuid
wishlist_table = Table(
    "wishlist",
    Base.metadata,
    Column("user_id", Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
    Column("product_id", Uuid(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), primary_key=True)
)
