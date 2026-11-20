import 'package:mlf_frontend/features/stock_summary/domain/entities/stock_summary_entity.dart';
import 'package:mlf_frontend/features/stock_summary/domain/repositories/stock_summary_repository.dart';

class GetStockSummaryUseCase {
  final StockSummaryRepository repository;

  GetStockSummaryUseCase(this.repository);

  Future<StockSummaryEntity> execute({
    String? godownId,
    String? groupId,
    String? search,
    String? fromDate,
    String? toDate,
    bool? showZeroStock,
  }) {
    return repository.getStockSummary(
      godownId: godownId,
      groupId: groupId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      showZeroStock: showZeroStock,
    );
  }

  Future<StockSummaryEntity> executeGroup({
    required String groupId,
    String? godownId,
    String? search,
    String? fromDate,
    String? toDate,
  }) {
    return repository.getGroupStockSummary(
      groupId: groupId,
      godownId: godownId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
