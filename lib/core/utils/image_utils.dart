class ImageUtils {
  static String getFullImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('assets/')) return rawUrl;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
    if (rawUrl.startsWith('/uploads/')) {
      return 'https://milliymetr-backend.onrender.com$rawUrl';
    }
    if (rawUrl.startsWith('uploads/')) {
      return 'https://milliymetr-backend.onrender.com/$rawUrl';
    }
    // Tanilmagan format — masalan bazada faqat fayl nomi saqlangan
    // ("cat1.png" kabi, "/uploads/" prefiksisiz). Buni to'g'ridan-to'g'ri
    // tarmoqqa yuborib xato chiqarish o'rniga, yuklangan rasm manzili
    // deb hisoblab, to'g'ri manzilga moslaymiz.
    if (!rawUrl.contains('/')) {
      return 'https://milliymetr-backend.onrender.com/uploads/images/$rawUrl';
    }
    return rawUrl;
  }
}
