import '../repositories/admin_repository.dart';

class GetAdminStaticDataUseCase {
  final AdminRepository repository;

  GetAdminStaticDataUseCase(this.repository);

  Future<Map<String, dynamic>> execute() async {
    return await repository.getStaticData();
  }
}
