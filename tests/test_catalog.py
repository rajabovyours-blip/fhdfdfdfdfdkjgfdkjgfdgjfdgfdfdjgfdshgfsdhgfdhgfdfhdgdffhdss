import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_get_categories(async_client: AsyncClient):
    response = await async_client.get("/api/v1/categories/")
    assert response.status_code == 200

@pytest.mark.asyncio
async def test_get_products(async_client: AsyncClient):
    response = await async_client.get("/api/v1/products/")
    assert response.status_code == 200
