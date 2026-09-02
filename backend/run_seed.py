import asyncio
from app.db.session import AsyncSessionLocal
from app.db.seed import seed_data

async def main():
    async with AsyncSessionLocal() as session:
        # Ignore preferred_language column error if it happens during other operations
        try:
            await seed_data(session)
            print("Success: Updated owner credentials.")
        except Exception as e:
            print("Error during seed:", e)

asyncio.run(main())
