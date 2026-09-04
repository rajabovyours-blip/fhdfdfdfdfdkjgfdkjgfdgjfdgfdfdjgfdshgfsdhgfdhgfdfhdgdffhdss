from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, cast, String, func
from sqlalchemy.orm import selectinload
from typing import List, Optional
from uuid import UUID

from app.db.session import get_db
from app.api.dependencies import get_current_admin, get_current_user
from app.models.product import Product
from app.models.category import Category
from app.models.user import User
from app.models.review import Review
from app.models.order import Order, OrderItem
from app.schemas.product import ProductModel, CategoryModel
from app.schemas.common import APIResponse

router = APIRouter()

@router.get("", response_model=APIResponse[List[ProductModel]])
async def get_products(
    category_id: Optional[UUID] = None, 
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    brand: Optional[str] = None,
    unit: Optional[str] = None,
    min_rating: Optional[float] = None,
    max_moq: Optional[int] = None,
    has_certificate: Optional[bool] = None,
    has_delivery: Optional[bool] = None,
    in_stock_only: Optional[bool] = None,
    has_discount: Optional[bool] = None,
    sort_by: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    limit: int = 20,
    db: AsyncSession = Depends(get_db)
):
    query = select(Product)
    
    if category_id:
        query = query.where(Product.category_id == category_id)
        
    if min_price is not None:
        query = query.where(Product.price >= min_price)
        
    if max_price is not None:
        query = query.where(Product.price <= max_price)
        
    if brand:
        query = query.where(func.lower(Product.brand) == brand.lower())
        
    if unit:
        query = query.where(Product.unit == unit)
        
    if min_rating is not None:
        query = query.where(Product.rating >= min_rating)
        
    if max_moq is not None:
        query = query.where(Product.moq <= max_moq)
        
    if has_certificate:
        query = query.where(Product.certificates.isnot(None))
        
    if has_delivery is not None:
        query = query.where(Product.has_delivery == has_delivery)
        
    if in_stock_only:
        query = query.where(Product.stock > 0)
        
    if has_discount:
        query = query.where(Product.discount_price.isnot(None))
        
    if search:
        search_lower = search.lower().replace("'", "").replace("", "")
        synonyms = {
            'kraska': "bo'yoq",
            'sement': 'cement',
            'oboy': "gulqog'oz",
            'gipsokarton': 'gips karton',
            'shpatlevka': 'shpaklyovka',
            'shurup': 'vint',
            'kley': 'yelim',
            'truba': 'quvur',
            'armatura': 'temir',
        }
        for k, v in synonyms.items():
            if k in search_lower:
                search_lower = search_lower.replace(k, v)

        search_term = f"%{search_lower}%"
        # Search in JSON name field. Cast to String for simple ILIKE search
        query = query.where(
            or_(
                cast(Product.name, String).ilike(search_term),
                cast(Product.description, String).ilike(search_term)
            )
        )
        
    if sort_by == 'price_asc':
        query = query.order_by(Product.price.asc())
    elif sort_by == 'price_desc':
        query = query.order_by(Product.price.desc())
    elif sort_by == 'newest':
        query = query.order_by(Product.created_at.desc())
    elif sort_by == 'rating':
        query = query.order_by(Product.rating.desc())
    elif sort_by == 'popular':
        query = query.order_by(Product.review_count.desc())
        
    query = query.offset((page - 1) * limit).limit(limit)
        
    result = await db.execute(query)
    products = result.scalars().all()
    return APIResponse(data=[ProductModel.model_validate(p) for p in products])

@router.get("/{id}", response_model=APIResponse[ProductModel])
async def get_product(id: str, db: AsyncSession = Depends(get_db)):
    try:
        product_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(
        select(Product)
        .where(Product.id == product_id)
        .options(selectinload(Product.reviews), selectinload(Product.category))
    )
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    return APIResponse(data=ProductModel.model_validate(product))

from pydantic.alias_generators import to_camel
from pydantic import BaseModel as PydanticBaseModel, ConfigDict, model_validator, Field
from typing import Union, Any, Dict

