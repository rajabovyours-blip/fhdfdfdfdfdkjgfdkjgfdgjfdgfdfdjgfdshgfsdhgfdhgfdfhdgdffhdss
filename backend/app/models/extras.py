from sqlalchemy import Column, String, ForeignKey, Boolean, Integer, DateTime, text, JSON
from sqlalchemy.orm import relationship
from app.db.base_class import Base
from sqlalchemy import Uuid
import uuid
from datetime import datetime

class Wishlist(Base):
    __tablename__ = "wishlists"

    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), primary_key=True)
    product_id = Column(Uuid(as_uuid=True), ForeignKey("products.id"), primary_key=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)

class Banner(Base):
    __tablename__ = "banners"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String, nullable=True) # Could be JSONB for localized
    image_url = Column(String, nullable=False)
    link_url = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    order_index = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    body = Column(String, nullable=False)
    image_url = Column(String, nullable=True)
    is_read = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User")


class NotificationBroadcast(Base):
    """Admin panel orqali yuborilgan har bir push xabar uchun BITTA yozuv.

    `Notification` jadvalida har bir qabul qiluvchiga alohida qator
    yaratiladi (fan-out), shuning uchun u admin uchun "yuborilgan
    xabarlar tarixi"ni ko'rsatishga mos emas — bitta broadcast yuzlab
    qatorga aylanadi. Bu jadval esa faqat yuborish faktini saqlaydi.
    """
    __tablename__ = "notification_broadcasts"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String, nullable=False)
    body = Column(String, nullable=False)
    image_url = Column(String, nullable=True)
    target = Column(String(50), default="all")  # all | admins | <user_id>
    recipient_count = Column(Integer, default=0)
    sent_by = Column(Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)


class SearchMiss(Base):
    """Mijoz qidirgan, lekin hech narsa topilmagan so'rovlar.

    MAQSAD: qidiruv o'z-o'zidan yaxshilanib borishi uchun. Admin panelda
    bu ro'yxat ko'rinadi — "odamlar buni shunday deb qidirar ekan" degan
    real ma'lumot. Admin mos mahsulotga bitta so'z qo'shsa (search_keywords),
    keyingi safar aynan shu so'rov topiladi. Hech qanday kod o'zgarishi
    yoki qayta deploy kerak emas.
    """
    __tablename__ = "search_misses"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    term = Column(String, nullable=False)          # foydalanuvchi aynan yozgan matn
    normalized_term = Column(String, nullable=False, index=True)  # takrorlarni yig'ish uchun
    hit_count = Column(Integer, default=1)          # shu so'z necha marta qidirilgan
    resolved = Column(Boolean, default=False)       # admin "ko'rib chiqdim" deb belgilashi mumkin
    last_searched_at = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)


class Payment(Base):
    __tablename__ = "payments"
    
    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id = Column(Uuid(as_uuid=True), ForeignKey("orders.id"), nullable=False)
    provider = Column(String(50), nullable=False)  # "click" | "payme"
    transaction_id = Column(String, nullable=True, unique=True, index=True)  # provider tomonidan berilgan id
    merchant_prepare_id = Column(String, nullable=True)  # faqat Click uchun
    amount = Column(Integer, nullable=False)  # eng kichik birlikda (tiyin)
    status = Column(String(50), default="pending")  # pending | created | performed | cancelled | cancelled_after_perform
    cancel_reason = Column(Integer, nullable=True)
    raw_payload = Column(JSON, nullable=True)  # webhook so'rovining xom nusxasi
    
    perform_time = Column(DateTime, nullable=True)
    cancel_time = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    order = relationship("Order")
