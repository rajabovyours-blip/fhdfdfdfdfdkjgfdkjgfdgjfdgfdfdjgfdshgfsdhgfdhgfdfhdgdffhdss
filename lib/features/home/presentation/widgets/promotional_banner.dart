import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:milliy_metr/shared/components/brand_image_loader.dart';

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
            // tepa/pastda) rangli bo'sh joy qolmaydi.
            final bannerHeight =
                (constraints.maxWidth / 2.4).clamp(160.0, 340.0);
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
                  return GestureDetector(
                    onTap: () => _launchUrl(banner.linkUrl),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // BrandImageLoader — xatodan keyin avtomatik qayta
                      // urinadi (keshni tozalab), aks holda Home'ga
                      // qaytilganda banner "buzilgan rasm" holatida
                      // qotib qolardi (faqat sahifani yangilash tuzatardi).
                      child: BrandImageLoader(
                        imageUrl: banner.imageUrl,
                        // Konteyner nisbati suratning haqiqiy nisbatiga
                        // (~2.4:1) mos kelgani uchun "cover" endi deyarli
                        // hech narsani kesmaydi va rangli chiziqlar
                        // (letterbox) qoldirmaydi.
                        fit: BoxFit.cover,
                        width: double.infinity,
                        borderRadius: 0,
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
}
