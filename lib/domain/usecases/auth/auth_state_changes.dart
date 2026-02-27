import '../../../core/utils/result.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class AuthStateChangesUseCase {
  AuthStateChangesUseCase(this._repository);
  final AuthRepository _repository;

  Stream<Result<UserProfile?>> call() {
    return _repository.authStateChanges();
  }
}
