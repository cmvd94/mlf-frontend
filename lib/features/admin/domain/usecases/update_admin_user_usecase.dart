import '../entities/access_scope_entity.dart';
import '../repositories/admin_repository.dart';

class UpdateAdminUserUseCase {
  final AdminRepository repository;

  UpdateAdminUserUseCase(this.repository);

  Future<void> execute({
    required String id,
    String? name,
    String? email,
    String? role,
    AccessScopeEntity? accessScope,
    String? employeeId,
    String? language,
  }) async {
    if (id.trim().isEmpty) throw ArgumentError('Admin ID is required');

    return await repository.updateAdminUser(
      id: id.trim(),
      name: name?.trim(),
      email: email?.trim(),
      role: role?.trim(),
      accessScope: accessScope,
      employeeId: employeeId?.trim(),
      language: language,
    );
  }
}
