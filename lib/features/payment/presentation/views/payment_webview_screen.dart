import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

/// To'lov sahifasini ILOVA ICHIDA ochadi.
///
/// Nima uchun tashqi brauzer emas:
///  - foydalanuvchi backend manzilini (va u orqali API'larni) ko'rmaydi
///  - to'lovdan keyin avtomatik ravishda ilovaga qaytadi
///  - to'lov holati URL orqali emas, backenddan tekshiriladi
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

class _PaymentWebviewScreenState extends ConsumerState<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/payments/return')) {
              // To'lov oqimi provayder tomonida tugadi. Oynani yopamiz va
              // haqiqiy holatni backenddan tekshiramiz — URL hech qachon
              // to'lov dalili emas.
              _close(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _close(bool completed) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop(completed);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close(false);
      },
      child: Scaffold(
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
            onPressed: () => _close(false),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
