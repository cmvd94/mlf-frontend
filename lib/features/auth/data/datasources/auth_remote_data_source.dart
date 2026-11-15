import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  });
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
}
