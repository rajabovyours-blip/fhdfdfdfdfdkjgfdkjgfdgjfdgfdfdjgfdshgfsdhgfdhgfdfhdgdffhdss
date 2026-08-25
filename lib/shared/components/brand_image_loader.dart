import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class BrandImageLoader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E222D) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF2D3342) : const Color(0xFFF9FAFB);

    Widget buildShimmerPlaceholder() {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                'assets/images/milliy_metr_logo.png',
                width: (width != null) ? (width! * 0.45).clamp(24.0, 56.0) : 42.0,
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

    if (imageUrl == null || imageUrl!.isEmpty) return buildShimmerPlaceholder();

    if (imageUrl!.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => buildShimmerPlaceholder(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => buildShimmerPlaceholder(),
        errorWidget: (_, __, ___) => buildShimmerPlaceholder(),
      ),
    );
  }
}
