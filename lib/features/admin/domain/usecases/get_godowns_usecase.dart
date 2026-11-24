import '../entities/godown_entity.dart';
import '../entities/godown_list_entity.dart';
import '../repositories/godown_repository.dart';

class GetGodownsUseCase {
  final GodownRepository _repository;

  GetGodownsUseCase(this._repository);

  Future<GodownListEntity> call({
    int page = 1,
    int limit = 10,
    String? search,
    GodownType? type,
    bool? isActive,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
  }) {
    return _repository.getGodowns(
      page: page,
      limit: limit,
      search: search,
      type: type,
      isActive: isActive,
      country: country,
      zone: zone,
      state: state,
      district: district,
      pincode: pincode,
    );
  }
}
