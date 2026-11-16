import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<void> execute({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty) {
      throw ArgumentError('Current password is required');
    }
    if (newPassword.length < 6) {
      throw ArgumentError('New password must be at least 6 characters');
    }
    if (newPassword != confirmPassword) {
      throw ArgumentError('New password and confirm password do not match');
    }
    if (currentPassword == newPassword) {
      throw ArgumentError('New password must be different from current password');
    }

    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
