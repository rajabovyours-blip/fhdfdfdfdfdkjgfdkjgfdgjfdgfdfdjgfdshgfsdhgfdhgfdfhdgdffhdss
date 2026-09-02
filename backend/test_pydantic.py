import sys
from uuid import UUID
from app.api.endpoints.products import ProductCreateRequest

try:
    req = ProductCreateRequest(name="test", description="test", category_id=None)
    print("category_id=None -> Success, category_id is:", req.category_id)
except Exception as e:
    print("category_id=None -> Exception:", e)

try:
    req2 = ProductCreateRequest(**{"name": "test", "description": "test", "categoryId": "52857474-b5de-4b6c-843e-c6c74776e0be"})
    print("categoryId -> Success, category_id is:", req2.category_id)
except Exception as e:
    print("categoryId -> Exception:", e)

try:
    req3 = ProductCreateRequest(**{"name": "test", "description": "test", "category_id": "52857474-b5de-4b6c-843e-c6c74776e0be"})
    print("category_id -> Success, category_id is:", req3.category_id)
except Exception as e:
    print("category_id -> Exception:", e)
