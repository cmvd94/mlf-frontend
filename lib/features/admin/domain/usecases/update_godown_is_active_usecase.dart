import '../repositories/godown_repository.dart';

class UpdateGodownIsActiveUseCase {
  final GodownRepository _repository;

  UpdateGodownIsActiveUseCase(this._repository);

  Future<void> call({
    required List<String> godownIds,
    required bool isActive,
  }) {
    return _repository.updateGodownIsActive(
      godownIds: godownIds,
      isActive: isActive,
    );
  }
}
