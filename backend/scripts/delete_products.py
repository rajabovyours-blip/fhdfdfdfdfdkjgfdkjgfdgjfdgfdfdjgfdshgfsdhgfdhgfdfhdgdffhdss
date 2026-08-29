import asyncio
import sys
import os

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.db.session import AsyncSessionLocal
from sqlalchemy import delete
from app.models.product import Product

async def main():
    async with AsyncSessionLocal() as session:
        await session.execute(delete(Product))
        await session.commit()
        print("All products deleted from the database.")

if __name__ == "__main__":
    asyncio.run(main())