class ProductCreateRequest(PydanticBaseModel):
    name: Union[Dict[str, str], str]
    description: Union[Dict[str, str], str]
    category_id: UUID = None
    price: float
    discount_price: float | None = None
    unit: str = "pcs"
    stock: int = 0
    images: list = []
    brand: str | None = None
    has_delivery: bool = True
    delivery_price: float = 0.0
    specifications: Dict[str, str] | None = None
    certificates: list | None = None
    delivery_information: str | None = None
    moq: int = 1

    model_config = ConfigDict(
        populate_by_name=True,
        alias_generator=to_camel,
    )

    @model_validator(mode='before')
    @classmethod
    def normalize_fields(cls, data: Any) -> Any:
        if isinstance(data, dict):
            # Handle name/description as string → dict
            if isinstance(data.get('name'), str):
                val = data['name']
                data['name'] = {'uz': val, 'ru': val, 'en': val}
            if isinstance(data.get('description'), str):
                val = data['description']
                data['description'] = {'uz': val, 'ru': val, 'en': val}
            # Normalize category_id from camelCase
            if 'categoryId' in data and 'category_id' not in data:
                data['category_id'] = data.pop('categoryId')
            # Normalize stock from stock_quantity or stockQuantity
            if 'stock_quantity' in data:
                data['stock'] = data.pop('stock_quantity')
            elif 'stockQuantity' in data:
                data['stock'] = data.pop('stockQuantity')
            # Normalize discount_price from discountPrice
            if 'discountPrice' in data and 'discount_price' not in data:
                data['discount_price'] = data.pop('discountPrice')
            # Normalize has_delivery from hasDelivery
            if 'hasDelivery' in data and 'has_delivery' not in data:
                data['has_delivery'] = data.pop('hasDelivery')
            # Normalize delivery_price from deliveryPrice
            if 'deliveryPrice' in data and 'delivery_price' not in data:
                data['delivery_price'] = data.pop('deliveryPrice')
        return data

@router.post("", response_model=APIResponse[ProductModel])
async def create_product(payload: ProductCreateRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_admin)):
    import uuid as _uuid
    product = Product(
        id=_uuid.uuid4(),
        sku=f"SKU-{_uuid.uuid4().hex[:8].upper()}",
        name=payload.name,
        description=payload.description,
        category_id=payload.category_id,
        price=payload.price,
        discount=payload.discount_price,
        old_price=payload.discount_price,
        unit=payload.unit,
        stock=payload.stock,
        images=payload.images,
        brand=payload.brand,
        has_delivery=payload.has_delivery,
        delivery_price=payload.delivery_price,
        specifications=payload.specifications,
        certificates=payload.certificates,
        delivery_information=payload.delivery_information,
        moq=payload.moq,
        currency="UZS",
    )
    db.add(product)
    await db.commit()
    await db.refresh(product)
    return APIResponse(data=ProductModel.model_validate(product))

@router.put("/{id}", response_model=APIResponse[ProductModel])
async def update_product(id: str, payload: ProductCreateRequest, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_admin)):
    try:
        product_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    product.name = payload.name
    product.description = payload.description
    product.category_id = payload.category_id
    product.price = payload.price
    product.discount = payload.discount_price
    product.old_price = payload.discount_price
    product.unit = payload.unit
    product.stock = payload.stock
    product.brand = payload.brand
    product.has_delivery = payload.has_delivery
    product.delivery_price = payload.delivery_price
    
    if payload.specifications is not None:
        product.specifications = payload.specifications
    if payload.certificates is not None:
        product.certificates = payload.certificates
    if payload.delivery_information is not None:
        product.delivery_information = payload.delivery_information
    if payload.moq is not None:
        product.moq = payload.moq
    if payload.images:
        product.images = payload.images
    if payload.brand is not None:
        product.brand = payload.brand
        
    await db.commit()
    await db.refresh(product)
    
    return APIResponse(data=ProductModel.model_validate(product))

@router.delete("/{id}", response_model=APIResponse[dict])
async def delete_product(id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_admin)):
    from sqlalchemy.exc import IntegrityError
    try:
        product_id = UUID(str(id))
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid UUID format")
        
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    try:
        await db.delete(product)
        await db.commit()
    except IntegrityError as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail="Bu mahsulot buyurtmalar yoki savatchalarda mavjud bo'lganligi sababli o'chirib bo'lmaydi. Iltimos, o'rniga zaxirani (stock) 0 qilib qo'ying.")
    
    return APIResponse(data={"success": True, "message": "Product deleted successfully"})

