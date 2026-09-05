import 'package:flutter/material.dart';

/// Ekran kengligiga qarab, mahsulot to'ridagi ustunlar sonini hisoblaydi.
///
/// [mobileColumns] — shu ekran uchun mobilda mo'ljallangan asl ustunlar soni
/// (masalan 2 yoki 3). Tor ekranda (telefon, kIsWeb bo'lmasa yoki web'da
/// tor oyna) hech narsa o'zgarmaydi — aynan shu son qaytadi. Ekran
/// kengaygan sari (kompyuter brauzeri) ustunlar soni bosqichma-bosqich
/// oshadi, shunda kartalar cho'zilib ketmaydi.
int responsiveCrossAxisCount(BuildContext context, {required int mobileColumns}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1200) return mobileColumns + 3; // katta kompyuter oynasi
  if (width >= 900) return mobileColumns + 2;  // o'rtacha kompyuter/planshet
  if (width >= 700) return mobileColumns + 1;  // katta planshet
  return mobileColumns; // telefon — hech narsa o'zgarmaydi
}
