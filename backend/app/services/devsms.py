import httpx
from fastapi import HTTPException
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class DevSmsService:
    def __init__(self):
        self.base_url = "https://devsms.uz/api"
        self.token = settings.DEVSMS_TOKEN

    async def send_sms(self, phone: str, message: str) -> bool:
        if not self.token:
            logger.warning("DevSMS token missing. SMS skipped.")
            return False

        # Ensure phone number is digits only (e.g. 998901234567)
        clean_phone = ''.join(filter(str.isdigit, phone))

        # DevSMS expects 12-digit Uzbek number starting with 998
        if not clean_phone.startswith("998"):
            clean_phone = "998" + clean_phone.lstrip("0")

        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json",
        }
        payload = {
            "phone": clean_phone,
            "message": message,
        }

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.post(
                    f"{self.base_url}/send_sms.php",
                    headers=headers,
                    json=payload,
                )

                if response.status_code == 200:
                    data = response.json()
                    # DevSMS returns {"success": true, ...} on success
                    if data.get("success") or data.get("status") == "success":
                        logger.info(f"SMS successfully sent to {clean_phone} via DevSMS")
                        return True
                    else:
                        error_msg = data.get("message") or data.get("error") or str(data)
                        logger.error(f"DevSMS API error: {error_msg}")
                        raise HTTPException(
                            status_code=500,
                            detail=f"SMS yuborishda xatolik: {error_msg}",
                        )
                else:
                    logger.error(
                        f"DevSMS HTTP {response.status_code}: {response.text}"
                    )
                    raise HTTPException(
                        status_code=500,
                        detail=f"SMS gateway xatosi (HTTP {response.status_code})",
                    )
        except httpx.TimeoutException:
            logger.error("DevSMS request timed out")
            raise HTTPException(status_code=504, detail="SMS gateway javob bermadi (timeout)")
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"DevSMS unexpected error: {e}")
            raise HTTPException(status_code=500, detail=f"SMS yuborishda kutilmagan xatolik: {e}")

    async def get_balance(self) -> dict:
        """Check remaining SMS balance on DevSMS account."""
        if not self.token:
            return {"balance": "N/A", "error": "Token missing"}

        headers = {"Authorization": f"Bearer {self.token}"}
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(
                    f"{self.base_url}/get_balance.php",
                    headers=headers,
                )
                if response.status_code == 200:
                    return response.json()
                return {"error": f"HTTP {response.status_code}"}
        except Exception as e:
            return {"error": str(e)}


devsms_service = DevSmsService()
