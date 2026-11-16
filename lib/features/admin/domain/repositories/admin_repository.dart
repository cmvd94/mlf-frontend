import '../entities/admin_list_entity.dart';
import '../entities/admin_user_entity.dart';

abstract class AdminRepository {
  Future<AdminListEntity> getAdminUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    String? search,
  });

  Future<AdminUserEntity> getAdminUserById(String id);

  Future<void> createAdminUser({
    required String name,
    required String email,
    required String phoneNumber,
    String? password,
    required String role,
    String? employeeId,
    String? language,
  });

  Future<void> updateAdminUser({
    required String id,
    String? name,
    String? email,
    String? role,
    String? employeeId,
    String? language,
  });

  Future<void> updateAdminUserIsActive({
    required String id,
    required bool isActive,
  });

  Future<void> deleteAdminUser(String id);
}
