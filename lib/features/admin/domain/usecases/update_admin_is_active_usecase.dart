import '../repositories/admin_repository.dart';

class UpdateAdminIsActiveUseCase {
  final AdminRepository repository;

  UpdateAdminIsActiveUseCase(this.repository);

  Future<void> execute({
    required String id,
    required bool isActive,
  }) async {
    if (id.trim().isEmpty) throw ArgumentError('Admin ID is required');

    return await repository.updateAdminUserIsActive(
      id: id.trim(),
      isActive: isActive,
    );
  }
}
