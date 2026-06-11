import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Result returned by PaymentService.
class PaymentResult {
  const PaymentResult._({
    required this.success,
    this.checkoutUrl,
    this.errorMessage,
  });

  factory PaymentResult.success(String checkoutUrl) =>
      PaymentResult._(success: true, checkoutUrl: checkoutUrl);

  factory PaymentResult.failure(String message) =>
      PaymentResult._(success: false, errorMessage: message);

  final bool success;

  /// The Yoco hosted checkout URL — open this in YocoPaymentScreen.
  final String? checkoutUrl;
  final String? errorMessage;
}

class PaymentService {
  // ── Yoco ───────────────────────────────────────────────────────────────────

  /// Creates a Yoco checkout session and returns the checkout URL.
  /// Open the URL in YocoPaymentScreen — do NOT use url_launcher.
  Future<PaymentResult> createYocoCheckout({
    required String orderId,
    required double amount,
    required String customerEmail,
  }) async {
    final secretKey = dotenv.env['YOCO_SECRET_KEY'] ?? '';
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

    if (secretKey.isEmpty) {
      return PaymentResult.failure(
          'Yoco not configured. Add YOCO_SECRET_KEY to .env');
    }

    // Yoco requires amount in cents
    final amountInCents = (amount * 100).round();

    // These are the URLs Yoco redirects to after payment.
    // YocoPaymentScreen detects these redirects and pops with true/false.
    final successUrl = 'https://$projectId.web.app/payment-success.html';
    final cancelUrl  = 'https://$projectId.web.app/payment-cancel.html';

    try {
      final response = await http.post(
        Uri.parse('https://payments.yoco.com/api/checkouts'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount':     amountInCents,
          'currency':   'ZAR',
          'successUrl': successUrl,
          'cancelUrl':  cancelUrl,
          'metadata':   {
            'orderId':        orderId,
            'customerEmail':  customerEmail,
          },
        }),
      );

      debugPrint('Yoco response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return PaymentResult.failure(
            'Could not create Yoco payment. Please try again.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final redirectUrl = data['redirectUrl'] as String?;

      if (redirectUrl == null || redirectUrl.isEmpty) {
        return PaymentResult.failure(
            'Yoco did not return a checkout URL.');
      }

      return PaymentResult.success(redirectUrl);
    } catch (e) {
      debugPrint('Yoco error: $e');
      return PaymentResult.failure(
          'Could not reach Yoco. Check your internet connection.');
    }
  }

  // ── Cash on Delivery ───────────────────────────────────────────────────────

  /// No gateway needed — just confirm immediately.
  Future<PaymentResult> confirmCash() async {
    return PaymentResult.success('cash');
  }
}