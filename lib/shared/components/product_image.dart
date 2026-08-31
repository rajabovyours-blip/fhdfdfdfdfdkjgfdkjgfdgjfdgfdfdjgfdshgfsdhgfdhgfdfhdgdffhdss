import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:milliy_metr/core/utils/image_utils.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final String fallbackSeed;
  final BoxFit fit;
  
  // Decoding size limit to prevent OOM
  static const int _cacheSize = 400;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.height = double.infinity,
    this.width = double.infinity,
    this.fallbackSeed = '',
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty || imageUrl == 'NEEDS_IMAGE') {
      return _buildNeedsImageFallback(context);
    }

    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        height: height,
        width: width,
        fit: fit,
        cacheWidth: _cacheSize,
        errorBuilder: (context, error, stackTrace) => _buildNeedsImageFallback(context),
      );
    }

    final String processedUrl = ImageUtils.getFullImageUrl(imageUrl!);

    return CachedNetworkImage(
      imageUrl: processedUrl,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: _cacheSize,
      memCacheHeight: _cacheSize,
      errorWidget: (context, url, error) => _buildNeedsImageFallback(context),
    );
  }

  Widget _buildNeedsImageFallback(BuildContext context) {
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
}
