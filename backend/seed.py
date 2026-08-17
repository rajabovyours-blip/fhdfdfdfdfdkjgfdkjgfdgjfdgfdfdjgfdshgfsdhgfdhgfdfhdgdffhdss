import asyncio
import uuid
import os
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from app.core.config import settings
from app.models.base import Base
from app.models.users import User, Role
from app.models.marketplace import Category, Product, ProductImage
from app.security.hashing import get_password_hash
import app.models.orders
import app.models.order
import app.models.user
import app.models.users

# The backend runs on port 8000. Mobile emulator accesses local backend via 10.0.2.2.
# We will use relative URLs for images which flutter will resolve against the base URL,
# or we can just use the path that main.py serves them on.
# We mounted StaticFiles on /uploads.

async def seed_data():
    engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI, echo=False)
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

    Session = async_sessionmaker(engine, expire_on_commit=False)

    async with Session() as db:
        print("Seeding roles...")
        admin_role = Role(name="admin", description="Administrator")
        customer_role = Role(name="customer", description="Standard customer")
        db.add_all([admin_role, customer_role])
        await db.flush()

        print("Seeding admin...")
        admin_user = User(
            email="admin@milliymetr.uz",
            password_hash=get_password_hash("admin123"),
            phone="+998900000000",
            first_name="Admin",
            last_name="User",
            role_id=admin_role.id
        )
        db.add(admin_user)
        await db.flush()

        print("Seeding categories...")
        cat_1 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-1.svg", name_uz="G'isht va Bloklar", name_ru="Кирпичи и Блоки", name_en="Bricks and Blocks")
        cat_2 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-2.svg", name_uz="Sement va Qorishmalar", name_ru="Цемент и смеси", name_en="Cement and Mixtures")
        cat_3 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-3.svg", name_uz="Yog'och Materiallari", name_ru="Пиломатериалы", name_en="Lumber")
        cat_4 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-4.svg", name_uz="Armatura va Metall", name_ru="Арматура и металл", name_en="Rebar and Metal")
        cat_5 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-5.svg", name_uz="Tom Yopish Materiallari", name_ru="Кровельные материалы", name_en="Roofing Materials")
        cat_6 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-6.svg", name_uz="Issiqlik Izolyatsiyasi", name_ru="Теплоизоляция", name_en="Thermal Insulation")
        cat_7 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-7.svg", name_uz="Bo'yoqlar va Laklar", name_ru="Краски и лаки", name_en="Paints and Varnishes")
        cat_8 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-8.svg", name_uz="Santexnika", name_ru="Сантехника", name_en="Plumbing")
        cat_9 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-9.svg", name_uz="Elektr Jihozlari", name_ru="Электрооборудование", name_en="Electrical Equipment")
        cat_10 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-10.svg", name_uz="Qurilish Asboblari", name_ru="Строительные инструменты", name_en="Construction Tools")
        cat_11 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-11.svg", name_uz="Qum va Shag'al", name_ru="Песок и щебень", name_en="Sand and Gravel")
        cat_12 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-12.svg", name_uz="Gipsokarton va Profillar", name_ru="Гипсокартон и профили", name_en="Drywall and Profiles")
        cat_13 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-13.svg", name_uz="Kafel va Keramika", name_ru="Плитка и керамика", name_en="Tiles and Ceramics")
        cat_14 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-14.svg", name_uz="Eshik va Derazalar", name_ru="Двери и окна", name_en="Doors and Windows")
        cat_15 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-15.svg", name_uz="Qulflar va Furnitura", name_ru="Замки и фурнитура", name_en="Locks and Hardware")
        cat_16 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-16.svg", name_uz="Pol Qoplamalari", name_ru="Напольные покрытия", name_en="Floor Coverings")
        cat_17 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-17.svg", name_uz="Gidroizolyatsiya", name_ru="Гидроизоляция", name_en="Waterproofing")
        cat_18 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-18.svg", name_uz="Shishalar va Ko'zgular", name_ru="Стекло и зеркала", name_en="Glass and Mirrors")
        cat_19 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-19.svg", name_uz="Qurilish Yelimlar", name_ru="Строительные клеи", name_en="Construction Adhesives")
        cat_20 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-20.svg", name_uz="Montaj Ko'piklari", name_ru="Монтажная пена", name_en="Mounting Foam")
        cat_21 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-21.svg", name_uz="Suv Quvurlari", name_ru="Водопроводные трубы", name_en="Water Pipes")
        cat_22 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-22.svg", name_uz="Kanalizatsiya Tizimlari", name_ru="Канализационные системы", name_en="Sewage Systems")
        cat_23 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-23.svg", name_uz="Isitish Tizimlari", name_ru="Системы отопления", name_en="Heating Systems")
        cat_24 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-24.svg", name_uz="Ventilyatsiya", name_ru="Вентиляция", name_en="Ventilation")
        cat_25 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-25.svg", name_uz="Yoritish Chiroqlari", name_ru="Осветительные приборы", name_en="Lighting Fixtures")
        cat_26 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-26.svg", name_uz="Kabel va Simlar", name_ru="Кабели и провода", name_en="Cables and Wires")
        cat_27 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-27.svg", name_uz="Rozetka va Viklyuchatellar", name_ru="Розетки и выключатели", name_en="Sockets and Switches")
        cat_28 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-28.svg", name_uz="Avtomatlar va Shitlar", name_ru="Автоматы и щиты", name_en="Circuit Breakers and Panels")
        cat_29 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-29.svg", name_uz="Perforatorlar", name_ru="Перфораторы", name_en="Rotary Hammers")
        cat_30 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-30.svg", name_uz="Bolgarkalar", name_ru="Болгарки", name_en="Angle Grinders")
        cat_31 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-31.svg", name_uz="Drellar va Shurupovyortlar", name_ru="Дрели и шуруповерты", name_en="Drills and Screwdrivers")
        cat_32 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-32.svg", name_uz="Lazerli Sathiylar", name_ru="Лазерные уровни", name_en="Laser Levels")
        cat_33 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-33.svg", name_uz="O'lchov Asboblari", name_ru="Измерительные инструменты", name_en="Measuring Tools")
        cat_34 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-34.svg", name_uz="Qo'l Asboblari", name_ru="Ручной инструмент", name_en="Hand Tools")
        cat_35 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-35.svg", name_uz="Bolg'alar", name_ru="Молотки", name_en="Hammers")
        cat_36 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-36.svg", name_uz="Otvortkalar", name_ru="Отвертки", name_en="Screwdrivers")
        cat_37 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-37.svg", name_uz="Pense va Ombur", name_ru="Плоскогубцы и клещи", name_en="Pliers and Tongs")
        cat_38 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-38.svg", name_uz="Spatel va Molalar", name_ru="Шпатели и мастерки", name_en="Spatulas and Trowels")
        cat_39 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-39.svg", name_uz="Qurilish Paqirlari", name_ru="Строительные ведра", name_en="Construction Buckets")
        cat_40 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-40.svg", name_uz="Narvonlar", name_ru="Лестницы и стремянки", name_en="Ladders")
        cat_41 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-41.svg", name_uz="Arra va Kesish", name_ru="Пилы и резка", name_en="Saws and Cutting")
        cat_42 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-42.svg", name_uz="Silliqlash Qog'ozlari", name_ru="Наждачная бумага", name_en="Sandpaper")
        cat_43 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-43.svg", name_uz="Qurilish Kaskalari", name_ru="Строительные каски", name_en="Construction Helmets")
        cat_44 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-44.svg", name_uz="Ishchi Qo'lqoplar", name_ru="Рабочие перчатки", name_en="Work Gloves")
        cat_45 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-45.svg", name_uz="Xavfsizlik Oyoq Kiyimlari", name_ru="Защитная обувь", name_en="Safety Shoes")
        cat_46 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-46.svg", name_uz="Himoya Ko'zoynaklari", name_ru="Защитные очки", name_en="Safety Glasses")
        cat_47 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-47.svg", name_uz="Suyuq Mixlar", name_ru="Жидкие гвозди", name_en="Liquid Nails")
        cat_48 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-48.svg", name_uz="Germetiklar", name_ru="Герметики", name_en="Sealants")
        cat_49 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-49.svg", name_uz="Qurilish Skotchi", name_ru="Строительный скотч", name_en="Construction Tape")
        cat_50 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-50.svg", name_uz="Dubellar va Vintlar", name_ru="Дюбели и винты", name_en="Dowels and Screws")
        cat_51 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-51.svg", name_uz="Mixlar", name_ru="Гвозди", name_en="Nails")
        cat_52 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-52.svg", name_uz="Bolt va Gaykalar", name_ru="Болты и гайки", name_en="Bolts and Nuts")
        cat_53 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-53.svg", name_uz="Zanjir va Troslar", name_ru="Цепи и тросы", name_en="Chains and Cables")
        cat_54 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-54.svg", name_uz="Qurilish To'rlari", name_ru="Строительные сетки", name_en="Construction Nets")
        cat_55 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-55.svg", name_uz="Polietilen Plenkalar", name_ru="Полиэтиленовые пленки", name_en="Polyethylene Films")
        cat_56 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-56.svg", name_uz="Tarozilar", name_ru="Весы", name_en="Scales")
        cat_57 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-57.svg", name_uz="G'ildirakli Aravalar", name_ru="Тележки", name_en="Wheelbarrows")
        cat_58 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-58.svg", name_uz="Sement Qorishtirgichlar", name_ru="Бетономешалки", name_en="Cement Mixers")
        cat_59 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-59.svg", name_uz="Payvandlash Apparatlari", name_ru="Сварочные аппараты", name_en="Welding Machines")
        cat_60 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-60.svg", name_uz="Elektrodlar", name_ru="Электроды", name_en="Electrodes")
        cat_61 = Category(id=uuid.uuid4(), icon_url="assets/svg/categories/cat-61.svg", name_uz="Kompressorlar", name_ru="Компрессоры", name_en="Compressors")

        db.add_all([cat_1, cat_2, cat_3, cat_4, cat_5, cat_6, cat_7, cat_8, cat_9, cat_10, cat_11, cat_12, cat_13, cat_14, cat_15, cat_16, cat_17, cat_18, cat_19, cat_20, cat_21, cat_22, cat_23, cat_24, cat_25, cat_26, cat_27, cat_28, cat_29, cat_30, cat_31, cat_32, cat_33, cat_34, cat_35, cat_36, cat_37, cat_38, cat_39, cat_40, cat_41, cat_42, cat_43, cat_44, cat_45, cat_46, cat_47, cat_48, cat_49, cat_50, cat_51, cat_52, cat_53, cat_54, cat_55, cat_56, cat_57, cat_58, cat_59, cat_60, cat_61])
        await db.flush()

        print("Seeding products...")
        products_data = [
            (cat_2, "Portland Sement M-400", "Портландцемент М-400", "Portland Cement M-400", "Yuqori sifatli qoplamali portland sement 50kg.", "Высококачественный портландцемент 50кг.", "High quality portland cement 50kg bag.", 55000, 60000, "cement.jpg", 1000),
            (cat_1, "Qizil pishgan g'isht", "Красный обожженный кирпич", "Red baked brick", "Standart o'lchamdagi qizil pishgan g'isht.", "Красный обожженный кирпич стандартного размера.", "Standard size red baked brick.", 1200, 1500, "brick.jpg", 50000),
            (cat_4, "Armatura A500C 12mm", "Арматура А500С 12мм", "Rebar A500C 12mm", "Qurilish uchun mustahkam po'lat armatura (1m narxi).", "Прочная стальная арматура для строительства (цена за 1м).", "Durable steel rebar for construction (price per 1m).", 8500, None, "rebar.jpg", 5000),
            (cat_7, "Oq akril bo'yoq 10L", "Белая акриловая краска 10Л", "White acrylic paint 10L", "Ichki ishlar uchun yuviladigan oq akril bo'yoq.", "Моющаяся белая акриловая краска для внутренних работ.", "Washable white acrylic paint for interior works.", 120000, 150000, "paint.jpg", 200),
            (cat_3, "Qarag'ay taxta 50x150", "Доска сосновая 50х150", "Pine wooden board 50x150", "Quritilgan qarag'ay yog'och taxtasi.", "Сушеная сосновая деревянная доска.", "Dried pine wooden board.", 45000, None, "timber.jpg", 300),
            (cat_8, "PVX santexnika quvuri", "ПВХ сантехническая труба", "PVC plumbing pipe", "Issiq va sovuq suv uchun PVX quvur.", "ПВХ труба для горячей и холодной воды.", "PVC pipe for hot and cold water.", 12000, None, "pipes.jpg", 800),
            (cat_5, "Profnastil tom uchun", "Профнастил кровельный", "Corrugated metal roofing", "Zangga qarshi qoplamali profnastil list.", "Профнастил с антикоррозийным покрытием.", "Corrugated metal sheet with anti-corrosion coating.", 65000, 75000, "roofing.jpg", 400),
            (cat_6, "Minvata issiqlik izolyatsiyasi", "Минвата теплоизоляция", "Mineral wool insulation", "Shisha tolali issiqlik izolyatsiyasi ruloni.", "Рулон стекловолоконной теплоизоляции.", "Fiberglass thermal insulation roll.", 180000, 200000, "insulation.jpg", 150),
            (cat_26, "Mis kabel VVGng 3x2.5", "Медный кабель ВВГнг 3х2.5", "Copper cable VVGng 3x2.5", "Elektr tarmog'i uchun sifatli mis kabel.", "Качественный медный кабель для электросети.", "High-quality copper cable for electrical network.", 15000, 18000, "cable.jpg", 2000),
            (cat_10, "Elektr drel 750W", "Электродрель 750Вт", "Electric drill 750W", "Professional zarbali elektr drel.", "Профессиональная ударная электродрель.", "Professional impact electric drill.", 450000, 500000, "drill.jpg", 50),
        ]

        products_to_add = []
        for cat, n_uz, n_ru, n_en, d_uz, d_ru, d_en, price, old_price, img_file, stock in products_data:
            prod = Product(
                category_id=cat.id,
                name_uz=n_uz, name_ru=n_ru, name_en=n_en,
                description_uz=d_uz, description_ru=d_ru, description_en=d_en,
                price=float(price),
                old_price=float(old_price) if old_price else None,
                stock=stock,
                status="approved",
                created_by_id=admin_user.id
            )
            db.add(prod)
            await db.flush()

            # Add Image
            # Note: the flutter app accesses http://10.0.2.2:8000 in dev
            # We'll use a relative path like /uploads/images/file.jpg and Flutter should parse it
            # Or absolute if flutter isn't prepending base url. Let's provide absolute placeholder.
            # Assuming emulator env
            base_url = "http://10.0.2.2:8000"
            if os.getenv("API_URL"):
                base_url = os.getenv("API_URL").replace("/api/v1", "")

            img = ProductImage(
                product_id=prod.id,
                image_url=f"{base_url}/uploads/images/{img_file}",
                is_primary=True
            )
            db.add(img)

        await db.commit()
        print("Seeding complete.")
        
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(seed_data())
