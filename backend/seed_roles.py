import asyncio
import uuid
from app.core.database import AsyncSessionLocal
from sqlalchemy.future import select
from app.models.users import Role

async def seed():
    async with AsyncSessionLocal() as db:
        for r in ['customer', 'admin', 'owner']:
            res = await db.execute(select(Role).filter_by(name=r))
            if not res.scalars().first():
                db.add(Role(id=uuid.uuid4(), name=r, description=r))
        await db.commit()

if __name__ == '__main__':
    asyncio.run(seed())
