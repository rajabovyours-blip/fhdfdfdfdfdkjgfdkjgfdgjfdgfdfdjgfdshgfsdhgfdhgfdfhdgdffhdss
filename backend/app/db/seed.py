"""
Production-safe seed script for Milliy Metr.
- Idempotent: only inserts categories if none exist
- Does NOT create demo/fake products
- Products are managed exclusively through Admin Panel
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.category import Category
import uuid

# Complete 61-category catalog with proper trilingual names
CATEGORIES = [
    (1, "G'isht va Bloklar", "Кирпич и Блоки", "Bricks and Blocks"),
    (2, "Sement va Qorishmalar", "Цемент и Смеси", "Cement and Mixtures"),
    (3, "Yog'och materiallar", "Пиломатериалы", "Lumber"),
    (4, "Armatura va Metal", "Арматура и Металл", "Rebar and Metal"),
    (5, "Tom yopish materiallari", "Кровельные материалы", "Roofing Materials"),
    (6, "Issiqlik izolyatsiyasi", "Теплоизоляция", "Thermal Insulation"),
    (7, "Bo'yoqlar va Laklar", "Краски и Лаки", "Paints and Varnishes"),
    (8, "Santexnika", "Сантехника", "Plumbing"),
    (9, "Elektr jihozlari", "Электрооборудование", "Electrical Equipment"),
    (10, "Qurilish asboblari", "Строительные инструменты", "Construction Tools"),
    (11, "Qum va Shag'al", "Песок и Гравий", "Sand and Gravel"),
    (12, "Gipsokarton va Profillar", "Гипсокартон и Профили", "Drywall and Profiles"),
    (13, "Kafel va Keramika", "Плитка и Керамика", "Tiles and Ceramics"),
    (14, "Eshiklar va Derazalar", "Двери и Окна", "Doors and Windows"),
    (15, "Qulflar va Uskuna", "Замки и Фурнитура", "Locks and Hardware"),
    (16, "Pol qoplamalari", "Напольные покрытия", "Floor Coverings"),
    (17, "Gidroizolyatsiya", "Гидроизоляция", "Waterproofing"),
    (18, "Oyna va Ko'zgular", "Стекло и Зеркала", "Glass and Mirrors"),
    (19, "Qurilish yelimlari", "Строительные клеи", "Construction Adhesives"),
    (20, "Montaj ko'pigi", "Монтажная пена", "Mounting Foam"),
    (21, "Suv quvurlari", "Водопроводные трубы", "Water Pipes"),
    (22, "Kanalizatsiya tizimlari", "Канализационные системы", "Sewage Systems"),
    (23, "Isitish tizimlari", "Системы отопления", "Heating Systems"),
    (24, "Ventilyatsiya", "Вентиляция", "Ventilation"),
    (25, "Yoritish asboblari", "Осветительные приборы", "Lighting Fixtures"),
    (26, "Kabellar va Simlar", "Кабели и Провода", "Cables and Wires"),
    (27, "Rozetkalar va O'chirg'ichlar", "Розетки и Выключатели", "Sockets and Switches"),
    (28, "Avtomatlar va Shitlar", "Автоматы и Щиты", "Circuit Breakers and Panels"),
    (29, "Perforatorlar", "Перфораторы", "Rotary Hammers"),
    (30, "Bolg'arlar", "Болгарки", "Angle Grinders"),
    (31, "Burg'ulash va Shurupvertlar", "Дрели и Шуруповёрты", "Drills and Screwdrivers"),
    (32, "Lazer daraja o'lchagichlar", "Лазерные уровни", "Laser Levels"),
    (33, "O'lchash asboblari", "Измерительные инструменты", "Measuring Tools"),
    (34, "Qo'l asboblari", "Ручные инструменты", "Hand Tools"),
    (35, "Bolg'alar", "Молотки", "Hammers"),
    (36, "Tornavitlar", "Отвёртки", "Screwdrivers"),
    (37, "Ombirlar", "Плоскогубцы", "Pliers and Tongs"),
    (38, "Shpatyollar va Malalar", "Шпатели и Кельмы", "Spatulas and Trowels"),
    (39, "Qurilish chelaklar", "Строительные вёдра", "Construction Buckets"),
    (40, "Narvonlar", "Лестницы", "Ladders"),
    (41, "Arra va Kesuvchi asboblar", "Пилы и режущие инструменты", "Saws and Cutting"),
    (42, "Qum qog'oz", "Наждачная бумага", "Sandpaper"),
    (43, "Qurilish dubulg'alari", "Строительные каски", "Construction Helmets"),
    (44, "Ish qo'lqoplari", "Рабочие перчатки", "Work Gloves"),
    (45, "Xavfsizlik poyabzali", "Защитная обувь", "Safety Shoes"),
    (46, "Himoya ko'zoynaklari", "Защитные очки", "Safety Glasses"),
    (47, "Suyuq mixlar", "Жидкие гвозди", "Liquid Nails"),
    (48, "Germetiklar", "Герметики", "Sealants"),
    (49, "Qurilish lentalari", "Строительные ленты", "Construction Tape"),
    (50, "Dyubellar va Shuruplar", "Дюбели и Шурупы", "Dowels and Screws"),
    (51, "Mixlar", "Гвозди", "Nails"),
    (52, "Boltlar va Gaykalar", "Болты и Гайки", "Bolts and Nuts"),
    (53, "Zanjirlar va Troslar", "Цепи и Тросы", "Chains and Cables"),
    (54, "Qurilish to'rlari", "Строительные сетки", "Construction Nets"),
    (55, "Polietilen plyonkalar", "Полиэтиленовые плёнки", "Polyethylene Films"),
    (56, "Tarozilar", "Весы", "Scales"),
    (57, "Aravachalar", "Тачки", "Wheelbarrows"),
    (58, "Beton qorishtirgichlar", "Бетономешалки", "Cement Mixers"),
    (59, "Payvandlash apparatlari", "Сварочные аппараты", "Welding Machines"),
    (60, "Elektrodlar", "Электроды", "Electrodes"),
    (61, "Kompressorlar", "Компрессоры", "Compressors"),
]

async def seed_data(session: AsyncSession):
    """Idempotent seed: only creates categories if none exist. Never creates demo products."""
    # Ensure initial owner accounts exist
    from app.models.user import User, RoleEnum
    from app.security.hashing import get_password_hash
    
    owner1_check = await session.execute(select(User).where(User.username == "manga_qaralarin"))
    if not owner1_check.scalar_one_or_none():
        owner1 = User(
            id=uuid.uuid4(),
            username="manga_qaralarin",
            full_name="Owner 1",
            phone=None,
            email=None,
            hashed_password=get_password_hash("achika1337"),
            role=RoleEnum.OWNER,
            is_active=True
        )
        session.add(owner1)
        
    owner2_check = await session.execute(select(User).where(User.username == "bekzodbek"))
    if not owner2_check.scalar_one_or_none():
        owner2 = User(
            id=uuid.uuid4(),
            username="bekzodbek",
            full_name="Owner 2",
            phone=None,
            email=None,
            hashed_password=get_password_hash("rajabov"),
            role=RoleEnum.OWNER,
            is_active=True
        )
        session.add(owner2)
        
    await session.commit()
    print("Seeded owner accounts.")

    result = await session.execute(select(func.count()).select_from(Category))
    count = result.scalar()
    
    if count >= 61:
        print(f"Categories already exist ({count}). Skipping seed.")
        return
    
    if count > 0 and count < 61:
        print(f"WARNING: Found {count} categories (expected 61). Run production_seed_fix.py to repair.")
        return
    
    # Insert all 61 categories
    print("Seeding 61 production categories...")
    for cat_num, uz_name, ru_name, en_name in CATEGORIES:
        cat = Category(
            id=uuid.uuid4(),
            name={"uz": uz_name, "ru": ru_name, "en": en_name},
            description={
                "uz": f"{uz_name} toifasidagi qurilish materiallari",
                "ru": f"Строительные материалы категории {ru_name}",
                "en": f"Construction materials in {en_name} category"
            },
            icon_url=f"assets/images/categories/cat-{cat_num}.webp",
            image_url=f"assets/images/categories/cat-{cat_num}.webp",
            is_featured=(cat_num <= 10),
            order_index=cat_num,
        )
        session.add(cat)
    
    await session.commit()
    print("Seeded 61 categories with proper UZ/RU/EN localization.")
    print("Products are managed exclusively through Admin Panel. No demo products seeded.")
