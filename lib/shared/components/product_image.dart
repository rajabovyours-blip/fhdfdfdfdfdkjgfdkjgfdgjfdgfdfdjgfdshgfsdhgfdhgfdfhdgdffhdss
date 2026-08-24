import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

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

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: _cacheSize,
      memCacheHeight: _cacheSize,
      errorWidget: (context, url, error) => _buildNeedsImageFallback(context),
    );
  }

  Widget _buildNeedsImageFallback(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Image.asset(
            'assets/images/milliy_metr_logo_transparent.png',
            width: width * 0.5,
            height: height * 0.5,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
