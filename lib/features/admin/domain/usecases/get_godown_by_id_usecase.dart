import '../entities/godown_entity.dart';
import '../repositories/godown_repository.dart';

class GetGodownByIdUseCase {
  final GodownRepository _repository;

  GetGodownByIdUseCase(this._repository);

  Future<GodownEntity> call(String id) {
    return _repository.getGodownById(id);
  }
}
