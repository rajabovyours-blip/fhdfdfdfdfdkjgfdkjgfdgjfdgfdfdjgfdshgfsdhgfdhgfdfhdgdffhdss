from sqlalchemy import Column, String, ForeignKey, Integer, Numeric, DateTime, Boolean, JSON, text
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

    # Ilova "Оставить отзыв" formasida yig'iladigan qo'shimcha ma'lumot.
    # Avval bularni saqlaydigan ustun umuman yo'q edi — mijoz rasm va
    # teglar bilan sharh yuborsa ham, ular jimgina yo'qolib ketardi.
    photos = Column(JSON, default=list)       # server URL'lari ro'yxati
    templates = Column(JSON, default=list)    # "Narxiga arziydi" kabi tanlangan teglar
    would_buy_again = Column(Boolean, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")
