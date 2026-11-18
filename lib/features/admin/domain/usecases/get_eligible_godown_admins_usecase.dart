import '../entities/godown_entity.dart';
import '../repositories/godown_repository.dart';

class GetEligibleGodownAdminsUseCase {
  final GodownRepository _repository;

  GetEligibleGodownAdminsUseCase(this._repository);

  Future<List<AssignedAdminEntity>> call({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
  }) {
    return _repository.getEligibleAdmins(
      search: search,
      role: role,
      country: country,
      zone: zone,
      state: state,
      district: district,
    );
  }
}
