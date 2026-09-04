import asyncio
from fastapi.testclient import TestClient
from app.main import app
from app.db.session import SessionLocal
from app.models.user import User, RoleEnum
from app.security.jwt import create_access_token

async def test_create_admin():
    async with SessionLocal() as db:
        # Find owner token
        from sqlalchemy import select
        res = await db.execute(select(User).where(User.role == RoleEnum.OWNER))
        owner = res.scalars().first()
        if not owner:
            print("No owner found")
            return
            
        token = create_access_token({"sub": str(owner.id), "type": "access", "tv": 0})
        
        client = TestClient(app)
        headers = {"Authorization": f"Bearer {token}"}
        payload = {
            "username": "newtestadmin",
            "full_name": "New Test Admin",
            "password": "password123",
            "role": "ADMIN"
        }
        resp = client.post("/api/v1/admin/users/", headers=headers, json=payload)
        print("Status:", resp.status_code)
        print("Response:", resp.json())

if __name__ == "__main__":
    asyncio.run(test_create_admin())
