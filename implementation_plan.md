# Admin Panel Muammolari - Tuzatish Rejasi

## Aniqlangan Muammolar

### 1. camelCase vs snake_case (ENG ASOSIY MUAMMO)
`ProductModel` da `alias_generator=to_camel` bor → JSON response `categoryId`, `stockStatus` kabi camelCase yuboradi.
Flutter admin panel esa `product['category_id']`, `product['stock']` kutadi → HAMMA NARSA ISHLAMAS!

**Tuzatish:** `ProductModel` dan `alias_generator` olib tashlanadi yoki `serialize_by_alias=False` qilinadi.

### 2. `sold_count` maydoni yo'q
`products.py` da `sort_by == 'popular'` → `Product.sold_count.desc()` - bu model da yo'q → 500 xato!

### 3. `banners.py` - PUT endpoint yo'q
Banner tahrirlash endpointi umuman yo'q.

### 4. `categories.py` - auth yo'q
Create/Update/Delete endpointlarida admin autentifikatsiya talab qilinmayapti.

### 5. Flutter `DropdownButtonFormField.initialValue` → `value`
Flutter'da `DropdownButtonFormField`da `initialValue` parametri yo'q - bu `value` bo'lishi kerak.

## Tuzatish Joylari

1. `backend/app/schemas/product.py` - camelCase olib tashlash
2. `backend/app/api/endpoints/products.py` - sold_count xatosi
3. `backend/app/api/endpoints/banners.py` - PUT endpoint qo'shish
4. `backend/app/api/endpoints/categories.py` - admin auth qo'shish
5. `milliy_metr_admin/lib/features/products/presentation/products_screen.dart` - `initialValue` → `value`
6. `milliy_metr_admin/lib/features/categories/presentation/categories_screen.dart` - `initialValue` → `value`
