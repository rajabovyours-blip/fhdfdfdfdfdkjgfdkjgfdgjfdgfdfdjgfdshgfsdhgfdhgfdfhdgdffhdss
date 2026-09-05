import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/payments/return')) {
              // Payment flow finished on the provider's side — close the webview
              // and let the checkout screen re-check the REAL order status from the backend
              // (never trust the URL alone as proof of payment).
              Navigator.of(context).pop(true); // true = "payment flow completed, please refresh"
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
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
          onPressed: () => context.pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
