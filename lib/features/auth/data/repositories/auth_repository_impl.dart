import 'package:mlf_frontend/core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      if (user.token.isNotEmpty) {
        await localDataSource.saveToken(user.token);
      }

      return user;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await localDataSource.getToken();
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        token: token,
      );
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    await localDataSource.saveToken(token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuth();
  }
}
