import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhoneAndPasswordUseCase {
  final AuthRepository repository;

  LoginWithPhoneAndPasswordUseCase(this.repository);

  Future<UserEntity> execute({
    required String phoneNumber,
    required String password,
  }) async {
    // Domain validations
    if (phoneNumber.trim().isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    return await repository.loginWithPhoneAndPassword(
      phoneNumber: phoneNumber.trim(),
      password: password,
    );
  }
}
