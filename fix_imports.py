with open('backend/app/api/endpoints/admin_products.py', 'r', encoding='utf-8') as f:
    content = f.read()

imports = """import pandas as pd
import io
import uuid
from sqlalchemy import select, insert
from app.models.category import Category
from app.models.product import Product
"""

content = content.replace(imports, '')
new_content = imports + content

with open('backend/app/api/endpoints/admin_products.py', 'w', encoding='utf-8') as f:
    f.write(new_content)
