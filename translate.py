import json
import re

uzbek_translations = {
    'Bricks and Blocks': 'G\'isht va Bloklar',
    'Cement and Mixtures': 'Sement va Qorishmalar',
    'Lumber': 'Taxta va Yog\'och',
    'Rebar and Metal': 'Armatura va Metall',
    'Roofing Materials': 'Tom yopish materiallari',
    'Thermal Insulation': 'Issiqlik izolyatsiyasi',
    'Paints and Varnishes': 'Bo\'yoqlar va Laklar',
    'Plumbing': 'Santexnika',
    'Electrical Equipment': 'Elektr uskunalari',
    'Construction Tools': 'Qurilish asboblari',
    'Sand and Gravel': 'Qum va Shag\'al',
    'Drywall and Profiles': 'Gipsokarton va Profillar',
    'Tiles and Ceramics': 'Kafel va Keramika',
    'Doors and Windows': 'Eshik va Derazalar',
    'Locks and Hardware': 'Qulf va Furnituralar',
    'Floor Coverings': 'Poydevor qoplamalari',
    'Waterproofing': 'Gidroizolyatsiya',
    'Glass and Mirrors': 'Oyna va Ko\'zgular',
    'Construction Adhesives': 'Qurilish yelimlari',
    'Mounting Foam': 'Montaj ko\'pigi',
    'Water Pipes': 'Suv quvurlari',
    'Sewage Systems': 'Kanalizatsiya tizimlari',
    'Heating Systems': 'Isitish tizimlari',
    'Ventilation': 'Ventilyatsiya',
    'Lighting Fixtures': 'Yoritish moslamalari',
    'Cables and Wires': 'Kabel va Simlar',
    'Sockets and Switches': 'Rozetka va Viklyuchatellar',
    'Circuit Breakers and Panels': 'Avtomatlar va Shitlar',
    'Rotary Hammers': 'Perforatorlar',
    'Angle Grinders': 'Bolgarkalar',
    'Drills and Screwdrivers': 'Drel va Shurupovyortlar',
    'Laser Levels': 'Lazerli sathlar',
    'Measuring Tools': 'O\'lchov asboblari',
    'Hand Tools': 'Qo\'l asboblari',
    'Hammers': 'Bolg\'alar',
    'Screwdrivers': 'Otvyortkalar',
    'Pliers and Tongs': 'Ombirlar',
    'Spatulas and Trowels': 'Shpatel va Kelmalar',
    'Construction Buckets': 'Qurilish chelaklari',
    'Ladders': 'Narvonlar',
    'Saws and Cutting': 'Arra va Kesuvchi asboblar',
    'Sandpaper': 'Qumqog\'oz (Shkurka)',
    'Construction Helmets': 'Qurilish kaskalari',
    'Work Gloves': 'Qo\'lqoplar',
    'Safety Shoes': 'Maxsus poyabzallar',
    'Safety Glasses': 'Himoya ko\'zoynaklari',
    'Liquid Nails': 'Suyuq mixlar',
    'Sealants': 'Germetiklar',
    'Construction Tape': 'Qurilish skotchi',
    'Dowels and Screws': 'Dyubel va Samorezlar',
    'Nails': 'Mixlar',
    'Bolts and Nuts': 'Bolt va Gaykalar',
    'Chains and Cables': 'Zanjir va Troslar',
    'Construction Nets': 'Qurilish to\'rlari',
    'Polyethylene Films': 'Polietilen plyonkalar',
    'Scales': 'Tarozilar',
    'Wheelbarrows': 'Zambilg\'achlar (Tachkalar)',
    'Cement Mixers': 'Beton qorishtirgichlar',
    'Welding Machines': 'Svarka apparatlari',
    'Electrodes': 'Elektrodlar',
    'Compressors': 'Kompressorlar'
}

def translate_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for en, uz in uzbek_translations.items():
        content = content.replace(f"'{en}'", f"'{uz}'")
        content = content.replace(f'"{en}"', f'"{uz}"')
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

translate_file('milliy_metr_admin/lib/core/providers/admin_providers.dart')
translate_file('lib/features/categories/data/repositories/category_repository_impl.dart')
print('Translation complete.')
