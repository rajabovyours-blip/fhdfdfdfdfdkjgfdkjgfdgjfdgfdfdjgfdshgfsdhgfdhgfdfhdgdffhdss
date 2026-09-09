from fastapi import APIRouter
from app.schemas.common import APIResponse
from app.core.config import settings

router = APIRouter()


@router.get("/shipping", response_model=APIResponse[dict])
async def get_shipping_settings():
    """Public endpoint so the app can always show the current, real shipping
    price without needing a new APK build whenever it changes on the server."""
    return APIResponse(data={
        "delivery_enabled": settings.DELIVERY_ENABLED,
        "shipping_fee": settings.SHIPPING_FEE,
        "free_shipping_threshold": settings.FREE_SHIPPING_THRESHOLD,
    })
