import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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

class PaymentService {
  // ── PayFast ────────────────────────────────────────────────────────────────

  Future<PaymentResult> initiatePayFast({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String itemName,
  }) async {
    final merchantId   = dotenv.env['PAYFAST_MERCHANT_ID'] ?? '';
    final merchantKey  = dotenv.env['PAYFAST_MERCHANT_KEY'] ?? '';
    final passphrase   = dotenv.env['PAYFAST_PASSPHRASE'] ?? '';
    final isSandbox    = dotenv.env['PAYFAST_SANDBOX'] == 'true';
    final projectId    = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

    if (merchantId.isEmpty || merchantKey.isEmpty) {
      return PaymentResult.failure(
          'PayFast credentials not configured in .env');
    }

    final amountStr = amount.toStringAsFixed(2);
    final nameParts = customerName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName  = nameParts.length > 1 ? nameParts.last : '';

    // For sandbox: use a simple success page as return URL
    // For production: use your deep link retailapp://payment/success
    final returnUrl = isSandbox
        ? 'https://$projectId.web.app/payment-success.html'
        : 'retailapp://payment/success?orderId=$orderId';
    final cancelUrl = isSandbox
        ? 'https://$projectId.web.app/payment-cancel.html'
        : 'retailapp://payment/cancel?orderId=$orderId';
    final notifyUrl = projectId.isNotEmpty
        ? 'https://us-central1-$projectId.cloudfunctions.net/payfastNotify'
        : 'https://webhook.site/test'; // fallback for testing

    final params = <String, String>{
      'merchant_id':   merchantId,
      'merchant_key':  merchantKey,
      'return_url':    returnUrl,
      'cancel_url':    cancelUrl,
      'notify_url':    notifyUrl,
      'name_first':    firstName,
      'name_last':     lastName,
      'email_address': customerEmail,
      'm_payment_id':  orderId,
      'amount':        amountStr,
      'item_name':     itemName,
    };

    // Generate signature
    final signature = _generateSignature(params, passphrase);
    params['signature'] = signature;

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final baseUrl = isSandbox
        ? 'https://sandbox.payfast.co.za/eng/process'
        : 'https://www.payfast.co.za/eng/process';

    final uri = Uri.parse('$baseUrl?$queryString');

    debugPrint('PayFast URL: $uri');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PaymentResult.success(orderId);
      } else {
        return PaymentResult.failure('Could not open PayFast. Please check your internet connection.');
      }
    } catch (e) {
      return PaymentResult.failure('Payment error: $e');
    }
  }

  // ── Yoco ───────────────────────────────────────────────────────────────────

  Future<PaymentResult> initiateYoco({
    required String orderId,
    required double amount,
  }) async {
    final publicKey = dotenv.env['YOCO_PUBLIC_KEY'] ?? '';

    if (publicKey.isEmpty) {
      return PaymentResult.failure('Yoco not configured. Add YOCO_PUBLIC_KEY to .env');
    }

    final uri = Uri.parse(
        'https://checkout.yoco.com/?amount=${(amount * 100).round()}'
        '&currency=ZAR'
        '&publicKey=$publicKey'
        '&metadata={"orderId":"$orderId"}');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PaymentResult.success(orderId);
      }
      return PaymentResult.failure('Could not open Yoco checkout.');
    } catch (e) {
      return PaymentResult.failure('Yoco error: $e');
    }
  }

  // ── Cash ───────────────────────────────────────────────────────────────────

  Future<PaymentResult> confirmCashOnDelivery(String orderId) async {
    return PaymentResult.success(orderId);
  }

  // ── Signature ──────────────────────────────────────────────────────────────

  String _generateSignature(Map<String, String> params, String passphrase) {
    // Build the string in the order PayFast expects
    final paramString = params.entries
        .where((e) => e.key != 'signature')
        .map((e) =>
            '${e.key}=${Uri.encodeComponent(e.value).replaceAll('+', '%20')}')
        .join('&');

    final withPassphrase = passphrase.isNotEmpty
        ? '$paramString&passphrase=${Uri.encodeComponent(passphrase).replaceAll('+', '%20')}'
        : paramString;

    return md5.convert(utf8.encode(withPassphrase)).toString();
  }
}
