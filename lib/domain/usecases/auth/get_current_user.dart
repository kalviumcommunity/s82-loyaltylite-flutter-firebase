import '../../../core/utils/result.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<UserProfile?>> call() {
    return _repository.getCurrentUser();
  }
}
