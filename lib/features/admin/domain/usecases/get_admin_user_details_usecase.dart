import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminUserDetailsUseCase {
  final AdminRepository repository;

  GetAdminUserDetailsUseCase(this.repository);

  Future<AdminUserEntity> execute(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Admin ID cannot be empty');
    }
    return await repository.getAdminUserById(id.trim());
  }
}
