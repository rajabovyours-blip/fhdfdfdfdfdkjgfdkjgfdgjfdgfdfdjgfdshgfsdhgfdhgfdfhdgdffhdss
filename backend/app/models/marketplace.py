import uuid
from sqlalchemy import Column, String, ForeignKey, Text, Float, Integer, Boolean, Table
from sqlalchemy.orm import relationship
from sqlalchemy import Uuid
from app.models.base import Base, TimestampMixin
from app.models.users import User
from app.models.orders import OrderItem
from app.models.review import Review

class Category(Base, TimestampMixin):
    __tablename__ = "categories"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    parent_id = Column(Uuid(as_uuid=True), ForeignKey("categories.id", ondelete="SET NULL"), nullable=True)
    name_uz = Column(String(255), nullable=False)
    name_ru = Column(String(255), nullable=False, default="")
    name_en = Column(String(255), nullable=False, default="")
    icon_url = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)

    parent = relationship("Category", remote_side=[id], back_populates="subcategories")
    subcategories = relationship("Category", back_populates="parent")
    products = relationship("Product", back_populates="category")

class Product(Base, TimestampMixin):
    __tablename__ = "products"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_by_id = Column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    category_id = Column(Uuid(as_uuid=True), ForeignKey("categories.id", ondelete="RESTRICT"), nullable=False)
    name_uz = Column(String(255), nullable=False, index=True)
    name_ru = Column(String(255), nullable=False, default="", index=True)
    name_en = Column(String(255), nullable=False, default="", index=True)
    description_uz = Column(Text, nullable=True)
    description_ru = Column(Text, nullable=True)
    description_en = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    old_price = Column(Float, nullable=True)
    stock = Column(Integer, default=0)
    status = Column(String(50), default="pending") # pending, approved, rejected
    rating = Column(Float, default=0.0)

    created_by = relationship("User")
    category = relationship("Category", back_populates="products")
    images = relationship("ProductImage", back_populates="product", cascade="all, delete-orphan")
    order_items = relationship("OrderItem", back_populates="product")
    reviews = relationship("Review", back_populates="product")

class ProductImage(Base, TimestampMixin):
    __tablename__ = "product_images"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    image_url = Column(Text, nullable=False)
    is_primary = Column(Boolean, default=False)

    product = relationship("Product", back_populates="images")

# Wishlist is simply a many-to-many relationship table in our setup
wishlist_table = Table(
    "wishlist",
    Base.metadata,
    Column("user_id", Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
    Column("product_id", Uuid(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), primary_key=True)
)

class Cart(Base, TimestampMixin):
    __tablename__ = "carts"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    total_price = Column(Float, default=0.0)
    
    items = relationship("CartItem", back_populates="cart", cascade="all, delete-orphan")

class CartItem(Base, TimestampMixin):
    __tablename__ = "cart_items"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cart_id = Column(Uuid(as_uuid=True), ForeignKey("carts.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    quantity = Column(Integer, default=1)
    price = Column(Float, nullable=False) # Price at time of adding

    cart = relationship("Cart", back_populates="items")
    product = relationship("Product")
