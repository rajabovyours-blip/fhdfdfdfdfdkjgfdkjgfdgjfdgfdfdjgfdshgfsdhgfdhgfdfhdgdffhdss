import redis.asyncio as redis
from app.core.config import settings

redis_url = settings.REDIS_URL or f"redis://{settings.REDIS_HOST}:{settings.REDIS_PORT}/0"

redis_client = redis.from_url(redis_url, decode_responses=True)

async def get_redis():
    return redis_client
