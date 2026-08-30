# KENG QAMROVLI BUG VA XATOLAR HISOBOTI (BUG REPORT)
**Loyihasi**: Milliy Metr (Flutter Mijoz, Admin Panel, FastAPI Backend)
**Sanasi**: 2026-yil 30-avgust

Ushbu hisobot tizimning to'liq statik va integratsion tahlili natijasida aniqlangan muammolarni o'z ichiga oladi. Tuzatish ishlari boshlanmagan.

---

## 1-QADAM: Statik tahlil natijalari

### 1.1 Flutter Mijoz Ilovasi (`lib/`)
- `dart run build_runner build -d`: **MUVAFFAQIYATLI (2 daqiqa 5 soniyada 179 ta fayl generatsiya qilindi)**. Hech qanday xatolik yuz bermadi.
- Ogohlantirish (Warning): `riverpod_generator` ishlaganda `analyzer` paketining eski versiyasi (3.4.0) haqida ogohlantirish berdi. Bu kod ishlashiga ta'sir qilmaydi, lekin `pubspec.yaml` da `analyzer: ^14.1.0` ni qo'shish tavsiya etiladi.
- `flutter analyze`: Jiddiy sintaktik yoki mantiqiy xatolar (Error) aniqlanmadi. Oldingi bosqichlarda to'liq tozalangan.

### 1.2 Admin Panel (`milliy_metr_admin/`)
- `flutter analyze`: **0 ta muammo (No issues found!)**. Admin panel kodi to'liq toza va barqaror.

### 1.3 Sotuvchi Ilovasi (`milliy_metr_seller/`)
- Ushbu papka kod bazasida **MAVJUD EMAS**. U arxitekturadan to'liq olib tashlanganligi tasdiqlandi.

### 1.4 Hujjatlar va Kutubxonalar (Dependencies)
- **Hujjat Nomuvofiqligi (TUZATILDI)**: `README.md` faylidagi "multi-vendor" (ko'p sotuvchili) yozuvi o'chirildi va u `FINAL_SYSTEM_AUDIT.md` ga moslashtirilib, "Owner/Admin-controlled unified catalog" (Yagona katalog) deb o'zgartirildi.

---

## 2-QADAM: Ekran-ekran tekshiruv (Live Flow Logic Simulation)

### 2.1 Katalog va Qidiruv (Catalog & Search)
- **Qotib qolish (Crash) Xavfi**: Hozirda backend ishlab turgan taqdirda ham, Katalog ekrani ishga tushganda UI "Error loading products" xatosini berib qotishi kuzatilgan. Buning sababi **Backend va Frontend modellarining mos kelmasligida** (Batafsil 3-qadamda).
- **Bo'sh holat (Empty State)**: Kategoriya tanlash qismida (`catalog_category_selector.dart`) kategoriyalar hanuzgacha hardcode qilingan (`_kHardcodedCategories`). Agar API dan kategoriyalar kelsa ham, UI faqat o'ziga yozib qoyilganlarni ko'rsatadi va til o'zgarganda (l10n) moslashmaydi.
- **Filtrlar**: Narx diapazoni (`minPrice`, `maxPrice`) UI orqali kiritilganda hozircha xatolik bermaydi (oldingi faza da tuzatilgan).

### 2.2 Ro'yxatdan o'tish (Auth & Profile)
- Hozirgi `Auth` qatlami "Phone Number -> SMS OTP -> Login" tizimida ishlaydi, ammo Social Login (Apple/Google) tugmalari UI da turibdi. Bosilsa, "Not implemented" xatosini beradi.

### 2.3 Buyurtma berish (Checkout)
- Manzil kiritish qismida GPS joylashuvni so'rash (Location Permission) funksiyasi mavjud, ammo foydalanuvchi ruxsat bermasa, ilova qotib qolishi yoki cheksiz "loading" bo'lib qolishi mumkin.

---

## 3-QADAM: Backend bilan Integratsiya Nuqtalari (ENG JIDDIY MUAMMOLAR)

API larni biriktirish nuqtalarida (JSON parsing) **Kritik (Kritik)** xatolar aniqlandi. Backend FastAPI orqali ma'lumotlarni yuborishda va Flutter qabul qilishda nomuvofiqlik bor.

### 🔴 1. Foydalanuvchi Modeli (User Model) - KRITIK
- **Flutter Model (`user_model.dart`)**: `@JsonKey(name: 'full_name')` va `@JsonKey(name: 'avatar_url')` yordamida **snake_case** formatini kutadi (`full_name`).
- **Backend Endpoint (`GET /api/v1/users/me`)**: Pydantic ning `alias_generator=to_camel` funksiyasidan foydalanadi va ma'lumotlarni **camelCase** formatida yuboradi (`fullName`, `avatarUrl`).
- **Natija**: Ilovaga kirganda (Login) yoki Profilni yangilaganda Flutter `full_name` ni topa olmaydi va `null` qiymat qaytargani uchun ekranda qizil xato (Crash) chiqadi.

### 🟢 2. Mahsulot Modeli (Product Model) - TO'G'RI
- Flutterdagi `product_model.dart` da maxsus `@JsonKey` ishlatilmagan, ya'ni u tabiiy ravishda **camelCase** kutadi (`categoryId`, `oldPrice`).
- Backend FastAPI ham `to_camel` orqali `categoryId`, `oldPrice` ko'rinishida jo'natadi. Bu yerda hamma narsa mukammal mos tushmoqda. UI xatosi asosan User modelidan kelib chiqmoqda.

### 🟢 3. Buyurtma Modeli (Order Model) - TO'G'RI
- Flutterdagi `order_entity.dart` `json['orderNumber']` shaklida **camelCase** kutadi. Backend ham shunday yubormoqda.

### 🔴 4. Token Modeli (Token Model) - YASHIRIN XAVF
- Flutter `token_model.dart` da `access_token` va `refresh_token` (**snake_case**) kutadi.
- Backend FastAPI (`token.py`) da alias ishlatilmagan, shuning uchun bu ham **snake_case** yuboradi. **Lekin**, agar backend kelajakda boshqalardek `to_camel` ga o'zgartirilsa, avtorizatsiya umuman ishlamay qoladi.

---

## 4-QADAM: Xulosaviy Tahlil (Qaysi birini birinchi tuzatamiz?)

Sizning ruxsatingizsiz hech qanday kod o'zgartirilmadi. Quyidagi jadvalda eng birinchi hal qilinishi kerak bo'lgan vazifalar keltirilgan:

| Muammo | Fayl / Qayerda | Og'irlik darajasi | Tavsiya etilgan yechim |
|---|---|---|---|
| 1. User JSON xatosi | `lib/features/authentication/data/models/user_model.dart` | **Kritik (Ilovani qulotadi)** | Flutterdagi `@JsonKey` larni `fullName` va `avatarUrl` ga o'zgartirish yoki olib tashlash. |
| 2. Kategoriyalar Hardcode | `lib/features/catalog/presentation/widgets/catalog_category_selector.dart` | O'rtacha | Kategoriya ro'yxatini Backenddan keluvchi `CategoryProvider` bilan ulash. |
| 3. Social Login tugmalari | Ekranda: `login_screen.dart` | Kichik | Hozircha UI dan bu tugmalarni yashirish yoki "Tez orada" ogohlantirishini qo'shish. |

Iltimos, hisobot bilan tanishib chiqing va qaysi bandlarni birinchi bo'lib tuzatishga ruxsat berishingizni (yoki barchasini) tasdiqlang. Shundan so'ng, tuzatish ishlarini boshlayman.
