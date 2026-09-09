"""Admin panel orqali o'zgartiriladigan sozlamalar.

Yetkazib berish narxi endi Render env emas, bazada saqlanadi va
admin panelidan o'zgartiriladi. Env qiymatlari faqat birinchi marta
(baza bo'sh bo'lganda) boshlang'ich qiymat sifatida ishlatiladi.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, Field
from typing import Optional

from app.db.session import get_db
from app.models.app_settings import AppSetting
from app.models.user import User
from app.schemas.common import APIResponse
from app.core.config import settings as env_settings
from app.api.dependencies import get_current_admin

router = APIRouter()

# Sozlama kalitlari va ularning env'dagi zaxira qiymatlari
DEFAULTS = {
    "delivery_enabled": lambda: "true" if env_settings.DELIVERY_ENABLED else "false",
    "shipping_fee": lambda: str(env_settings.SHIPPING_FEE),
    "free_shipping_threshold": lambda: str(env_settings.FREE_SHIPPING_THRESHOLD),
}


async def get_setting(db: AsyncSession, key: str) -> str:
    """Bitta sozlamani o'qiydi. Bazada yo'q bo'lsa env'dan oladi."""
    row = (await db.execute(select(AppSetting).where(AppSetting.key == key))).scalar_one_or_none()
    if row is not None and row.value is not None:
        return row.value
    default = DEFAULTS.get(key)
    return default() if default else ""


async def load_shipping_settings(db: AsyncSession) -> dict:
    """Yetkazib berish sozlamalarini to'g'ri turlarda qaytaradi."""
    enabled = (await get_setting(db, "delivery_enabled")).strip().lower() in ("true", "1", "yes")
    try:
        fee = float(await get_setting(db, "shipping_fee") or 0)
    except ValueError:
        fee = 0.0
    try:
        threshold = float(await get_setting(db, "free_shipping_threshold") or 0)
    except ValueError:
        threshold = 0.0
    return {
        "delivery_enabled": enabled,
        "shipping_fee": fee,
        "free_shipping_threshold": threshold,
    }


async def set_setting(db: AsyncSession, key: str, value: str) -> None:
    row = (await db.execute(select(AppSetting).where(AppSetting.key == key))).scalar_one_or_none()
    if row:
        row.value = value
    else:
        db.add(AppSetting(key=key, value=value))


# ── Ochiq endpoint: ilova ko'rsatish uchun o'qiydi ────────────────────

@router.get("/shipping", response_model=APIResponse[dict])
async def get_shipping_settings(db: AsyncSession = Depends(get_db)):
    return APIResponse(data=await load_shipping_settings(db))


# ── Admin endpointlari ───────────────────────────────────────────────

class ShippingSettingsUpdate(BaseModel):
    delivery_enabled: Optional[bool] = Field(default=None, alias="deliveryEnabled")
    shipping_fee: Optional[float] = Field(default=None, alias="shippingFee")
    free_shipping_threshold: Optional[float] = Field(default=None, alias="freeShippingThreshold")

    model_config = {"populate_by_name": True}


@router.get("/admin", response_model=APIResponse[dict])
async def admin_get_settings(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    data = await load_shipping_settings(db)
    return APIResponse(data={
        "deliveryEnabled": data["delivery_enabled"],
        "shippingFee": data["shipping_fee"],
        "freeShippingThreshold": data["free_shipping_threshold"],
    })


@router.put("/admin", response_model=APIResponse[dict])
async def admin_update_settings(
    payload: ShippingSettingsUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    if payload.delivery_enabled is not None:
        await set_setting(db, "delivery_enabled", "true" if payload.delivery_enabled else "false")
    if payload.shipping_fee is not None:
        await set_setting(db, "shipping_fee", str(max(0.0, payload.shipping_fee)))
    if payload.free_shipping_threshold is not None:
        await set_setting(db, "free_shipping_threshold", str(max(0.0, payload.free_shipping_threshold)))

    await db.commit()

    data = await load_shipping_settings(db)
    return APIResponse(message="Sozlamalar saqlandi", data={
        "deliveryEnabled": data["delivery_enabled"],
        "shippingFee": data["shipping_fee"],
        "freeShippingThreshold": data["free_shipping_threshold"],
    })
