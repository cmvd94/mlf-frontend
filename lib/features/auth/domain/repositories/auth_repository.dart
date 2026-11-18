import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> logout();
  Future<void> logoutAll();
}
