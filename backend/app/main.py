from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from contextlib import asynccontextmanager

from app.core.config import settings
from app.db.base_class import Base
from app.db.session import engine
# Import all models to ensure they are registered with Base.metadata
from app.models.user import User
from app.models.category import Category
from app.models.product import Product
from app.models.review import Review
from app.models.order import Order
from app.models.extras import Payment
from app.db.session import AsyncSessionLocal
from app.db.seed import seed_data

from sqlalchemy import text
import asyncio
from datetime import datetime, timedelta
from sqlalchemy import select, func
from sqlalchemy.orm import joinedload

async def _abandoned_order_cleanup_loop():
    """Every 10 minutes, cancel and restore stock for orders that have been
    sitting unpaid (payme/click) for more than 30 minutes with no webhook received."""
    from app.models.order import Order
    from app.api.endpoints.orders import _restore_order_stock

    while True:
        try:
            async with AsyncSessionLocal() as db:
                cutoff = datetime.utcnow() - timedelta(minutes=30)
                result = await db.execute(
                    select(Order)
                    .options(joinedload(Order.items))
                    .where(
                        Order.created_at < cutoff,
                        func.lower(Order.status) == "pending",
                        func.lower(Order.payment_method).in_(["payme", "click"]),
                        func.lower(Order.payment_status).in_(["pending", "waiting"]),
                    )
                )
                stale_orders = result.unique().scalars().all()
                for order in stale_orders:
                    order.status = "Cancelled"
                    order.payment_status = "Cancelled"
                    await _restore_order_stock(order, db)
                if stale_orders:
                    await db.commit()
                    print(f"[abandoned_order_cleanup] cancelled {len(stale_orders)} stale order(s), stock restored")
        except Exception as e:
            print(f"[abandoned_order_cleanup] error: {e}")
        await asyncio.sleep(600)  # 10 minutes


