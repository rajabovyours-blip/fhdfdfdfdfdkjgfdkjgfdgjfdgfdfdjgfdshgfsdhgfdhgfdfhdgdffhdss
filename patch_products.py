import re

file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\backend\app\api\endpoints\products.py'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports for cast, or_ if missing
if 'from sqlalchemy import select' in content:
    content = content.replace('from sqlalchemy import select', 'from sqlalchemy import select, or_, cast, String, func')

# Define new endpoint function
new_endpoint = '''@router.get("", response_model=APIResponse[List[ProductModel]])
async def get_products(
    category_id: Optional[UUID] = None, 
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    region_id: Optional[str] = None,
    district_id: Optional[str] = None,
    in_stock_only: Optional[bool] = None,
    has_discount: Optional[bool] = None,
    sort_by: Optional[str] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    query = select(Product)
    
    if category_id:
        query = query.where(Product.category_id == category_id)
        
    if min_price is not None:
        query = query.where(Product.price >= min_price)
        
    if max_price is not None:
        query = query.where(Product.price <= max_price)
        
    if in_stock_only:
        query = query.where(Product.stock > 0)
        
    if has_discount:
        query = query.where(Product.discount_price.isnot(None))
        
    if search:
        search_term = f"%{search.lower()}%"
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
        query = query.order_by(Product.sold_count.desc())
        
    result = await db.execute(query)
    products = result.scalars().all()
    return APIResponse(data=[ProductModel.model_validate(p) for p in products])'''

# Replace the existing endpoint
endpoint_pattern = re.compile(r'@router\.get\("", response_model=APIResponse\[List\[ProductModel\]\]\)\s*async def get_products\(.*?\):.*?(?=@router\.get)', re.DOTALL)
content = re.sub(endpoint_pattern, new_endpoint + '\n\n', content, count=1)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
