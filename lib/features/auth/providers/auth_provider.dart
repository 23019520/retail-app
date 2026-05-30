import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';

// ── Service provider ─────────────────────────────────────────────────────────

/// Single instance of AuthService shared across the app.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Stream providers ──────────────────────────────────────────────────────────

/// Raw Firebase User stream. Null = signed out.
/// The router listens to this to trigger redirects.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// The current Firebase user (synchronous read).
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Fetches and caches the Firestore UserModel for the signed-in user.
/// Re-runs whenever the Firebase user changes.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseUser = ref.watch(currentFirebaseUserProvider);
  if (firebaseUser == null) return null;
  return ref.read(authServiceProvider).fetchUserModel(firebaseUser.uid);
});

/// True if the current user has the admin role.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return false;
  final token = await user.getIdTokenResult(true);
  return token.claims?['role'] == 'admin';
});

// ── Auth state for UI ─────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Auth notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState());

  final AuthService _authService;

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    final result = await _authService.signInWithEmail(
        email: email, password: password);
    if (result.isSuccess) {
      // Init notifications and save FCM token after successful sign-in
      final uid = result.user?.uid;
      if (uid != null) {
        final ns = NotificationService();
        await ns.init();
        await ns.saveToken(uid);
      }
      state = const AuthState();
      return true;
    }
    state = AuthState(errorMessage: result.errorMessage);
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _authService.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
    if (result.isSuccess) {
      // Save FCM token for new registrations too
      final uid = result.user?.uid;
      if (uid != null) {
        final ns = NotificationService();
        await ns.init();
        await ns.saveToken(uid);
      }
      state = const AuthState();
      return true;
    }
    state = AuthState(errorMessage: result.errorMessage);
    return false;
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    final result = await _authService.signInWithGoogle();
    if (result.isSuccess) {
      final uid = result.user?.uid;
      if (uid != null) {
        final ns = NotificationService();
        await ns.init();
        await ns.saveToken(uid);
      }
      state = const AuthState();
      return true;
    }
    state = AuthState(errorMessage: result.errorMessage);
    return false;
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = const AuthState();
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true);
    final result = await _authService.sendPasswordReset(email);
    state = const AuthState();
    if (!result.isSuccess) {
      state = AuthState(errorMessage: result.errorMessage);
      return false;
    }
    return true;
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});