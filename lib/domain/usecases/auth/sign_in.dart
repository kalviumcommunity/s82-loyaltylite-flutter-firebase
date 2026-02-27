import '../../../core/utils/result.dart';
import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class SignInParams {
  const SignInParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInUseCase {
  SignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<UserProfile>> call(SignInParams params) {
    return _repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
