import '../../auth/data/datasources/auth_local_data_source.dart';
import '../domain/entities/admin_list_entity.dart';
import '../domain/entities/admin_user_entity.dart';
import '../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<AdminListEntity> getAdminUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    String? search,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getAdminUsers(
      page: page,
      limit: limit,
      role: role,
      isActive: isActive,
      search: search,
      token: token,
    );
  }

  @override
  Future<AdminUserEntity> getAdminUserById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getAdminUserById(id, token: token);
  }

  @override
  Future<void> createAdminUser({
    required String name,
    required String email,
    required String phoneNumber,
    String? password,
    required String role,
    required String employeeId,
    String? language,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'employeeId': employeeId,
      if (password != null && password.isNotEmpty) 'password': password,
      if (language != null) 'language': language,
    };
    await remoteDataSource.createAdminUser(body, token: token);
  }

  @override
  Future<void> updateAdminUser({
    required String id,
    String? name,
    String? email,
    String? role,
    String? employeeId,
    String? language,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (employeeId != null) 'employeeId': employeeId,
      if (language != null) 'language': language,
    };
    await remoteDataSource.updateAdminUser(id, body, token: token);
  }

  @override
  Future<void> updateAdminUserIsActive({
    required String id,
    required bool isActive,
  }) async {
    final token = await _getToken();
    await remoteDataSource.updateAdminUserIsActive(
      userId: id,
      isActive: isActive,
      token: token,
    );
  }

  @override
  Future<void> deleteAdminUser(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteAdminUser(id, token: token);
  }
}
