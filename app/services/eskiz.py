import httpx
from fastapi import HTTPException
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class EskizService:
    def __init__(self):
        self.base_url = "https://notify.eskiz.uz/api"
        self.email = settings.ESKIZ_EMAIL
        self.password = settings.ESKIZ_PASSWORD
        self._token = None

    async def _authenticate(self) -> str:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/auth/login",
                data={"email": self.email, "password": self.password}
            )
            
            if response.status_code == 200:
                data = response.json()
                self._token = data["data"]["token"]
                return self._token
            else:
                logger.error(f"Eskiz Auth Failed: {response.text}")
                raise HTTPException(status_code=500, detail="SMS gateway authentication failed")

    async def send_sms(self, phone: str, message: str) -> bool:
        if not self.email or not self.password:
            logger.warning("Eskiz credentials missing. SMS skipped.")
            return False

        # Make sure phone number is in digits only (e.g. 998901234567)
        clean_phone = ''.join(filter(str.isdigit, phone))
        
        # Authenticate if token is missing
        if not self._token:
            await self._authenticate()

        async with httpx.AsyncClient() as client:
            headers = {"Authorization": f"Bearer {self._token}"}
            data = {
                "mobile_phone": clean_phone,
                "message": message,
                "from": "4546"
            }
            
            response = await client.post(
                f"{self.base_url}/message/sms/send",
                headers=headers,
                data=data
            )

            if response.status_code == 401:
                # Token might have expired, try refreshing once
                await self._authenticate()
                headers = {"Authorization": f"Bearer {self._token}"}
                response = await client.post(
                    f"{self.base_url}/message/sms/send",
                    headers=headers,
                    data=data
                )

            if response.status_code == 200:
                logger.info(f"SMS successfully sent to {clean_phone}")
                return True
            else:
                logger.error(f"Eskiz SMS Send Failed: {response.text}")
                raise HTTPException(status_code=500, detail=f"Eskiz Error: {response.text}")

eskiz_service = EskizService()
