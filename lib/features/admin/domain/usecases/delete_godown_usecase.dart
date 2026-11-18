import '../repositories/godown_repository.dart';

class DeleteGodownUseCase {
  final GodownRepository _repository;

  DeleteGodownUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteGodown(id);
  }
}
