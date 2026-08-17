import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';

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

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        SizedBox(
          height: 160,
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
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner.title.get(languageCode),
                              style: TextStyle(
                                color: context.colors.textHigh,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner.subtitle.get(languageCode),
                              style: TextStyle(
                                color: context.colors.textHigh.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8,),
                              decoration: BoxDecoration(
                                color: context.colors.textHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                banner.cta.get(languageCode),
                                style: TextStyle(
                                  color: context.colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(20),),
                        child: Container(
                          color: context.colors.textHigh.withValues(alpha: 0.1),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  banner.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.image,
                                    size: 60,
                                    color: context.colors.textHigh
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
