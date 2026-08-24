import re

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'r', encoding='utf-8') as f:
    text = f.read()

translations = {
    "G'isht va Bloklar": {"ru": "Кирпичи и Блоки", "en": "Bricks and Blocks"},
    "Sement va Qorishmalar": {"ru": "Цемент и Смеси", "en": "Cement and Mixtures"},
    "Taxta va Yog'och": {"ru": "Пиломатериалы и Дерево", "en": "Timber and Wood"},
    "Armatura va Metall": {"ru": "Арматура и Металл", "en": "Fittings and Metal"},
    "Tom yopish materiallari": {"ru": "Кровельные материалы", "en": "Roofing Materials"},
    "Issiqlik izolyatsiyasi": {"ru": "Теплоизоляция", "en": "Thermal Insulation"},
    "Bo'yoqlar va Laklar": {"ru": "Краски и Лаки", "en": "Paints and Varnishes"},
    "Santexnika": {"ru": "Сантехника", "en": "Plumbing"},
    "Elektr uskunalari": {"ru": "Электрооборудование", "en": "Electrical Equipment"},
    "Qurilish asboblari": {"ru": "Строительные инструменты", "en": "Construction Tools"},
    "Qum va Shag'al": {"ru": "Песок и Щебень", "en": "Sand and Gravel"},
    "Gipsokarton va Profillar": {"ru": "Гипсокартон и Профили", "en": "Drywall and Profiles"},
    "Kafel va Keramika": {"ru": "Кафель и Керамика", "en": "Tiles and Ceramics"},
    "Eshik va Derazalar": {"ru": "Двери и Окна", "en": "Doors and Windows"},
    "Qulf va Furnituralar": {"ru": "Замки и Фурнитура", "en": "Locks and Hardware"},
    "Poydevor qoplamalari": {"ru": "Фундаментные покрытия", "en": "Foundation Coatings"},
    "Gidroizolyatsiya": {"ru": "Гидроизоляция", "en": "Waterproofing"},
    "Oyna va Ko'zgular": {"ru": "Стекло и Зеркала", "en": "Glass and Mirrors"},
    "Qurilish yelimlari": {"ru": "Строительные клеи", "en": "Construction Adhesives"},
    "Montaj ko'pigi": {"ru": "Монтажная пена", "en": "Mounting Foam"},
    "Suv quvurlari": {"ru": "Водопроводные трубы", "en": "Water Pipes"},
    "Kanalizatsiya tizimlari": {"ru": "Канализационные системы", "en": "Sewer Systems"},
    "Isitish tizimlari": {"ru": "Системы отопления", "en": "Heating Systems"},
    "Ventilyatsiya": {"ru": "Вентиляция", "en": "Ventilation"},
    "Yoritish moslamalari": {"ru": "Осветительные приборы", "en": "Lighting Fixtures"},
    "Kabel va Simlar": {"ru": "Кабели и Провода", "en": "Cables and Wires"},
    "Rozetka va Viklyuchatellar": {"ru": "Розетки и Выключатели", "en": "Sockets and Switches"},
    "Avtomatlar va Shitlar": {"ru": "Автоматы и Щитки", "en": "Circuit Breakers and Panels"},
    "Perforatorlar": {"ru": "Перфораторы", "en": "Rotary Hammers"},
    "Bolgarkalar": {"ru": "Болгарки", "en": "Angle Grinders"},
    "Drel va Shurupovyortlar": {"ru": "Дрели и Шуруповерты", "en": "Drills and Screwdrivers"},
    "Lazerli sathlar": {"ru": "Лазерные уровни", "en": "Laser Levels"},
    "O'lchov asboblari": {"ru": "Измерительные инструменты", "en": "Measuring Tools"},
    "Qo'l asboblari": {"ru": "Ручные инструменты", "en": "Hand Tools"},
    "Bolg'alar": {"ru": "Молотки", "en": "Hammers"},
    "Otvyortkalar": {"ru": "Отвертки", "en": "Screwdrivers"},
    "Ombirlar": {"ru": "Плоскогубцы", "en": "Pliers"},
    "Shpatel va Kelmalar": {"ru": "Шпатели и Кельмы", "en": "Spatulas and Trowels"},
    "Qurilish chelaklari": {"ru": "Строительные ведра", "en": "Construction Buckets"},
    "Narvonlar": {"ru": "Лестницы", "en": "Ladders"},
    "Arra va Kesuvchi asboblar": {"ru": "Пилы и Режущие инструменты", "en": "Saws and Cutting Tools"},
    "Qumqog'oz (Shkurka)": {"ru": "Наждачная бумага", "en": "Sandpaper"},
    "Qurilish kaskalari": {"ru": "Строительные каски", "en": "Construction Helmets"},
    "Qo'lqoplar": {"ru": "Перчатки", "en": "Gloves"},
    "Maxsus poyabzallar": {"ru": "Спецобувь", "en": "Safety Shoes"},
    "Himoya ko'zoynaklari": {"ru": "Защитные очки", "en": "Safety Glasses"},
    "Suyuq mixlar": {"ru": "Жидкие гвозди", "en": "Liquid Nails"},
    "Germetiklar": {"ru": "Герметики", "en": "Sealants"},
    "Qurilish skotchi": {"ru": "Строительный скотч", "en": "Construction Tape"},
    "Dyubel va Samorezlar": {"ru": "Дюбели и Саморезы", "en": "Dowels and Screws"},
    "Mixlar": {"ru": "Гвозди", "en": "Nails"},
    "Bolt va Gaykalar": {"ru": "Болты и Гайки", "en": "Bolts and Nuts"},
    "Zanjir va Troslar": {"ru": "Цепи и Тросы", "en": "Chains and Cables"},
    "Qurilish to'rlari": {"ru": "Строительные сетки", "en": "Construction Nets"},
    "Polietilen plyonkalar": {"ru": "Полиэтиленовые пленки", "en": "Polyethylene Films"},
    "Tarozilar": {"ru": "Весы", "en": "Scales"},
    "Zambilg'achlar (Tachkalar)": {"ru": "Тачки", "en": "Wheelbarrows"},
    "Beton qorishtirgichlar": {"ru": "Бетономешалки", "en": "Concrete Mixers"},
    "Svarka apparatlari": {"ru": "Сварочные аппараты", "en": "Welding Machines"},
    "Elektrodlar": {"ru": "Электроды", "en": "Electrodes"},
    "Kompressorlar": {"ru": "Компрессоры", "en": "Compressors"}
}

