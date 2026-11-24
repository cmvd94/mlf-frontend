import 'package:mlf_frontend/features/stock_summary/domain/entities/stock_summary_entity.dart';

abstract class StockSummaryRepository {
  Future<StockSummaryEntity> getStockSummary({
    String? godownId,
    String? groupId,
    String? search,
    String? fromDate,
    String? toDate,
    bool? showZeroStock,
  });

  Future<StockSummaryEntity> getGroupStockSummary({
    required String groupId,
    String? godownId,
    String? search,
    String? fromDate,
    String? toDate,
  });
}
