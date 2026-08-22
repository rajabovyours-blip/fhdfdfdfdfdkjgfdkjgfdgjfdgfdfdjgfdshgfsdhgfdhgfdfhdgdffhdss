import io
import openpyxl
from difflib import get_close_matches
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Dict, Any, Tuple
from app.models.category import Category
from app.models.product import Product

class ExcelImporter:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.categories: Dict[str, str] = {} # name -> id
        
    async def load_categories(self):
        result = await self.db.execute(select(Category))
        cats = result.scalars().all()
        for c in cats:
            name_en = c.name.get("en", "").lower()
            name_uz = c.name.get("uz", "").lower()
            name_ru = c.name.get("ru", "").lower()
            if name_en: self.categories[name_en] = str(c.id)
            if name_uz: self.categories[name_uz] = str(c.id)
            if name_ru: self.categories[name_ru] = str(c.id)

    def match_category(self, query: str) -> Tuple[str, str, str]:
        # returns (category_id, detected_name, confidence)
        if not query or not self.categories:
            return None, "Unknown", "Low"
            
        query = str(query).lower().strip()
        
        # Exact match
        if query in self.categories:
            return self.categories[query], query.title(), "High"
            
        # Fuzzy match
        matches = get_close_matches(query, self.categories.keys(), n=1, cutoff=0.6)
        if matches:
            matched_name = matches[0]
            confidence = "High" if get_close_matches(query, self.categories.keys(), n=1, cutoff=0.8) else "Low"
            return self.categories[matched_name], matched_name.title(), confidence
            
        return None, "Unknown", "Low"

    async def check_duplicate(self, sku: str, name: str) -> bool:
        if sku:
            res = await self.db.execute(select(Product).where(Product.sku == str(sku)))
            if res.scalar_one_or_none():
                return True
        return False

    async def preview_file(self, file_bytes: bytes) -> Dict[str, Any]:
        await self.load_categories()
        
        wb = openpyxl.load_workbook(io.BytesIO(file_bytes), data_only=True)
        sheet = wb.active
        
        rows = list(sheet.iter_rows(values_only=True))
        if not rows or len(rows) < 2:
            return {"error": "File is empty or missing headers"}
            
        headers = [str(h).lower().strip() if h else "" for h in rows[0]]
        
        # Map headers to indices
        col_map = {
            "name": headers.index("name") if "name" in headers else -1,
            "description": headers.index("description") if "description" in headers else -1,
            "category": headers.index("category") if "category" in headers else -1,
            "price": headers.index("price") if "price" in headers else -1,
            "old_price": headers.index("old_price") if "old_price" in headers else -1,
            "stock": headers.index("stock") if "stock" in headers else -1,
            "sku": headers.index("sku") if "sku" in headers else -1,
            "brand": headers.index("brand") if "brand" in headers else -1,
            "image_url": headers.index("image_url") if "image_url" in headers else -1,
            "unit": headers.index("unit") if "unit" in headers else -1,
        }
        
        if col_map["name"] == -1 or col_map["price"] == -1:
            return {"error": "Missing required columns: 'name' and 'price'"}

        preview_rows = []
        stats = {"total": 0, "valid": 0, "invalid": 0, "duplicates": 0, "needs_review": 0}
        category_distribution = {}
        
        for idx, row in enumerate(rows[1:], start=2):
            # Skip completely empty rows
            if not any(row):
                continue
                
            stats["total"] += 1
            
            # Extract data safely
            def get_val(key, default=""):
                c_idx = col_map.get(key, -1)
                return row[c_idx] if c_idx != -1 and c_idx < len(row) and row[c_idx] is not None else default

            name = get_val("name")
            desc = get_val("description")
            category_raw = get_val("category")
            price = get_val("price", 0)
            stock = get_val("stock", 0)
            sku = get_val("sku")
            brand = get_val("brand")
            image_url = get_val("image_url")
            unit = get_val("unit", "pcs")
            
            errors = []
            
            # Validation
            if not name: errors.append("Missing product name")
            
            try:
                price = float(price)
                if price < 0: errors.append("Negative price")
            except:
                errors.append("Invalid price")
                
            try:
                stock = int(stock)
                if stock < 0: errors.append("Negative stock")
            except:
                errors.append("Invalid stock")
                
            # Category Matching
            cat_id, cat_name, confidence = self.match_category(str(category_raw) if category_raw else str(name))
            if not cat_id:
                errors.append("Category not found")
                
            if cat_name not in category_distribution:
                category_distribution[cat_name] = 0
            category_distribution[cat_name] += 1
            
            # Duplicate check
            is_dup = await self.check_duplicate(sku, str(name))
            
            row_status = "Valid"
            if errors:
                row_status = "Error"
                stats["invalid"] += 1
            elif is_dup:
                row_status = "Duplicate"
                stats["duplicates"] += 1
            elif confidence == "Low":
                row_status = "Needs Review"
                stats["needs_review"] += 1
            else:
                stats["valid"] += 1
                
            preview_rows.append({
                "row_index": idx,
                "name": str(name),
                "description": str(desc),
                "price": price,
                "stock": stock,
                "sku": str(sku),
                "brand": str(brand),
                "image_url": str(image_url),
                "unit": str(unit),
                "category_id": cat_id,
                "detected_category": cat_name,
                "confidence": confidence,
                "status": row_status,
                "errors": errors,
                "is_duplicate": is_dup
            })
            
        return {
            "stats": stats,
            "category_distribution": category_distribution,
            "rows": preview_rows
        }
    async def execute_import(self, rows_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        success_count = 0
        error_count = 0
        
        for row in rows_data:
            if row.get("status") == "Error":
                error_count += 1
                continue
                
            try:
                new_product = Product(
                    name={"uz": row["name"], "ru": row["name"], "en": row["name"]},
                    description={"uz": row.get("description", ""), "ru": row.get("description", ""), "en": row.get("description", "")},
                    price=row["price"],
                    stock=row["stock"],
                    sku=row.get("sku"),
                    brand=row.get("brand"),
                    unit=row.get("unit", "pcs"),
                    category_id=row["category_id"],
                    images=[row["image_url"]] if row.get("image_url") else []
                )
                self.db.add(new_product)
                success_count += 1
            except Exception as e:
                error_count += 1
                
        await self.db.commit()
        return {"imported": success_count, "failed": error_count}