def replacer(match):
    uz_raw = match.group(1)
    # Extract actual value without quotes
    uz_val = uz_raw.strip('\'"')
    if uz_val in translations:
        ru_val = translations[uz_val]['ru']
        en_val = translations[uz_val]['en']
        
        ru_fmt = f'"{ru_val}"' if "'" in ru_val else f"'{ru_val}'"
        en_fmt = f'"{en_val}"' if "'" in en_val else f"'{en_val}'"
        
        return f'LocalizedString(uz: {uz_raw}, ru: {ru_fmt}, en: {en_fmt})'
    
    return match.group(0)

new_text = re.sub(r'LocalizedString\(uz:\s*([^\,]+),\s*ru:\s*([^\,]+),\s*en:\s*([^\)]+)\)', replacer, text)

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)

# Do the same for admin_providers.dart if it has hardcoded values!
with open('milliy_metr_admin/lib/core/providers/admin_providers.dart', 'r', encoding='utf-8') as f:
    admin_text = f.read()

# We need to change {'id': '...', 'name': '...'} -> name should remain in uzbek because admin doesn't support multilang yet?
# Wait! In the user's prompt: "Category Model Update: Update Category model to support multi-language name fields"
# Does admin panel use Category Model? Yes, but admin panel has {'id': '...', 'name': '...'}. If they want admin panel updated, I should leave it as is or update it. But they explicitly mentioned Main App (Home Page & Catalog Screen).
# Let's just fix the main app first.
