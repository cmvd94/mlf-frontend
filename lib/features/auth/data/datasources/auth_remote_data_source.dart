import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    String? token,
  });

  Future<void> logout({String? token});

  Future<void> logoutAll({String? token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      body: {
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    } else {
      throw FormatException('Unexpected response format: $response');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    String? token,
  }) async {
    await apiClient.patch(
      ApiEndpoints.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      token: token,
    );
  }

  @override
  Future<void> logout({String? token}) async {
    await apiClient.patch(
      ApiEndpoints.logout,
      token: token,
    );
  }

  @override
  Future<void> logoutAll({String? token}) async {
    await apiClient.delete(
      ApiEndpoints.logoutAll,
      token: token,
    );
  }
}
