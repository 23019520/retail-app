import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constants/firestore_constants.dart';

/// Handles FCM push notification setup and token management.
/// Order status notifications are triggered server-side via
/// Firebase Functions when an admin updates an order status.
class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  // ── Initialise ────────────────────────────────────────────────────────────

  /// Call this once from main.dart after Firebase.initializeApp().
  Future<void> init() async {
    // Request permission (required on iOS, shows dialog)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
        'Notification permission: ${settings.authorizationStatus}');

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Handle notification that launched the app from terminated state
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessageOpened(initial);
  }

  // ── Token management ──────────────────────────────────────────────────────

  /// Save the device FCM token to the user's Firestore document.
  /// Call this after the user signs in.
  Future<void> saveToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .update({'fcmToken': token});

      // Refresh token when it rotates
      _messaging.onTokenRefresh.listen((newToken) {
        _firestore
            .collection(FirestoreConstants.users)
            .doc(userId)
            .update({'fcmToken': newToken});
      });
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  /// Remove the token when the user signs out.
  Future<void> removeToken(String userId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Failed to remove FCM token: $e');
    }
  }

  // ── Message handlers ──────────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    // In Sprint 8 — show an in-app notification banner here
    // For now just log it
    debugPrint(
        'Foreground message: ${message.notification?.title}');
  }

  void _handleMessageOpened(RemoteMessage message) {
    // In Sprint 8 — navigate to the relevant order screen
    // using the orderId from message.data['orderId']
    debugPrint('Opened from notification: ${message.data}');
  }
}
