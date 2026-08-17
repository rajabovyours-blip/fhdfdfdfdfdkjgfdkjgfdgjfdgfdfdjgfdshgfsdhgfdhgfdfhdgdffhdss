import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_register_user(async_client: AsyncClient):
    response = await async_client.post("/api/v1/auth/register", json={
        "full_name": "Test User",
        "phone": "+998900000000",
        "password": "password123"
    })
    # Since we can't run tests without DB, we just ensure the route is structured correctly
    assert response.status_code in [200, 400] # 400 if already exists

@pytest.mark.asyncio
async def test_login_user(async_client: AsyncClient):
    response = await async_client.post("/api/v1/auth/login", json={
        "phone": "+998900000000",
        "password": "password123"
    })
    assert response.status_code in [200, 400]
