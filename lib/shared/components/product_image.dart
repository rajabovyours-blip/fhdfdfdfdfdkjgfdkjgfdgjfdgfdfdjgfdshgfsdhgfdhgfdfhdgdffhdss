import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:milliy_metr/core/utils/image_utils.dart';

class ProductImage extends StatefulWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final String fallbackSeed;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.height = double.infinity,
    this.width = double.infinity,
    this.fallbackSeed = '',
    this.fit = BoxFit.cover,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  // Decoding size limit to prevent OOM
  static const int _cacheSize = 400;
  static const int _maxRetries = 2;

  int _retryCount = 0;
  bool _retryScheduled = false;

  @override
  void didUpdateWidget(covariant ProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retryCount = 0;
      _retryScheduled = false;
    }
  }

  void _scheduleRetry(String url) {
    if (_retryScheduled || _retryCount >= _maxRetries) return;
    _retryScheduled = true;
    // Avvalgi (xato bilan tugagan) yozuvni keshdan tozalaymiz — aks holda
    // Flutter xuddi shu URL uchun eski xatoni qayta ko'rsatib qo'yaveradi
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
    final imageUrl = widget.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'NEEDS_IMAGE') {
      return _buildErrorFallback(context);
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        cacheWidth: _cacheSize,
        errorBuilder: (context, error, stackTrace) => _buildErrorFallback(context),
      );
    }

    final String processedUrl = ImageUtils.getFullImageUrl(imageUrl);

    return CachedNetworkImage(
      // _retryCount o'zgarganda kalit ham o'zgaradi — bu Flutter'ga eski,
      // xato bilan tugagan urinishni emas, yangi, toza urinishni
      // ishlatishini majburlaydi
      key: ValueKey('$processedUrl#$_retryCount'),
      imageUrl: processedUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      memCacheWidth: _cacheSize,
      memCacheHeight: _cacheSize,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => _buildLoadingPlaceholder(context),
      errorWidget: (context, url, error) {
        if (_retryCount < _maxRetries) {
          _scheduleRetry(url);
          return _buildLoadingPlaceholder(context);
        }
        return _buildErrorFallback(context);
      },
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8E8E8);
    final highlightColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
    final logoColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/milliy_metr_logo_transparent.png',
            color: logoColor,
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
      ),
    );
  }
}
