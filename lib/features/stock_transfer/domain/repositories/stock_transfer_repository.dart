import '../entities/stock_transfer_entity.dart';
import '../entities/available_stock_entity.dart';

abstract class StockTransferRepository {
  Future<StockTransferListResultEntity> getStockTransfers({
    int page = 1,
    int limit = 20,
    String? search,
    String? godownId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<StockTransferEntity> getStockTransferById(String id);

  Future<List<AvailableStockEntity>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
  });

  Future<StockTransferEntity> createStockTransfer({
    required DateTime date,
    required List<CreateStockTransferSourceInput> sourceItems,
    required List<CreateStockTransferDestinationInput> destinationItems,
    String? narration,
  });
}
