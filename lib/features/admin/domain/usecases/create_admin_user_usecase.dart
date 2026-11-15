import '../repositories/admin_repository.dart';

class CreateAdminUserUseCase {
  final AdminRepository repository;

  CreateAdminUserUseCase(this.repository);

  Future<void> execute({
    required String name,
    required String email,
    required String phoneNumber,
    String? password,
    required String role,
    required String employeeId,
    String? language,
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('Name is required');
    if (email.trim().isEmpty) throw ArgumentError('Email is required');
    if (phoneNumber.trim().length != 10) {
      throw ArgumentError('Phone number must be exactly 10 digits');
    }
    if (employeeId.trim().isEmpty) throw ArgumentError('Employee ID is required');

    return await repository.createAdminUser(
      name: name.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      password: password,
      role: role.trim(),
      employeeId: employeeId.trim(),
      language: language,
    );
  }
}
