class CategoryAssetHelper {
  static const Map<String, String> categoryAssets = {
    'cat-1': 'assets/images/categories/cat-1.webp',   // G'isht va Bloklar
    'cat-2': 'assets/images/categories/cat-2.webp',   // Sement va Qorishmalar
    'cat-3': 'assets/images/categories/cat-3.webp',   // Taxta va Yog'och
    'cat-4': 'assets/images/categories/cat-4.webp',   // Armatura va Metall
    'cat-5': 'assets/images/categories/cat-5.webp',   // Tom yopish materiallari
    'cat-6': 'assets/images/categories/cat-6.webp',   // Issiqlik izolyatsiyasi
    'cat-7': 'assets/images/categories/cat-7.webp',   // Bo'yoqlar va Laklar
    'cat-8': 'assets/images/categories/cat-8.webp',   // Santexnika
    'cat-9': 'assets/images/categories/cat-9.webp',   // Elektr uskunalari
    'cat-10': 'assets/images/categories/cat-10.webp', // Qurilish asboblari
    'cat-11': 'assets/images/categories/cat-11.webp', // Qum va Shag'al
    'cat-12': 'assets/images/categories/cat-12.webp', // Gipsokarton va Profillar
    'cat-13': 'assets/images/categories/cat-13.webp', // Kafel va Keramika
    'cat-14': 'assets/images/categories/cat-14.webp', // Eshik va Derazalar
    'cat-15': 'assets/images/categories/cat-15.webp', // Qulf va Furnituralar
    'cat-16': 'assets/images/categories/cat-16.webp', // Poydevor qoplamalari
    'cat-17': 'assets/images/categories/cat-17.webp', // Gidroizolyatsiya
    'cat-18': 'assets/images/categories/cat-18.webp', // Oyna va Ko'zgular
    'cat-19': 'assets/images/categories/cat-19.webp', // Qurilish yelimlari
    'cat-20': 'assets/images/categories/cat-20.webp', // Montaj ko'pigi
    'cat-21': 'assets/images/categories/cat-21.webp', // Suv quvurlari
    'cat-22': 'assets/images/categories/cat-22.webp', // Kanalizatsiya tizimlari
    'cat-23': 'assets/images/categories/cat-23.webp', // Isitish tizimlari
    'cat-24': 'assets/images/categories/cat-24.webp', // Ventilyatsiya
    'cat-25': 'assets/images/categories/cat-25.webp', // Yoritish moslamalari
    'cat-26': 'assets/images/categories/cat-26.webp', // Kabel va Simlar
    'cat-27': 'assets/images/categories/cat-27.webp', // Rozetka va Viklyuchatellar
    'cat-28': 'assets/images/categories/cat-28.webp', // Avtomatlar va Shitlar
    'cat-29': 'assets/images/categories/cat-29.webp', // Perforatorlar
    'cat-30': 'assets/images/categories/cat-30.webp', // Bolgarkalar
    'cat-31': 'assets/images/categories/cat-31.webp', // Drel va Shurupovyortlar
    'cat-32': 'assets/images/categories/cat-32.webp', // Lazerli sathlar
    'cat-33': 'assets/images/categories/cat-33.webp', // O'lchov asboblari
    'cat-34': 'assets/images/categories/cat-34.webp', // Qo'l asboblari
    'cat-35': 'assets/images/categories/cat-35.webp', // Bolg'alar
    'cat-36': 'assets/images/categories/cat-36.webp', // Otvyortkalar
    'cat-37': 'assets/images/categories/cat-37.webp', // Ombirlar
    'cat-38': 'assets/images/categories/cat-38.webp', // Shpatel va Kelmalar
    'cat-39': 'assets/images/categories/cat-39.webp', // Qurilish chelaklari
    'cat-40': 'assets/images/categories/cat-40.webp', // Narvonlar
    'cat-41': 'assets/images/categories/cat-41.webp', // Arra va Kesuvchi asboblar
    'cat-42': 'assets/images/categories/cat-42.webp', // Qumg'og'oz (Shkurka)
    'cat-43': 'assets/images/categories/cat-43.webp', // Qurilish kaskalari
    'cat-44': 'assets/images/categories/cat-44.webp', // Qo'lqoplar
    'cat-45': 'assets/images/categories/cat-45.webp', // Maxsus poyabzallar
    'cat-46': 'assets/images/categories/cat-46.webp', // Himoya ko'zoynaklari
    'cat-47': 'assets/images/categories/cat-47.webp', // Suyuq mixlar
    'cat-48': 'assets/images/categories/cat-48.webp', // Germetiklar
    'cat-49': 'assets/images/categories/cat-49.webp', // Qurilish skotchi
    'cat-50': 'assets/images/categories/cat-50.webp', // Dyubel va Samorezlar
    'cat-51': 'assets/images/categories/cat-51.webp', // Mixlar
    'cat-52': 'assets/images/categories/cat-52.webp', // Bolt va Gaykalar
    'cat-53': 'assets/images/categories/cat-53.webp', // Zanjir va Troslar
    'cat-54': 'assets/images/categories/cat-54.webp', // Qurilish to'rlari
    'cat-55': 'assets/images/categories/cat-55.webp', // Polietilen plyonkalar
    'cat-56': 'assets/images/categories/cat-56.webp', // Tarozilar
    'cat-57': 'assets/images/categories/cat-57.webp', // Zambilg'achlar (Tachkalar)
    'cat-58': 'assets/images/categories/cat-58.webp', // Beton qorishtirgichlar
    'cat-59': 'assets/images/categories/cat-59.webp', // Svarka apparatlari
    'cat-60': 'assets/images/categories/cat-60.webp', // Elektrodlar
    'cat-61': 'assets/images/categories/cat-61.webp', // Kompressorlar
  };

  static String getAssetPath(String id) {
    return categoryAssets[id] ?? 'assets/images/categories/cat-1.webp';
  }
}