async def _backfill_search_text():
    """search_text bo'sh mahsulotlar uchun uni hisoblab qo'yadi.

    Yangi ustun qo'shilgach mavjud mahsulotlarda u bo'sh bo'ladi va ular
    qidiruvda umuman chiqmaydi. Shu funksiya bir marta to'ldirib beradi.
    Faqat bo'shlari olinadi, shuning uchun har ishga tushishda qayta
    hisoblanmaydi.
    """
    from app.models.product import Product as _P
    from app.models.category import Category as _C
    from app.utils.search_helpers import build_search_text

    async with AsyncSessionLocal() as db:
        rows = (await db.execute(
            select(_P).where((_P.search_text.is_(None)) | (_P.search_text == ""))
        )).scalars().all()
        if not rows:
            return

        cats = {c.id: c.name for c in (await db.execute(select(_C))).scalars().all()}
        for p in rows:
            p.search_text = build_search_text(p, cats.get(p.category_id))
        await db.commit()
        print(f"[search] {len(rows)} ta mahsulot uchun search_text to'ldirildi")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize database tables
    
    # Idempotently add missing columns for production upgrades
    # Separate blocks are used so that if a column already exists,
    # the transaction abort doesn't crash the entire startup process.
    try:
        async with engine.begin() as conn:
            await conn.execute(text('ALTER TABLE users ADD COLUMN username VARCHAR(255)'))
    except Exception:
        pass
        
    try:
        async with engine.begin() as conn:
            await conn.execute(text('ALTER TABLE users ADD CONSTRAINT users_username_key UNIQUE (username)'))
    except Exception:
        pass

    try:
        async with engine.begin() as conn:
            await conn.execute(text("ALTER TABLE users ADD COLUMN role VARCHAR DEFAULT 'USER'"))
    except Exception:
        pass
        
    try:
        async with engine.begin() as conn:
            await conn.execute(text("ALTER TABLE users ALTER COLUMN role TYPE VARCHAR USING role::text"))
    except Exception:
        pass
        
    try:
        async with engine.begin() as conn:
            await conn.execute(text("ALTER TABLE users ADD COLUMN preferred_language VARCHAR DEFAULT 'uz'"))
    except Exception:
        pass
        
    try:
        async with engine.begin() as conn:
            await conn.execute(text("ALTER TABLE users ADD COLUMN token_version INTEGER DEFAULT 0 NOT NULL"))
    except Exception:
        pass
    
    # Payment table migrations
    for col_sql in [
        "ALTER TABLE payments ADD COLUMN merchant_prepare_id VARCHAR",
        "ALTER TABLE payments ADD COLUMN cancel_reason INTEGER",
        "ALTER TABLE payments ADD COLUMN raw_payload JSON",
        "ALTER TABLE payments ADD COLUMN perform_time TIMESTAMP",
        "ALTER TABLE payments ADD COLUMN cancel_time TIMESTAMP",
    ]:
        try:
            async with engine.begin() as conn:
                await conn.execute(text(col_sql))
        except Exception:
            pass

    # Product delivery columns (per-product delivery settings)
    for col_sql in [
        "ALTER TABLE products ADD COLUMN has_delivery BOOLEAN DEFAULT TRUE",
        "ALTER TABLE products ADD COLUMN delivery_price NUMERIC(12,2) DEFAULT 0",
        # Qidiruv ustunlari
        "ALTER TABLE products ADD COLUMN search_keywords VARCHAR",
        "ALTER TABLE products ADD COLUMN search_text VARCHAR",
    ]:
        try:
            async with engine.begin() as conn:
                await conn.execute(text(col_sql))
        except Exception:
            pass

    # pg_trgm — xatoga chidamli qidiruvning asosi. So'zlarni uch harfli
    # bo'laklarga bo'lib solishtiradi, shuning uchun bir-ikki harf xato
    # yozilsa ham mahsulot topiladi. Sinonim ro'yxati talab qilmaydi.
    try:
        async with engine.begin() as conn:
            await conn.execute(text("CREATE EXTENSION IF NOT EXISTS pg_trgm"))
        print("[search] pg_trgm tayyor")
    except Exception as e:
        print(f"[search] pg_trgm mavjud emas, faqat ILIKE ishlaydi: {e}")

    # Notifications: model'da image_url bor edi, lekin jadval avval shusiz
    # yaratilgan (schema drift). Chatdan admin javob yozganda mijozga
    # bildirishnoma yaratilishi shu ustunni talab qiladi — busiz
    # "UndefinedColumnError: column image_url does not exist" beradi.
    try:
        async with engine.begin() as conn:
            await conn.execute(text("ALTER TABLE notifications ADD COLUMN image_url VARCHAR"))
    except Exception:
        pass
    
    # Add unique index on transaction_id if not exists
    try:
        async with engine.begin() as conn:
            await conn.execute(text("CREATE UNIQUE INDEX IF NOT EXISTS ix_payments_transaction_id ON payments (transaction_id)"))
    except Exception:
        pass
        
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Seed data
    try:
        async with AsyncSessionLocal() as session:
            await seed_data(session)
    except Exception as e:
        print(f"Error seeding/cleaning data: {e}")

    # DIQQAT — TARTIB: indeks va backfill create_all() hamda seed_data()
    # dan KEYIN turishi shart. Aks holda bo'sh bazada products jadvali
    # hali yo'q bo'ladi, urug'langan mahsulotlar esa search_text'siz
    # qolib, qidiruvda umuman chiqmaydi.
    try:
        async with engine.begin() as conn:
            await conn.execute(text(
                "CREATE INDEX IF NOT EXISTS ix_products_search_trgm "
                "ON products USING GIN (search_text gin_trgm_ops)"
            ))
    except Exception as e:
        print(f"[search] trgm indeks o'tkazib yuborildi: {e}")

    try:
        await _backfill_search_text()
    except Exception as e:
        print(f"[search] backfill xatosi: {e}")
        
    asyncio.create_task(_abandoned_order_cleanup_loop())

    yield


app = FastAPI(
    title="Milliy Metr API",
    description="Backend API for the Milliy Metr Marketplace",
    version="1.0.0",
    lifespan=lifespan,
    redirect_slashes=False,
    # XAVFSIZLIK: avtomatik API hujjatlari (/docs, /redoc, /openapi.json) faqat
    # ENABLE_API_DOCS=true bo'lganda ochiladi. Production'da ular yopiq turadi,
    # aks holda istalgan odam backend'ning barcha endpointlarini ko'ra oladi.
    docs_url="/docs" if settings.ENABLE_API_DOCS else None,
    redoc_url="/redoc" if settings.ENABLE_API_DOCS else None,
    openapi_url="/openapi.json" if settings.ENABLE_API_DOCS else None,
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

from app.api.router import api_router

app.include_router(api_router, prefix=settings.API_V1_STR)

# Mount static files directory
BASE_UPLOAD_DIR = os.getenv("UPLOAD_DIR", "/app/uploads")
os.makedirs(os.path.join(BASE_UPLOAD_DIR, "images"), exist_ok=True)

class CachedStaticFiles(StaticFiles):
    async def get_response(self, path: str, scope):
        response = await super().get_response(path, scope)
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "*"
        response.headers["Access-Control-Allow-Headers"] = "*"
        return response

    def is_not_modified(self, response_headers, request_headers) -> bool:
        response_headers["Cache-Control"] = "public, max-age=31536000, immutable"
        return super().is_not_modified(response_headers, request_headers)

app.mount("/uploads", CachedStaticFiles(directory=BASE_UPLOAD_DIR), name="uploads")

from app.core.exceptions import AppError, app_error_handler
app.add_exception_handler(AppError, app_error_handler)

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.get("/")
@app.head("/")
async def root():
    return {"message": "Milliy Metr API is running"}
