import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
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
        errorBuilder: (context, error, stackTrace) => _buildNeedsImageFallback(context),
      );
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildNeedsImageFallback(context),
    );
  }

  Widget _buildNeedsImageFallback(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }
}
