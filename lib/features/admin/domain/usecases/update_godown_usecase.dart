import '../entities/godown_entity.dart';
import '../repositories/godown_repository.dart';

class UpdateGodownUseCase {
  final GodownRepository _repository;

  UpdateGodownUseCase(this._repository);

  Future<void> call({
    required String id,
    String? name,
    String? godownId,
    GodownType? type,
    String? description,
    bool? isActive,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
  }) {
    return _repository.updateGodown(
      id: id,
      name: name,
      godownId: godownId,
      type: type,
      description: description,
      isActive: isActive,
      godownManagerId: godownManagerId,
      supervisorId: supervisorId,
      assistantId: assistantId,
      billingUserId: billingUserId,
    );
  }
}
