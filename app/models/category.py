from sqlalchemy import Column, String, ForeignKey, Boolean, Integer, text
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid, JSON
import uuid

class Category(Base):
    __tablename__ = "categories"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(JSON, nullable=False) # {"uz": "", "ru": "", "en": ""}
    description = Column(JSON, nullable=False)
    icon_url = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    parent_id = Column(Uuid(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    is_featured = Column(Boolean, default=False)
    order_index = Column(Integer, default=0)

    # Relationships
    subcategories = relationship("Category", backref="parent", remote_side=[id])
    products = relationship("Product", foreign_keys="[Product.category_id]", back_populates="category")
