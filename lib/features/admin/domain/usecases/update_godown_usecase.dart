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
    bool clearGodownManager = false,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool clearBillingUser = false,
  }) {
    return _repository.updateGodown(
      id: id,
      name: name,
      godownId: godownId,
      type: type,
      description: description,
      isActive: isActive,
      godownManagerId: godownManagerId,
      clearGodownManager: clearGodownManager,
      supervisorId: supervisorId,
      assistantId: assistantId,
      billingUserId: billingUserId,
      clearBillingUser: clearBillingUser,
    );
  }
}
