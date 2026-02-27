import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/auth/auth_state_changes.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
    required AuthStateChangesUseCase authStateChanges,
    required GetCurrentUserUseCase getCurrentUser,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _authStateChanges = authStateChanges,
        _getCurrentUser = getCurrentUser {
    _listenAuthChanges();
  }

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final AuthStateChangesUseCase _authStateChanges;
  final GetCurrentUserUseCase _getCurrentUser;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  UserProfile? _user;
  UserProfile? get user => _user;

  AppException? _error;
  AppException? get error => _error;

  StreamSubscription<Result<UserProfile?>>? _authSub;

  Future<void> _listenAuthChanges() async {
    _authSub?.cancel();
    _authSub = _authStateChanges().listen((result) {
      result.fold((value) {
        _user = value;
        _status = value == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
        _error = null;
        notifyListeners();
      }, (err) {
        _status = AuthStatus.error;
        _error = err;
        notifyListeners();
      });
    });
  }

  Future<void> loadCurrentUser() async {
    _status = AuthStatus.loading;
    notifyListeners();
    final result = await _getCurrentUser();
    result.fold((value) {
      _user = value;
      _status = value == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      _error = null;
    }, (err) {
      _status = AuthStatus.error;
      _error = err;
    });
    notifyListeners();
  }

  Future<Result<UserProfile>> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    notifyListeners();
    final result = await _signIn(SignInParams(email: email, password: password));
    result.fold((value) {
      _user = value;
      _status = AuthStatus.authenticated;
      _error = null;
    }, (err) {
      _status = AuthStatus.unauthenticated;
      _error = err;
    });
    notifyListeners();
    return result;
  }

  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();
    final result = await _signUp(SignUpParams(
      email: email,
      password: password,
      displayName: displayName,
    ));
    result.fold((value) {
      _user = value;
      _status = AuthStatus.authenticated;
      _error = null;
    }, (err) {
      _status = AuthStatus.unauthenticated;
      _error = err;
    });
    notifyListeners();
    return result;
  }

  Future<Result<void>> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();
    final result = await _signOut();
    result.fold((_) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
    }, (err) {
      _status = AuthStatus.error;
      _error = err;
    });
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