import openpyxl
import io
import uuid as _uuid
from sqlalchemy import insert
from fastapi import UploadFile, File

@router.post("/bulk-upload", response_model=APIResponse[dict])
async def bulk_upload_products(file: UploadFile = File(...), db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_admin)):
    if not file.filename.endswith(".xlsx"):
        raise HTTPException(status_code=400, detail="Faqat .xlsx formatidagi fayllar qabul qilinadi (Only .xlsx files are supported)")
    
    contents = await file.read()
    
    try:
        # Load workbook in read-only mode for efficiency
        wb = openpyxl.load_workbook(io.BytesIO(contents), data_only=True, read_only=True)
        sheet = wb.active
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Faylni o'qishda xatolik: {str(e)}")
        
    # Read headers (first row)
    row_iter = sheet.iter_rows(values_only=True)
    try:
        headers = next(row_iter)
    except StopIteration:
        raise HTTPException(status_code=400, detail="Fayl bo'sh (File is empty)")
        
    if not headers:
        raise HTTPException(status_code=400, detail="Fayl sarlavhalari (header) topilmadi")
        
    headers = [str(h).strip() if h else "" for h in headers]
    
    # Required columns
    expected_headers = {
        "Nomi (O'zbekcha)": None,
        "Nomi (Ruscha)": None,
        "Nomi (Inglizcha)": None,
        "Kategoriya": None,
        "Narxi": None,
        "O'lchov birligi": None,
    }
    
    # Map column names to their index
    col_map = {}
    for idx, h in enumerate(headers):
        if h in expected_headers:
            col_map[h] = idx
        elif h == "Tavsif":
            col_map["Tavsif"] = idx
            
    # Check for missing required headers
    missing_headers = [h for h in expected_headers if h not in col_map]
    if missing_headers:
        raise HTTPException(
            status_code=400, 
            detail=f"Quyidagi ustunlar yetishmayapti: {', '.join(missing_headers)}"
        )
        
    # Pre-fetch categories
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    
    # Map category names (lowercase) to Category IDs
    cat_map = {}
    for c in categories:
        name_dict = c.name if isinstance(c.name, dict) else {}
        for lang, val in name_dict.items():
            if val:
                cat_map[str(val).strip().lower()] = c.id
                
    valid_units = {"dona", "kg", "metr", "kv.m", "litr", "komplekt", "m3", "tonna", "rulon", "qop"}

    valid_rows = []
    failed_rows = []
    
    # Process rows (1-indexed for Excel reporting, headers were row 1)
    current_row_idx = 1
    
    for row in row_iter:
        current_row_idx += 1
        
        # Skip completely empty rows
        if not any(row):
            continue
            
        def get_val(col_name):
            if col_name not in col_map:
                return ""
            v = row[col_map[col_name]]
            return str(v).strip() if v is not None else ""
            
        name_uz = get_val("Nomi (O'zbekcha)")
        name_ru = get_val("Nomi (Ruscha)")
        name_en = get_val("Nomi (Inglizcha)")
        cat_name = get_val("Kategoriya")
        price_str = get_val("Narxi")
        unit_str = get_val("O'lchov birligi")
        desc_str = get_val("Tavsif")
        
        # Validation
        if not name_uz:
            failed_rows.append({"row": current_row_idx, "reason": "Nomi (O'zbekcha) bo'sh bo'lishi mumkin emas"})
            continue
        if not name_ru:
            failed_rows.append({"row": current_row_idx, "reason": "Nomi (Ruscha) bo'sh bo'lishi mumkin emas"})
            continue
        if not name_en:
            failed_rows.append({"row": current_row_idx, "reason": "Nomi (Inglizcha) bo'sh bo'lishi mumkin emas"})
            continue
            
        if not cat_name:
            failed_rows.append({"row": current_row_idx, "reason": "Kategoriya kiritilmagan"})
            continue
            
        cat_id = cat_map.get(cat_name.lower())
        if not cat_id:
            failed_rows.append({"row": current_row_idx, "reason": f"'{cat_name}' nomli kategoriya topilmadi"})
            continue
            
        try:
            price = float(price_str)
            if price < 0:
                raise ValueError
        except ValueError:
            failed_rows.append({"row": current_row_idx, "reason": "Narx to'g'ri raqam bo'lishi (masbiy) kerak"})
            continue
            
        if not unit_str or unit_str.lower() not in valid_units:
            # Optionally default to 'dona' or fail
            failed_rows.append({"row": current_row_idx, "reason": f"O'lchov birligi yaroqsiz ('{unit_str}'). Ruxsat etilganlar: {', '.join(valid_units)}"})
            continue

        product_id = _uuid.uuid4()
        sku = f"SKU-{product_id.hex[:8].upper()}"
        
        valid_rows.append({
            "id": product_id,
            "sku": sku,
            "name": {"uz": name_uz, "ru": name_ru, "en": name_en},
            "description": {"uz": desc_str, "ru": desc_str, "en": desc_str} if desc_str else {},
            "category_id": cat_id,
            "price": price,
            "unit": unit_str.lower(),
            "stock": 100, # Default stock
            "images": [],
            "currency": "UZS",
        })
        
    # Bulk insert valid rows
    if valid_rows:
        await db.execute(insert(Product).values(valid_rows))
        await db.commit()
        
    return APIResponse(
        message="Ommaviy yuklash yakunlandi",
        data={
            "total_rows": len(valid_rows) + len(failed_rows),
            "success_count": len(valid_rows),
            "failed_rows": failed_rows
        }
    )

