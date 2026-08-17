# MILLIY METR - BACKEND API CONTRACT

This document outlines the API endpoints required by the Flutter application.

## AUTH
### Login
- **METHOD:** POST
- **PATH:** `/auth/login`
- **AUTH REQUIRED:** No
- **REQUEST BODY:** `{"phone": "+998...", "password": "..."}`
- **EXPECTED RESPONSE:** `{"token": "JWT", "user": {...}}`
- **ERROR RESPONSES:** 401 Unauthorized, 422 Validation Error

### Register
- **METHOD:** POST
- **PATH:** `/auth/register`
- **AUTH REQUIRED:** No
- **REQUEST BODY:** `{"phone": "+998...", "name": "...", "password": "..."}`
- **EXPECTED RESPONSE:** `{"token": "JWT", "user": {...}}`
- **ERROR RESPONSES:** 422 Validation Error, 409 Conflict

## HOME
### Get Home Data
- **METHOD:** GET
- **PATH:** `/home`
- **AUTH REQUIRED:** No
- **EXPECTED RESPONSE:** `{"banners": [...], "featured_categories": [...], "popular_products": [...]}`

## CATEGORIES
### Get Categories
- **METHOD:** GET
- **PATH:** `/categories`
- **AUTH REQUIRED:** No
- **EXPECTED RESPONSE:** `{"data": [...]}`

## PRODUCTS
### Get Products
- **METHOD:** GET
- **PATH:** `/products`
- **AUTH REQUIRED:** No
- **QUERY PARAMETERS:** `categoryId`, `search`, `minPrice`, `maxPrice`
- **EXPECTED RESPONSE:** `{"data": [...], "meta": {...}}`

### Get Product Details
- **METHOD:** GET
- **PATH:** `/products/:id`
- **AUTH REQUIRED:** No
- **EXPECTED RESPONSE:** `{"data": {...}}`

## SEARCH
### Search Products
- **METHOD:** GET
- **PATH:** `/search`
- **AUTH REQUIRED:** No
- **QUERY PARAMETERS:** `q`, `filters...`
- **EXPECTED RESPONSE:** `{"data": [...], "meta": {...}}`

## STORES
### Get Store Profile
- **METHOD:** GET
- **PATH:** `/stores/:id`
- **AUTH REQUIRED:** No
- **EXPECTED RESPONSE:** `{"data": {...}}`

### Get Store Reviews (BACKEND CONTRACT TO CONFIRM)
- **METHOD:** GET
- **PATH:** `/stores/:id/reviews`
- **AUTH REQUIRED:** No
- **EXPECTED RESPONSE:** `{"data": [...]}`

## WISHLIST
### Get Wishlist
- **METHOD:** GET
- **PATH:** `/wishlist`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** `{"data": [...]}`

### Add to Wishlist
- **METHOD:** POST
- **PATH:** `/wishlist/add`
- **AUTH REQUIRED:** Yes
- **REQUEST BODY:** `{"product_id": 123}`
- **EXPECTED RESPONSE:** 200 OK

### Remove from Wishlist
- **METHOD:** DELETE
- **PATH:** `/wishlist/remove/:productId`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** 200 OK

## CART
### Get Cart
- **METHOD:** GET
- **PATH:** `/cart`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** `{"data": [...], "total": 0.0}`

### Add to Cart
- **METHOD:** POST
- **PATH:** `/cart/add`
- **AUTH REQUIRED:** Yes
- **REQUEST BODY:** `{"product_id": 123, "quantity": 1}`
- **EXPECTED RESPONSE:** 200 OK

### Update Cart Item
- **METHOD:** POST
- **PATH:** `/cart/update`
- **AUTH REQUIRED:** Yes
- **REQUEST BODY:** `{"product_id": 123, "quantity": 2}`
- **EXPECTED RESPONSE:** 200 OK

### Remove from Cart
- **METHOD:** DELETE
- **PATH:** `/cart/remove/:productId`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** 200 OK

## ADDRESSES
### Get Addresses
- **METHOD:** GET
- **PATH:** `/addresses`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** `{"data": [...]}`

