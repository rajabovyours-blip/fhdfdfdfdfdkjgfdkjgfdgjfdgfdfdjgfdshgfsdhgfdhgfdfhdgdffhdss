import random
import time
import logging
from fastapi import HTTPException
from pydantic import BaseModel

logger = logging.getLogger(__name__)

class OTPData(BaseModel):
    otp: str
    expires_at: float
    resend_cooldown_until: float
    attempts: int = 0

class OTPService:
    def __init__(self):
        # We use an in-memory dictionary to store OTPs mapping phone -> OTPData
        # This is safe for single-worker local testing. In production, use Redis.
        self.store = {}
        self.EXPIRATION_SECONDS = 120 # 2 minutes
        self.COOLDOWN_SECONDS = 60 # 1 minute
        self.MAX_ATTEMPTS = 3

    def generate_otp(self) -> str:
        # Cryptographically secure OTP generation (simulated with random for now)
        import secrets
        return str(secrets.randbelow(1000000)).zfill(6)

    def request_otp(self, phone: str) -> str:
        now = time.time()
        
        # Check cooldown
        if phone in self.store:
            existing = self.store[phone]
            if now < existing.resend_cooldown_until:
                remaining = int(existing.resend_cooldown_until - now)
                raise HTTPException(status_code=429, detail=f"Please wait {remaining} seconds before requesting again.")
                
        otp_code = self.generate_otp()
        self.store[phone] = OTPData(
            otp=otp_code,
            expires_at=now + self.EXPIRATION_SECONDS,
            resend_cooldown_until=now + self.COOLDOWN_SECONDS,
            attempts=0
        )
        
        # We log that OTP was requested, but NOT the code itself in production!
        logger.info(f"OTP generated for {phone}")
        return otp_code

    def verify_otp(self, phone: str, otp: str) -> bool:
        now = time.time()
        
        if phone not in self.store:
            raise HTTPException(status_code=400, detail="No OTP requested for this number.")
            
        record = self.store[phone]
        
        # Check expiration
        if now > record.expires_at:
            del self.store[phone]
            raise HTTPException(status_code=400, detail="OTP has expired. Please request a new one.")
            
        # Check attempts
        if record.attempts >= self.MAX_ATTEMPTS:
            del self.store[phone]
            raise HTTPException(status_code=400, detail="Too many failed attempts. Please request a new OTP.")
            
        record.attempts += 1
        
        # Verify code
        if record.otp == otp:
            # OTP is correct. Invalidate it for single-use.
            del self.store[phone]
            return True
        else:
            raise HTTPException(status_code=400, detail="Invalid OTP code.")

otp_service = OTPService()
