import uuid
from sqlalchemy import Column, String, ForeignKey, Text, Float, Integer
from sqlalchemy.orm import relationship
from sqlalchemy import Uuid
from app.models.base import Base, TimestampMixin

class Order(Base, TimestampMixin):
    __tablename__ = "orders"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    status = Column(String(50), default="pending") # pending, processing, shipped, delivered, cancelled
    total_amount = Column(Float, nullable=False)
    shipping_address_id = Column(Uuid(as_uuid=True), ForeignKey("addresses.id", ondelete="SET NULL"), nullable=True)

    user = relationship("User", back_populates="orders")
    shipping_address = relationship("Address")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
    payment = relationship("Payment", back_populates="order", uselist=False)
    reviews = relationship("Review", back_populates="order", cascade="all, delete-orphan")

class OrderItem(Base, TimestampMixin):
    __tablename__ = "order_items"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id = Column(Uuid(as_uuid=True), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id", ondelete="RESTRICT"), nullable=False)
    quantity = Column(Integer, nullable=False)
    price = Column(Float, nullable=False) # Price at time of order
    
    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")

class Payment(Base, TimestampMixin):
    __tablename__ = "payments"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id = Column(Uuid(as_uuid=True), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False, unique=True)
    payment_method_id = Column(Integer, nullable=False) # e.g. 1=Card, 2=Cash
    amount = Column(Float, nullable=False)
    status = Column(String(50), default="pending") # pending, completed, failed
    transaction_id = Column(String(255), nullable=True)

    order = relationship("Order", back_populates="payment")

class Review(Base, TimestampMixin):
    __tablename__ = "reviews"
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    order_id = Column(Uuid(as_uuid=True), ForeignKey("orders.id", ondelete="CASCADE"), nullable=True)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id", ondelete="CASCADE"), nullable=True)
    rating = Column(Integer, nullable=False) # 1 to 5
    comment = Column(Text, nullable=True)

    user = relationship("User", back_populates="reviews")
    order = relationship("Order", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")
