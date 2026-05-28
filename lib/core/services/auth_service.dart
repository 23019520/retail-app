import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/firestore_constants.dart';
import '../models/user_model.dart';

/// All authentication operations.
/// Returns typed results — never throws raw Firebase exceptions to the UI.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // ── Streams ─────────────────────────────────────────────────────────────

  /// Raw Firebase user stream. Null = signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user (synchronous, may be null).
  User? get currentUser => _auth.currentUser;

  // ── Sign in ──────────────────────────────────────────────────────────────

  /// Sign in with email + password.
  /// Returns [AuthResult] — never throws.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Register new account, then create a Firestore user doc.
  Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Update display name in Firebase Auth
      await user.updateDisplayName(name.trim());

      // Create the Firestore user document
      await _createUserDoc(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
      );

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('Registration failed. Please try again.');
    }
  }

  /// Google Sign-In flow.
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker
        return AuthResult.failure('Sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Create Firestore doc only if first sign-in
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDoc(
          uid: user.uid,
          name: user.displayName ?? 'Customer',
          email: user.email ?? '',
        );
      }

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('Google sign-in failed. Please try again.');
    }
  }

  // ── Password reset ────────────────────────────────────────────────────────

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Firestore user doc ────────────────────────────────────────────────────

  Future<void> _createUserDoc({
    required String uid,
    required String name,
    required String email,
  }) async {
    final doc = _firestore.collection(FirestoreConstants.users).doc(uid);
    final userModel = UserModel(uid: uid, name: name, email: email);
    await doc.set(userModel.toJson());
  }

  /// Fetch the Firestore UserModel for the current user.
  Future<UserModel?> fetchUserModel(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  /// Converts cryptic Firebase error codes into readable messages.
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Typed result returned by every AuthService method.
/// UI checks .isSuccess and reads .errorMessage — no try/catch in widgets.
class AuthResult {
  const AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(User? user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final User? user;
  final String? errorMessage;
}
