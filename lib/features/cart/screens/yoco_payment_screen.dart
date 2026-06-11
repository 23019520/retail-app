import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens the Yoco checkout URL inside a WebView.
/// Detects the success/cancel redirect and pops with a result.
///
/// Usage:
/// ```dart
/// final paid = await Navigator.push<bool>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => YocoPaymentScreen(
///       checkoutUrl: url,
///       successUrl: 'https://yourproject.web.app/payment-success.html',
///       cancelUrl:  'https://yourproject.web.app/payment-cancel.html',
///     ),
///   ),
/// );
/// if (paid == true) { /* create order */ }
/// ```
class YocoPaymentScreen extends StatefulWidget {
  const YocoPaymentScreen({
    super.key,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  final String checkoutUrl;
  final String successUrl;
  final String cancelUrl;

  @override
  State<YocoPaymentScreen> createState() => _YocoPaymentScreenState();
}

class _YocoPaymentScreenState extends State<YocoPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url;

            // Payment succeeded
            if (url.startsWith(widget.successUrl)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }

            // Payment cancelled
            if (url.startsWith(widget.cancelUrl)) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        // SSL lock icon — reassures the user
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.lock_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}