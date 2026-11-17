import '../entities/admin_list_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminUsersUseCase {
  final AdminRepository repository;

  GetAdminUsersUseCase(this.repository);

  Future<AdminListEntity> execute({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    String? search,
  }) async {
    return await repository.getAdminUsers(
      page: page,
      limit: limit,
      role: role,
      isActive: isActive,
      search: search,
    );
  }
}
