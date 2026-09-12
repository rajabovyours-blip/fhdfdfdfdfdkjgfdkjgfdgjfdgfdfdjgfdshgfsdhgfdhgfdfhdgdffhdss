import pandas as pd
import io
import uuid
from sqlalchemy import select, insert
from app.models.category import Category
from app.models.product import Product
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Body
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Dict, Any, List

from app.db.session import get_db
from app.models.user import User, RoleEnum
from app.api.deps import get_current_user
from app.services.excel_importer import ExcelImporter
from app.schemas.common import APIResponse

from app.api.dependencies import get_current_admin

router = APIRouter()


# ── Topilmagan qidiruvlar ────────────────────────────────────────
# Qidiruvning o'z-o'zidan yaxshilanishi uchun asosiy vosita: mijozlar
# nima deb qidirganini, lekin hech narsa topilmaganini ko'rsatadi.
# Admin shu ro'yxatga qarab kerakli mahsulotga bitta so'z qo'shadi
# (search_keywords) — kod o'zgarmaydi, deploy kerak emas.

from sqlalchemy import desc as _desc


@router.get("/search-misses", response_model=APIResponse[List[Dict[str, Any]]])
async def list_search_misses(
    resolved: bool = False,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    from app.models.extras import SearchMiss

    result = await db.execute(
        select(SearchMiss)
        .where(SearchMiss.resolved == resolved)
        .order_by(_desc(SearchMiss.hit_count), _desc(SearchMiss.last_searched_at))
        .limit(limit)
    )
    rows = result.scalars().all()
    return APIResponse(data=[
        {
            "id": str(r.id),
            "term": r.term,
            "normalized_term": r.normalized_term,
            "hit_count": r.hit_count,
            "resolved": r.resolved,
            "last_searched_at": r.last_searched_at.isoformat() if r.last_searched_at else None,
        }
        for r in rows
    ])


@router.put("/search-misses/{miss_id}/resolve", response_model=APIResponse[dict])
async def resolve_search_miss(
    miss_id: str,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    """Admin bu so'rovni "ko'rib chiqdim, hal qildim" deb belgilaydi
    (masalan tegishli mahsulotga search_keywords qo'shgandan keyin)."""
    from app.models.extras import SearchMiss

    row = (await db.execute(
        select(SearchMiss).where(SearchMiss.id == miss_id)
    )).scalar_one_or_none()
    if not row:
        raise HTTPException(status_code=404, detail="Topilmadi")

    row.resolved = True
    await db.commit()
    return APIResponse(message="Belgilandi", data={"id": str(row.id)})

@router.post("/import/preview", response_model=APIResponse[Dict[str, Any]])
async def preview_excel_import(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    if not file.filename.endswith(".xlsx"):
        raise HTTPException(status_code=400, detail="Only .xlsx files are supported")
        
    content = await file.read()
    importer = ExcelImporter(db)
    result = await importer.preview_file(content)
    
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
        
    return APIResponse(data=result)

@router.post("/import", response_model=APIResponse[Dict[str, Any]])
async def execute_excel_import(
    rows: List[Dict[str, Any]] = Body(...),
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    if not rows:
        raise HTTPException(status_code=400, detail="No rows provided for import")
        
    importer = ExcelImporter(db)
    result = await importer.execute_import(rows)
    return APIResponse(data=result)


@router.post("/bulk-upload", response_model=APIResponse[Dict[str, Any]])
async def bulk_upload_products(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    if not (file.filename.endswith(".xlsx") or file.filename.endswith(".csv")):
        raise HTTPException(status_code=400, detail="Only .xlsx or .csv files are supported")
    
    content = await file.read()
    
    try:
        if file.filename.endswith(".csv"):
            df = pd.read_csv(io.BytesIO(content))
        else:
            df = pd.read_excel(io.BytesIO(content))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to parse file: {str(e)}")
    
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    
    tools_keywords = ["bolgarka", "otvyorka", "drel", "болгарка", "отвертка", "дрель", "grinder", "screwdriver", "drill", "asbob"]
    materials_keywords = ["sement", "g'isht", "цемент", "кирпич", "cement", "brick", "shpaklyovka", "bo'yoq", "краска"]
    
    tools_cat_id = None
    materials_cat_id = None
    default_cat_id = None
    
    for cat in categories:
        cat_name_uz = str(cat.name.get('uz', '')).lower()
        cat_name_ru = str(cat.name.get('ru', '')).lower()
        if any(k in cat_name_uz or k in cat_name_ru for k in ["asbob", "инструмент", "tool"]):
            tools_cat_id = cat.id
        elif any(k in cat_name_uz or k in cat_name_ru for k in ["material", "материал"]):
            materials_cat_id = cat.id
        if default_cat_id is None:
            default_cat_id = cat.id
            
    if not tools_cat_id:
        new_tools_cat = Category(name={"uz": "Qurilish asboblari", "ru": "Строительные инструменты", "en": "Tools"}, description={})
        db.add(new_tools_cat)
        await db.flush()
        tools_cat_id = new_tools_cat.id
        
    if not materials_cat_id:
        new_materials_cat = Category(name={"uz": "Qurilish materiallari", "ru": "Строительные материалы", "en": "Construction Materials"}, description={})
        db.add(new_materials_cat)
        await db.flush()
        materials_cat_id = new_materials_cat.id
        
    if not default_cat_id:
        default_cat_id = tools_cat_id
    
    products_to_insert = []
    failed = 0
    
    for index, row in df.iterrows():
        try:
            row_dict = {str(k).lower(): v for k, v in row.items()}
            
            name_val = row_dict.get('name', row_dict.get('nomi', row_dict.get('название', f"Product {index}")))
            if pd.isna(name_val):
                name_val = f"Unknown Product {index}"
            name_str = str(name_val)
            name_lower = name_str.lower()
            
            cat_id = default_cat_id
            if any(k in name_lower for k in tools_keywords):
                cat_id = tools_cat_id
            elif any(k in name_lower for k in materials_keywords):
                cat_id = materials_cat_id
                
            price_val = row_dict.get('price', row_dict.get('narxi', row_dict.get('цена', 0)))
            price = float(price_val) if not pd.isna(price_val) else 0.0
            
            stock_val = row_dict.get('stock', row_dict.get('zaxira', row_dict.get('склад', 0)))
            stock = int(stock_val) if not pd.isna(stock_val) else 0
            
            sku_val = row_dict.get('sku', row_dict.get('kod', row_dict.get('код', None)))
            sku = str(sku_val) if not pd.isna(sku_val) else f"SKU-{uuid.uuid4().hex[:8].upper()}"
            
            desc_val = row_dict.get('description', row_dict.get('tavsif', row_dict.get('описание', "")))
            desc = str(desc_val) if not pd.isna(desc_val) else ""
            
            product_dict = {
                "id": uuid.uuid4(),
                "sku": sku,
                "name": {"uz": name_str, "ru": name_str, "en": name_str},
                "description": {"uz": desc, "ru": desc, "en": desc},
                "category_id": cat_id,
                "price": price,
                "stock": stock,
                "currency": "UZS",
                "unit": "pcs",
            }
            products_to_insert.append(product_dict)
            
        except Exception:
            failed += 1
            continue

    if products_to_insert:
        await db.execute(insert(Product).values(products_to_insert))
        await db.commit()
        
    return APIResponse(data={
        "imported": len(products_to_insert),
        "failed": failed,
        "total": len(df)
    })
