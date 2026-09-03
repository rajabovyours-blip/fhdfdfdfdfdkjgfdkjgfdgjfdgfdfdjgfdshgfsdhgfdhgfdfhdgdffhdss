import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';

class PaymentWebviewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  ConsumerState<PaymentWebviewScreen> createState() =>
      _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends ConsumerState<PaymentWebviewScreen>
    with WidgetsBindingObserver {
  bool _launched = false;
  bool _checking = false;
  String _statusMessage = '';
  int _checkCount = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchPaymentUrl();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns from browser, check payment status
    if (state == AppLifecycleState.resumed && _launched) {
      _startPolling();
    }
  }

  Future<void> _launchPaymentUrl() async {
    final uri = Uri.parse(widget.paymentUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _launched = true);
    } catch (e) {
      setState(() {
        _statusMessage = "To'lov sahifasini ochib bo'lmadi";
      });
    }
  }

  void _startPolling() {
    if (_checking) return;
    setState(() {
      _checking = true;
      _checkCount = 0;
      _statusMessage = "To'lov tasdiqlanmoqda...";
    });

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _checkCount++;
      if (_checkCount > 5) {
        timer.cancel();
        setState(() {
          _checking = false;
          _statusMessage =
              "To'lov hali tasdiqlanmadi. Iltimos, qayta tekshiring.";
        });
        return;
      }

      try {
        // Refresh the order from backend
        await ref
            .read(checkoutProvider.notifier)
            .refreshOrderStatus(widget.orderId);
        final state = ref.read(checkoutProvider);
        final order = state.order;

        if (order != null &&
            order.paymentStatus.toLowerCase() == 'paid') {
          timer.cancel();
          if (!mounted) return;
          context.go(AppRoutes.orderSuccess);
          return;
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text(
          "To'lov",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _checking
                  ? Icons.hourglass_top_rounded
                  : Icons.open_in_browser_rounded,
              size: 80,
              color: _checking
                  ? context.colors.warning
                  : context.colors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _checking
                  ? "To'lov tasdiqlanmoqda..."
                  : "To'lov sahifasi brauzerda ochildi",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage.isEmpty
                  ? "Brauzerda to'lovni amalga oshiring va bu yerga qayting."
                  : _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 14,
              ),
            ),
            if (_checking) ...[
              const SizedBox(height: 24),
              CircularProgressIndicator(color: context.colors.primary),
            ],
            const SizedBox(height: 32),
            AppButton(
              text: 'Qayta ochish',
              isSecondary: true,
              onPressed: _launchPaymentUrl,
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Tekshirish',
              onPressed: _startPolling,
            ),
          ],
        ),
      ),
    );
  }
}
