from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Milliy Metr API"
    API_V1_STR: str = "/api/v1"
    PUBLIC_BACKEND_URL: str = "https://milliymetr-backend.onrender.com"
    SECRET_KEY: str = "super_secret_key_change_in_production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days

    # XAVFSIZLIK: /docs, /redoc va /openapi.json sahifalari. Production'da
    # HAR DOIM false bo'lishi kerak — aks holda istalgan odam backend
    # manzilining oxiriga /docs qo'shib, barcha API'larni ko'ra oladi.
    ENABLE_API_DOCS: bool = False

    # Database
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "password"
    POSTGRES_DB: str = "milliy_metr"
    
    # Redis
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_URL: str | None = None

    # Eskiz SMS
    ESKIZ_EMAIL: str = ""
    ESKIZ_PASSWORD: str = ""
    ESKIZ_TEST_MODE: bool = False
    
    # DevSMS 
    DEVSMS_TOKEN: str = ""

    # Click
    CLICK_SERVICE_ID: str = ""
    CLICK_MERCHANT_ID: str = ""
    CLICK_SECRET_KEY: str = ""
    CLICK_MERCHANT_USER_ID: str = ""

    # Payme
    PAYME_MERCHANT_ID: str = ""
    PAYME_KEY: str = ""

    # ── Yetkazib berish (shipping) ────────────────────────────────
    # Asosiy narx endi HAR BIR MAHSULOTGA admin panelda belgilanadi
    # (products.has_delivery / products.delivery_price).
    # Quyidagilar faqat umumiy qoidalar:
    #   DELIVERY_ENABLED        — butun tizim bo'yicha yetkazib berishni o'chirish
    #   FREE_SHIPPING_THRESHOLD — shu summadan katta buyurtmaga yetkazish bepul
    #   SHIPPING_FEE            — mahsulotda narx belgilanmagan bo'lsa, zaxira qiymat
    DELIVERY_ENABLED: bool = True
    SHIPPING_FEE: float = 0.0
    FREE_SHIPPING_THRESHOLD: float = 500000.0

    DATABASE_URL: str | None = None

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        fallback = "sqlite+aiosqlite:///./milliy_metr.db"
        
        if self.DATABASE_URL:
            # Check if it's a valid URL format for SQLAlchemy
            if self.DATABASE_URL.startswith("postgres://"):
                return self.DATABASE_URL.replace("postgres://", "postgresql+asyncpg://", 1)
            elif self.DATABASE_URL.startswith("postgresql://"):
                return self.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)
            elif self.DATABASE_URL.startswith("sqlite"):
                return self.DATABASE_URL
            
            # If it's something completely invalid (e.g. random base64 string from Render)
            print(f"WARNING: Invalid DATABASE_URL provided. Falling back to SQLite.")
            
        if self.POSTGRES_SERVER and self.POSTGRES_SERVER != "localhost":
            return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}/{self.POSTGRES_DB}"
            
        return fallback

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
