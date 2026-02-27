import '../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Stream<Result<UserProfile?>> authStateChanges();

  Future<Result<UserProfile?>> getCurrentUser();
}
