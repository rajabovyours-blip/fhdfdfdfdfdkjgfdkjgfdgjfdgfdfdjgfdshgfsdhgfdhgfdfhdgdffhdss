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
from app.db.session import AsyncSessionLocal
from app.db.seed import seed_data

from sqlalchemy import text

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
        
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Seed data
    try:
        async with AsyncSessionLocal() as session:
            await seed_data(session)
    except Exception as e:
        print(f"Error seeding/cleaning data: {e}")
        
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
app.mount("/uploads", StaticFiles(directory=BASE_UPLOAD_DIR), name="uploads")

from app.core.exceptions import AppError, app_error_handler
app.add_exception_handler(AppError, app_error_handler)

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.get("/")
@app.head("/")
async def root():
    return {"message": "Milliy Metr API is running"}
