// Veb'da rasm strategiyasini aniqlaydi.
// Sukut bo'yicha 'network' — Image.network brauzerning o'z rasm quvuridan
// foydalanadi va CanvasKit'dagi ImageBitmap/texImage2D kesh buzilish
// muammosini oldini oladi (sahifalar orasida navigatsiya qilganda rasmlar
// "buzilgan" holatda ko'rinmas).
// Backend allaqachon Cache-Control: public, max-age=31536000, immutable
// sarlavhasini beradi — brauzer rasmlarni o'zi keshlaydi.
// ?img=cached orqali eski xatti-harakatni sinab ko'rish mumkin.
String get webImgMode => Uri.base.queryParameters['img'] ?? 'network';
