import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

/// Payment result returned after a gateway interaction.
class PaymentResult {
  const PaymentResult._({
    required this.success,
    this.paymentId,
    this.errorMessage,
  });

  factory PaymentResult.success(String paymentId) =>
      PaymentResult._(success: true, paymentId: paymentId);

  factory PaymentResult.failure(String message) =>
      PaymentResult._(success: false, errorMessage: message);

  final bool success;
  final String? paymentId;
  final String? errorMessage;
}

/// Supported payment gateways.
enum PaymentGateway { payfast, yoco, cash }

/// PaymentService builds the correct payment URL and launches it.
/// Sprint 8 (post-MVP) should replace the URL launcher approach with
/// a dedicated WebView or SDK integration for a native in-app feel.
class PaymentService {
  // ── PayFast ────────────────────────────────────────────────────────────────

  /// Builds a PayFast payment URL and opens it in the browser.
  /// PayFast redirects back to the app via a deep link on completion.
  Future<PaymentResult> initiatePayFast({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String itemName,
  }) async {
    final merchantId =
        dotenv.env['PAYFAST_MERCHANT_ID'] ?? '';
    final merchantKey =
        dotenv.env['PAYFAST_MERCHANT_KEY'] ?? '';
    final passphrase =
        dotenv.env['PAYFAST_PASSPHRASE'] ?? '';

    if (merchantId.isEmpty || merchantKey.isEmpty) {
      return PaymentResult.failure(
          'PayFast is not configured. Please add credentials to .env');
    }

    // PayFast requires amount as string with 2 decimal places
    final amountStr = amount.toStringAsFixed(2);

    final params = {
      'merchant_id': merchantId,
      'merchant_key': merchantKey,
      'return_url':
          'retailapp://payment/success?orderId=$orderId',
      'cancel_url':
          'retailapp://payment/cancel?orderId=$orderId',
      'notify_url':
          'https://us-central1-${dotenv.env['FIREBASE_PROJECT_ID'] ?? ''}.cloudfunctions.net/payfastNotify',
      'name_first': customerName.split(' ').first,
      'name_last': customerName.split(' ').length > 1
          ? customerName.split(' ').last
          : '',
      'email_address': customerEmail,
      'm_payment_id': orderId,
      'amount': amountStr,
      'item_name': itemName,
    };

    // Generate PayFast signature
    final signature = _generatePayFastSignature(params, passphrase);
    params['signature'] = signature;

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    // Use sandbox URL during development, live URL for production
    final isSandbox =
        dotenv.env['PAYFAST_SANDBOX'] == 'true';
    final baseUrl = isSandbox
        ? 'https://sandbox.payfast.co.za/eng/process'
        : 'https://www.payfast.co.za/eng/process';

    final uri = Uri.parse('$baseUrl?$queryString');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Payment result is confirmed via the PayFast notify URL
        // hitting our Firebase Function, which updates the order status.
        return PaymentResult.success(orderId);
      } else {
        return PaymentResult.failure(
            'Could not open payment gateway.');
      }
    } catch (e) {
      return PaymentResult.failure(
          'Payment failed. Please try again.');
    }
  }

  // ── Yoco ───────────────────────────────────────────────────────────────────

  /// Yoco uses a JavaScript SDK in a WebView.
  /// For MVP: launches Yoco's web checkout in the browser.
  Future<PaymentResult> initiateYoco({
    required String orderId,
    required double amount,
  }) async {
    final publicKey = dotenv.env['YOCO_PUBLIC_KEY'] ?? '';

    if (publicKey.isEmpty) {
      return PaymentResult.failure(
          'Yoco is not configured. Please add YOCO_PUBLIC_KEY to .env');
    }

    // Yoco inline checkout — MVP uses a hosted payment page
    // Full SDK integration is a Sprint 8 enhancement
    final uri = Uri.parse(
        'https://checkout.yoco.com/?amount=${(amount * 100).round()}'
        '&currency=ZAR'
        '&publicKey=$publicKey'
        '&metadata={"orderId":"$orderId"}');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PaymentResult.success(orderId);
      } else {
        return PaymentResult.failure(
            'Could not open Yoco checkout.');
      }
    } catch (e) {
      return PaymentResult.failure(
          'Payment failed. Please try again.');
    }
  }

  // ── Cash on Delivery ───────────────────────────────────────────────────────

  /// Cash on delivery requires no gateway — just confirm the order.
  Future<PaymentResult> confirmCashOnDelivery(String orderId) async {
    return PaymentResult.success(orderId);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _generatePayFastSignature(
      Map<String, String> params, String passphrase) {
    final paramString = params.entries
        .where((e) => e.key != 'signature')
        .map((e) =>
            '${e.key}=${Uri.encodeComponent(e.value).replaceAll('+', '%20')}')
        .join('&');

    final withPassphrase = passphrase.isNotEmpty
        ? '$paramString&passphrase=${Uri.encodeComponent(passphrase)}'
        : paramString;

    return md5.convert(utf8.encode(withPassphrase)).toString();
  }
}
