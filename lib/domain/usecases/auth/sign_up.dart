import '../../../core/utils/result.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}

class SignUpUseCase {
  SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<UserProfile>> call(SignUpParams params) {
    return _repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
