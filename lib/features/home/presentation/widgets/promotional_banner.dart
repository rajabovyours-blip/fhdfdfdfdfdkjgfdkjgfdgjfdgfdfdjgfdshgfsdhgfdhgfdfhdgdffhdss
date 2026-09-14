import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/core/utils/image_utils.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:milliy_metr/shared/components/brand_image_loader.dart';
import 'package:milliy_metr/features/home/presentation/widgets/video_banner_player.dart';

class PromotionalBanner extends StatefulWidget {
  final List<BannerEntity> banners;
  const PromotionalBanner({super.key, required this.banners});

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    
    // Auto add https if missing
    if (!urlString.startsWith('http')) {
      urlString = 'https://$urlString';
    }
    
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Real banner suratlari ~2.4:1 nisbatda (1920x800) yuklanadi —
            // konteyner nisbatini aynan shunga moslaymiz, shunda BoxFit.cover
            // deyarli hech narsani kesmaydi va yon tomonlarda (yoki
            // tepa/pastda) rangli bo'sh joy qolmaydi. Video bannerlar ham
            // aynan shu nisbatda tayyorlanishi kerak.
            final bannerHeight =
                (constraints.maxWidth / 2.4).clamp(160.0, 440.0);
            // Konteyner chap-o'ngdan 16px margin bilan torayadi — kesh
            // o'lchami hisoblanganda shu haqiqiy kenglik ishlatiladi.
            final bannerWidth = constraints.maxWidth - 32;
            return SizedBox(
              height: bannerHeight,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.banners.length,
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  final isActivePage = index == _currentPage;

                  return GestureDetector(
                    onTap: () => _launchUrl(banner.linkUrl),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      // MUHIM: soya (boxShadow) va burchak kesish (clip)
                      // ATAYLAB ikki alohida qatlamga ajratilgan.
                      //
                      // Avval ikkalasi BITTA Container'da edi
                      // (clipBehavior + boxShadow bir joyda). Bu Flutter'da
                      // ma'lum muammo: debug rejimida to'g'ri chiqadi, lekin
                      // Impeller render dvigateli bilan KOMPILYATSIYA
                      // qilingan (App Store/TestFlight) build'da burchaklarda
                      // kichik uchburchak shaklidagi nuqsonlar paydo bo'ladi —
                      // aynan shu rasmlarda ko'ringan holat.
                      //
                      // Yechim: tashqi Container faqat soya chizadi (KESMAYDI),
                      // ichkarida esa alohida ClipRRect burchaklarni kesadi.
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: ColoredBox(
                          color: context.colors.primary,
                          child: banner.isVideo
                              ? _buildVideoOrPlaceholder(banner, isActivePage)
                              : BrandImageLoader(
                                  imageUrl: banner.imageUrl,
                                  // Konteyner nisbati suratning haqiqiy
                                  // nisbatiga (~2.4:1) mos kelgani uchun
                                  // "cover" endi deyarli hech narsani
                                  // kesmaydi va rangli chiziqlar
                                  // (letterbox) qoldirmaydi.
                                  fit: BoxFit.cover,
                                  // MUHIM — TUZATILDI: avval bu yerda
                                  // "width: double.infinity" va height
                                  // umuman berilmagan edi. BrandImageLoader
                                  // ichida esa kesh o'lchami (memCacheWidth/
                                  // Height) qattiq 400x400 (KVADRAT) qilib
                                  // yozilgan edi — bu banner kabi keng
                                  // (2.4:1) rasmlarni kvadratga siqib,
                                  // matn va grafikani qiyshaytirib
                                  // ko'rsatardi. Endi aniq, haqiqiy en/bo'y
                                  // beriladi, shunda kesh ham to'g'ri
                                  // nisbatda hisoblanadi.
                                  width: bannerWidth,
                                  height: bannerHeight,
                                  borderRadius: 0,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (widget.banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentPage == index ? 24.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? context.colors.primary
                      : context.colors.outline,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Video faqat HOZIR EKRANDA ko'rinib turgan sahifada ijro etiladi.
  ///
  /// PageView bir nechta sahifani oldindan tayyorlab qo'yishi mumkin
  /// (keyingi/oldingi banner uchun). Agar har biri o'zi video ijro
  /// eta boshlasa — foydalanuvchi ko'rmayotgan bir nechta video bir
  /// vaqtda internetdan yuklanib, ma'lumot va batareyani isrof qiladi.
  /// Faol bo'lmagan sahifada shunchaki fon rangi turadi, aylanib
  /// kelinganda video darhol ishga tushadi.
  Widget _buildVideoOrPlaceholder(BannerEntity banner, bool isActivePage) {
    if (!isActivePage) {
      return const ColoredBox(color: Colors.black12);
    }
    return VideoBannerPlayer(
      videoUrl: ImageUtils.getFullImageUrl(banner.videoUrl),
    );
  }
}
