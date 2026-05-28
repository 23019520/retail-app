import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  ProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _load() async {
    final user = _ref.read(currentFirebaseUserProvider);
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final model =
          await _ref.read(authServiceProvider).fetchUserModel(user.uid);
      state = AsyncValue.data(model);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      name: name ?? current.name,
      phone: phone ?? current.phone,
    );

    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(current.uid)
          .update({
        if (name != null) FirestoreConstants.name: name,
        if (phone != null) FirestoreConstants.phone: phone,
      });
      state = AsyncValue.data(updated);
    } catch (e) {
      // Revert on failure — state stays as current
    }
  }

  Future<void> reload() => _load();
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserModel?>>(
        (ref) => ProfileNotifier(ref));