### Add Address
- **METHOD:** POST
- **PATH:** `/addresses`
- **AUTH REQUIRED:** Yes
- **REQUEST BODY:** `{"name": "...", "phone": "...", "region": "...", "city": "...", "addressLine": "...", "isDefault": true}`
- **EXPECTED RESPONSE:** 201 Created

## CHECKOUT
### Create Order
- **METHOD:** POST
- **PATH:** `/checkout/order`
- **AUTH REQUIRED:** Yes
- **REQUEST BODY:** `{"address_id": 1, "payment_method": "click"}`
- **EXPECTED RESPONSE:** `{"order_id": 123, "payment_url": "..."}`
- **ERROR RESPONSES:** 400 Bad Request (Stock issues)

## ORDERS
### Get Order History
- **METHOD:** GET
- **PATH:** `/orders`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** `{"data": [...]}`

### Get Order Details
- **METHOD:** GET
- **PATH:** `/orders/:id`
- **AUTH REQUIRED:** Yes
- **EXPECTED RESPONSE:** `{"data": {...}}`

## SELLER (BACKEND CONTRACT TO CONFIRM)
### Seller Registration
- **METHOD:** POST
- **PATH:** `/seller/register`
- **AUTH REQUIRED:** Yes

### Seller Dashboard Analytics
- **METHOD:** GET
- **PATH:** `/seller/dashboard`
- **AUTH REQUIRED:** Yes (Seller)

### Seller Inventory
- **METHOD:** GET
- **PATH:** `/seller/inventory`
- **AUTH REQUIRED:** Yes (Seller)

### Seller Orders
- **METHOD:** GET
- **PATH:** `/seller/orders`
- **AUTH REQUIRED:** Yes (Seller)

### Seller Products
- **METHOD:** GET
- **PATH:** `/seller/products`
- **AUTH REQUIRED:** Yes (Seller)

### Update Order Status
- **METHOD:** POST
- **PATH:** `/seller/orders/:id/status`
- **AUTH REQUIRED:** Yes (Seller)

### Update Store Profile
- **METHOD:** POST
- **PATH:** `/seller/profile/update`
- **AUTH REQUIRED:** Yes (Seller)

### Seller Notifications
- **METHOD:** GET
- **PATH:** `/seller/notifications`
- **AUTH REQUIRED:** Yes (Seller)

### Seller Analytics
- **METHOD:** GET
- **PATH:** `/seller/analytics`
- **AUTH REQUIRED:** Yes (Seller)

### Add / Update Product
- **METHOD:** POST
- **PATH:** `/seller/products/create` (or update)
- **AUTH REQUIRED:** Yes (Seller)

## ADMIN (BACKEND CONTRACT TO CONFIRM)
### Admin Login
- **METHOD:** POST
- **PATH:** `/admin/login`
- **AUTH REQUIRED:** No

### Admin Dashboard Analytics
- **METHOD:** GET
- **PATH:** `/admin/dashboard`
- **AUTH REQUIRED:** Yes (Admin)

### Admin Users List
- **METHOD:** GET
- **PATH:** `/admin/users`
- **AUTH REQUIRED:** Yes (Admin)

### Admin Sellers List
- **METHOD:** GET
- **PATH:** `/admin/sellers`
- **AUTH REQUIRED:** Yes (Admin)

### Approve/Reject Seller Verification
- **METHOD:** POST
- **PATH:** `/admin/sellers/verification/approve` (or reject)
- **AUTH REQUIRED:** Yes (Admin)

### Approve/Reject Product Moderation
- **METHOD:** POST
- **PATH:** `/admin/products/moderation/approve` (or reject)
- **AUTH REQUIRED:** Yes (Admin)

### Admin Orders
- **METHOD:** GET
- **PATH:** `/admin/orders`
- **AUTH REQUIRED:** Yes (Admin)

### Admin Complaints
- **METHOD:** GET
- **PATH:** `/admin/complaints`
- **AUTH REQUIRED:** Yes (Admin)

### Admin Payments
- **METHOD:** GET
- **PATH:** `/admin/payments`
- **AUTH REQUIRED:** Yes (Admin)

### Admin Audit Logs
- **METHOD:** GET
- **PATH:** `/admin/audit-logs`
- **AUTH REQUIRED:** Yes (Admin)
