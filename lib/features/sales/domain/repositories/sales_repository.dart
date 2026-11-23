import '../entities/sale_entity.dart';
import '../../../stock_transfer/domain/entities/available_stock_entity.dart';

abstract class SalesRepository {
  Future<({List<SaleEntity> sales, int totalCount, int totalPages, int currentPage})> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  });

  Future<SaleEntity> getSaleById(String id);

  Future<SaleEntity> createSale(SaleCreateInput input);

  Future<SaleEntity> updateSale(String id, SaleUpdateInput input);

  Future<void> deleteSale(String id);

  Future<List<AvailableStockEntity>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
  });
}
