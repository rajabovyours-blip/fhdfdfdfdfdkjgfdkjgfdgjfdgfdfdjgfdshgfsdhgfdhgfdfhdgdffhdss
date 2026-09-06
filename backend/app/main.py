from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from contextlib import asynccontextmanager

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
        
    asyncio.create_task(_abandoned_order_cleanup_loop())

    yield


app = FastAPI(
    title="Milliy Metr API",
    description="Backend API for the Milliy Metr Marketplace",
    version="1.0.0",
    lifespan=lifespan,
    redirect_slashes=False,
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
from app.core.config import settings

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
