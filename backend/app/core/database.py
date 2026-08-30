from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from sqlalchemy.orm import declarative_base
from app.core.config import settings

is_dev = getattr(settings, "ENVIRONMENT", "production") == "development"
engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI, echo=is_dev)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

Base = declarative_base()

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
