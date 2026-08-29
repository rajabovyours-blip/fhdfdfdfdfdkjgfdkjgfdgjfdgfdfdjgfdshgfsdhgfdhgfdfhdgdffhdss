import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/shared/components/product_card.dart';

class FlashDealsSection extends StatefulWidget {
  final List<ProductEntity> products;

  const FlashDealsSection({super.key, required this.products});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  late DateTime targetTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Simulate a target time of 12h 34m 56s from initialization
    targetTime = DateTime.now().add(const Duration(hours: 12, minutes: 34, seconds: 56));
    
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      } else {
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    if (d.isNegative) d = Duration.zero;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFFFF3B30), size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.specialOffers,
                style: TextStyle(
                  color: context.colors.textHigh,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatDuration(targetTime.difference(DateTime.now())),
                  style: const TextStyle(
                    color: Color(0xFFFF3B30),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280, // Approximate height for the product card
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: widget.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return SizedBox(
                width: 160, // Fixed width for horizontal scrolling
                child: ProductCard(
                  product: product,
                  showCartAction: true,
                  onTap: () => context.push(
                    AppRoutes.productDetails.replaceAll(':id', product.id),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
