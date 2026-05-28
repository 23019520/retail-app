import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/models/business_model.dart';
import 'admin_products_provider.dart';
import 'dart:io';

class SettingsNotifier extends StateNotifier<AsyncValue<BusinessModel>> {
  SettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final _firestore = FirebaseFirestore.instance;

  String get _businessId =>
      dotenv.env['BUSINESS_ID'] ?? AppConstants.defaultBusinessId;

  DocumentReference<Map<String, dynamic>> get _settingsDoc => _firestore
      .collection(FirestoreConstants.businesses)
      .doc(_businessId);

  Future<void> _load() async {
    try {
      final snap = await _settingsDoc.get();
      if (!snap.exists || snap.data() == null) {
        state = AsyncValue.data(BusinessModel.empty.copyWith(id: _businessId));
        return;
      }
      state = AsyncValue.data(BusinessModel.fromJson(snap.data()!));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> save(BusinessModel model, {File? newLogoFile}) async {
    try {
      String? logoUrl = model.logoUrl;

      // Upload new logo if selected
      if (newLogoFile != null) {
        final storageService = _ref.read(adminStorageServiceProvider);
        logoUrl = await storageService.uploadFile(
          file: newLogoFile,
          path: 'businesses/$_businessId',
        );
      }

      final updated = model.copyWith(logoUrl: logoUrl, id: _businessId);
      await _settingsDoc.set(updated.toJson());
      state = AsyncValue.data(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> reload() => _load();
}

final adminSettingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<BusinessModel>>(
        (ref) => SettingsNotifier(ref));
