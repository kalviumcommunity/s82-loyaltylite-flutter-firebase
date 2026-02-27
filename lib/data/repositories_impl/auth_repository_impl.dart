import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exceptions/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._authService,
    this._firestoreService,
  );

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  @override
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      final user = credential.user;
      if (user == null) {
        return Failure(AuthFailure('Sign up failed: no user returned'));
      }
      await _firestoreService.createUserProfile(
        user: user,
        displayName: displayName,
      );
      final profile = await _firestoreService.fetchUserProfile(user.uid);
      return Success<UserProfile>(profile);
    } on FirebaseAuthException catch (e, st) {
      return Failure(AuthFailure(_mapFirebaseAuthError(e), cause: e, stackTrace: st));
    } on FirebaseException catch (e, st) {
      return Failure(FirestoreFailure(_mapFirestoreError(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure(AuthFailure('Unknown sign up error', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Failure(AuthFailure('Sign in failed: no user returned'));
      }
      final profile = await _firestoreService.fetchUserProfile(user.uid);
      return Success<UserProfile>(profile);
    } on FirebaseAuthException catch (e, st) {
      return Failure(AuthFailure(_mapFirebaseAuthError(e), cause: e, stackTrace: st));
    } on FirebaseException catch (e, st) {
      return Failure(FirestoreFailure(_mapFirestoreError(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure(AuthFailure('Unknown sign in error', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return const Success(null);
    } catch (e, st) {
      return Failure(AuthFailure('Sign out failed', cause: e, stackTrace: st));
    }
  }

  @override
  Stream<Result<UserProfile?>> authStateChanges() {
    return _authService.authStateChanges().asyncMap((user) async {
      if (user == null) return const Success<UserProfile?>(null);
      try {
        final profile = await _firestoreService.fetchUserProfile(user.uid);
        return Success<UserProfile?>(profile);
      } on FirebaseException catch (e, st) {
        return Failure<UserProfile?>(FirestoreFailure(e.message ?? 'Firestore error', cause: e, stackTrace: st));
      } catch (e, st) {
        return Failure<UserProfile?>(AuthFailure('Auth state failed', cause: e, stackTrace: st));
      }
    });
  }

  @override
  Future<Result<UserProfile?>> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return const Success<UserProfile?>(null);
    try {
      final profile = await _firestoreService.fetchUserProfile(user.uid);
      return Success<UserProfile?>(profile);
    } on FirebaseException catch (e, st) {
      return Failure<UserProfile?>(FirestoreFailure(_mapFirestoreError(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure<UserProfile?>(AuthFailure('Failed to get current user', cause: e, stackTrace: st));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied when accessing your data.';
      case 'unavailable':
        return 'Service unavailable. Please try again shortly.';
      case 'failed-precondition':
        return 'Firestore precondition failed.';
      default:
        return e.message ?? 'Firestore error.';
    }
  }
}