from pydantic import BaseModel as PydanticBaseModel

class ReviewCreate(PydanticBaseModel):
    rating: int
    text: str

@router.get("/{id}/reviews", response_model=APIResponse[list])
async def get_product_reviews(
    id: UUID,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Product)
        .where(Product.id == id)
        .options(selectinload(Product.reviews).selectinload(Review.user))
    )
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    reviews = []
    if product.reviews:
        for r in product.reviews:
            reviews.append({
                "id": str(r.id),
                "productId": str(r.product_id),
                "userId": str(r.user_id),
                "userName": r.user.full_name if r.user else "User",
                "rating": float(r.rating) if r.rating else 5.0,
                "text": r.comment if hasattr(r, 'comment') else "",
                "photos": [],
                "createdAt": r.created_at.isoformat() if hasattr(r, 'created_at') and r.created_at else None,
                "isVerifiedPurchase": True
            })
            
    return APIResponse(data=reviews)

@router.get("/{id}/eligibility")
async def check_review_eligibility(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(OrderItem)
        .join(Order, Order.id == OrderItem.order_id)
        .where(Order.user_id == current_user.id, OrderItem.product_id == id)
    )
    has_purchased = result.first() is not None
    return {"eligible": has_purchased, "reason": None if has_purchased else "purchase_required"}

@router.get("/{id}/user-review")
async def get_user_review(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Review).where(Review.product_id == id, Review.user_id == current_user.id)
    )
    review = result.scalar_one_or_none()
    if not review:
        return {"data": None}
    return {"data": {
        "id": str(review.id), 
        "rating": float(review.rating),
        "text": review.comment, 
        "createdAt": review.created_at.isoformat(),
    }}

@router.post("/{id}/reviews", response_model=APIResponse[dict])
async def add_product_review(
    id: UUID,
    payload: ReviewCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(select(Product).where(Product.id == id))
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    existing = await db.execute(
        select(Review).where(Review.product_id == id, Review.user_id == current_user.id)
    )
    review = existing.scalar_one_or_none()
    if review:
        review.rating = payload.rating
        review.comment = payload.text
    else:
        review = Review(user_id=current_user.id, product_id=id, rating=payload.rating, comment=payload.text)
        db.add(review)
    await db.flush()

    # Recompute cached rating/review_count on the product
    agg = await db.execute(
        select(func.avg(Review.rating), func.count(Review.id)).where(Review.product_id == id)
    )
    avg_rating, count = agg.first()
    product.rating = round(float(avg_rating or 0), 2)
    product.review_count = count

    await db.commit()
    return APIResponse(message="Review saved successfully", data={"id": str(review.id)})
