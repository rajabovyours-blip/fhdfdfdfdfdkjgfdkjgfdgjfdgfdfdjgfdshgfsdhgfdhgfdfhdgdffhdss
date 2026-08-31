import sys
import asyncio
from fastapi.testclient import TestClient
from app.main import app
from app.models.user import User
from app.api.deps import get_current_user
import uuid

async def override_get_current_user():
    return User(id=uuid.uuid4(), phone="+998901234567")

app.dependency_overrides[get_current_user] = override_get_current_user

client = TestClient(app)

response = client.post('/api/v1/checkout/order', json={'items': [{'product_id': '123e4567-e89b-12d3-a456-426614174000', 'quantity': 1}], 'delivery_address': 'Tashkent', 'payment_method': 'Click', 'delivery_method': 'Delivery', 'customer_notes': 'Call me'})
print("CHECKOUT RESPONSE:", response.status_code, response.json())

response = client.post('/api/v1/checkout/order', json={'items': [{'product_id': 'not-a-uuid', 'quantity': 1}], 'delivery_address': 'Tashkent', 'payment_method': 'Click', 'delivery_method': 'Delivery', 'customer_notes': 'Call me'})
print("CHECKOUT INVALID UUID RESPONSE:", response.status_code, response.json())

response = client.get('/api/v1/products?minPrice=5000&maxPrice=10000')
print("PRODUCTS PARAMS ERROR RESPONSE:", response.status_code, response.json())

response = client.get('/api/v1/products?min_price=5000&max_price=10000')
print("PRODUCTS FIXED PARAMS RESPONSE:", response.status_code, len(response.json().get('data', [])))

response = client.get('/api/v1/products')
print("PRODUCTS NO PARAMS ERROR RESPONSE:", response.status_code, len(response.json().get('data', [])))
