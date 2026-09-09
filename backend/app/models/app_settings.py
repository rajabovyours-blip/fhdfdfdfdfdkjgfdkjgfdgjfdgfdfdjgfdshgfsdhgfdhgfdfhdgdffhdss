from sqlalchemy import Column, String, DateTime
from datetime import datetime

from app.db.base_class import Base


class AppSetting(Base):
    """Admin panel orqali o'zgartiriladigan sozlamalar.

    Kalit-qiymat ko'rinishida saqlanadi, shuning uchun yangi sozlama
    qo'shish uchun migratsiya kerak emas. Qiymat har doim matn sifatida
    saqlanadi, o'qiyotganda kerakli turga o'giriladi.
    """

    __tablename__ = "app_settings"

    key = Column(String(100), primary_key=True)
    value = Column(String, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
