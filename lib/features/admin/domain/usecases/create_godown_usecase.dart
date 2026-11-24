import '../entities/godown_entity.dart';
import '../repositories/godown_repository.dart';

class CreateGodownUseCase {
  final GodownRepository _repository;

  CreateGodownUseCase(this._repository);

  Future<String> call({
    required String name,
    String? godownId,
    required GodownType type,
    String? description,
    required String country,
    required String zone,
    required String state,
    required String district,
    required String pincode,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool isActive = true,
  }) {
    return _repository.createGodown(
      name: name,
      godownId: godownId,
      type: type,
      description: description,
      country: country,
      zone: zone,
      state: state,
      district: district,
      pincode: pincode,
      godownManagerId: godownManagerId,
      supervisorId: supervisorId,
      assistantId: assistantId,
      billingUserId: billingUserId,
      isActive: isActive,
    );
  }
}
