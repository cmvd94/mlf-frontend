import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/admin_list_model.dart';
import '../models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminListModel> getAdminUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    String? search,
    String? token,
  });

  Future<AdminUserModel> getAdminUserById(String id, {String? token});

  Future<void> createAdminUser(Map<String, dynamic> body, {String? token});

  Future<void> updateAdminUser(String id, Map<String, dynamic> body, {String? token});

  Future<void> updateAdminUserIsActive({
    required String userId,
    required bool isActive,
    String? token,
  });

  Future<void> deleteAdminUser(String id, {String? token});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AdminListModel> getAdminUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    String? search,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (role != null && role.isNotEmpty) 'role': role,
      if (isActive != null) 'isActive': isActive,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await apiClient.get(
      ApiEndpoints.getAdminList,
      queryParams: queryParams,
      token: token,
    );

    return AdminListModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AdminUserModel> getAdminUserById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getAdminById(id),
      token: token,
    );

    final data = response is Map<String, dynamic> ? response['data'] ?? response : response;
    final userJson = data is Map<String, dynamic> && data['user'] != null
        ? data['user']
        : data;

    return AdminUserModel.fromJson(userJson as Map<String, dynamic>);
  }

  @override
  Future<void> createAdminUser(Map<String, dynamic> body, {String? token}) async {
    await apiClient.post(
      ApiEndpoints.createAdmin,
      body: body,
      token: token,
    );
  }

  @override
  Future<void> updateAdminUser(
    String id,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    await apiClient.patch(
      ApiEndpoints.updateAdmin(id),
      body: body,
      token: token,
    );
  }

  @override
  Future<void> updateAdminUserIsActive({
    required String userId,
    required bool isActive,
    String? token,
  }) async {
    await apiClient.patch(
      ApiEndpoints.updateIsActiveAdmin,
      body: {
        'userId': userId,
        'isActive': isActive,
      },
      token: token,
    );
  }

  @override
  Future<void> deleteAdminUser(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deleteAdmin(id),
      token: token,
    );
  }
}
