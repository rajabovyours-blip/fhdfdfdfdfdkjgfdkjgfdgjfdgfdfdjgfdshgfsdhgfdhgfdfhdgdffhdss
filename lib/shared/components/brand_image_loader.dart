import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:milliy_metr/core/utils/image_utils.dart';
import 'package:milliy_metr/shared/components/web_image_strategy.dart';

class BrandImageLoader extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const BrandImageLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  State<BrandImageLoader> createState() => _BrandImageLoaderState();
}

class _BrandImageLoaderState extends State<BrandImageLoader> {
  // Ba'zi sahifalarga qaytib kelinganda (masalan Home'ga orqaga qaytish)
  // cached_network_image bir marta xato bergan URL uchun eski xatoni
  // takror ko'rsatib qo'yaveradi — yangidan urinib ko'rmaydi. Shu sababli
  // rasm doimiy "buzilgan" holatda qolib, faqat sahifani to'liq yangilash
  // (F5) tuzatardi. Bu yerda ProductImage'dagi kabi: xatodan keyin eski
  // yozuvni keshdan tozalab, avtomatik qayta urinamiz.
  static const int _maxRetries = 2;
  int _retryCount = 0;
  bool _retryScheduled = false;

  @override
  void didUpdateWidget(covariant BrandImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retryCount = 0;
      _retryScheduled = false;
    }
  }

  void _scheduleRetry(String url) {
    if (_retryScheduled || _retryCount >= _maxRetries) return;
    _retryScheduled = true;
    CachedNetworkImage.evictFromCache(url);
    Future.delayed(Duration(milliseconds: 500 * (_retryCount + 1)), () {
      if (!mounted) return;
      setState(() {
        _retryCount++;
        _retryScheduled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E222D) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF2D3342) : const Color(0xFFF9FAFB);

    Widget buildShimmerPlaceholder() {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Center(
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                'assets/images/milliy_metr_logo_transparent.png',
                width: (widget.width != null) ? (widget.width! * 0.45).clamp(24.0, 56.0) : 40.0,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.construction_rounded,
                  color: Color(0xFFFF7A00),
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final processedUrl = ImageUtils.getFullImageUrl(widget.imageUrl);

    if (processedUrl.isEmpty) return buildShimmerPlaceholder();

    if (processedUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.asset(
          processedUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, __, ___) => buildShimmerPlaceholder(),
        ),
      );
    }

    Widget buildErrorPlaceholder() {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
        ),
      );
    }

    if (kIsWeb && webImgMode != 'cached') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.network(
          processedUrl,
          key: ValueKey('$processedUrl#$_retryCount'),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          webHtmlElementStrategy: webImgMode == 'html'
              ? WebHtmlElementStrategy.prefer
              : WebHtmlElementStrategy.never,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return buildShimmerPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            if (_retryCount < _maxRetries) {
              _scheduleRetry(processedUrl);
              return buildShimmerPlaceholder();
            }
            return buildErrorPlaceholder();
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: CachedNetworkImage(
        // _retryCount o'zgarganda kalit ham o'zgaradi — bu Flutter'ga eski,
        // xato bilan tugagan urinishni emas, yangi, toza urinishni
        // ishlatishini majburlaydi.
        key: ValueKey('$processedUrl#$_retryCount'),
        imageUrl: processedUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        memCacheWidth: 400,
        memCacheHeight: 400,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => buildShimmerPlaceholder(),
        errorWidget: (context, url, error) {
          if (_retryCount < _maxRetries) {
            _scheduleRetry(url);
            return buildShimmerPlaceholder();
          }
          return buildErrorPlaceholder();
        },
      ),
    );
  }
}
