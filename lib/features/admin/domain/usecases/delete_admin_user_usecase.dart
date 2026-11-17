import '../repositories/admin_repository.dart';

class DeleteAdminUserUseCase {
  final AdminRepository repository;

  DeleteAdminUserUseCase(this.repository);

  Future<void> execute(String id) async {
    if (id.trim().isEmpty) throw ArgumentError('Admin ID is required');

    return await repository.deleteAdminUser(id.trim());
  }
}
