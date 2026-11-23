import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../../../stock_transfer/domain/entities/available_stock_entity.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  SalesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<({List<SaleEntity> sales, int totalCount, int totalPages, int currentPage})> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getSales(
      page: page,
      limit: limit,
      search: search,
      partyId: partyId,
      godownId: godownId,
      fromDate: fromDate,
      toDate: toDate,
      token: token,
    );
  }

  @override
  Future<SaleEntity> getSaleById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getSaleById(id, token: token);
  }

  @override
  Future<SaleEntity> createSale(SaleCreateInput input) async {
    final token = await _getToken();
    return await remoteDataSource.createSale(input.toJson(), token: token);
  }

  @override
  Future<SaleEntity> updateSale(String id, SaleUpdateInput input) async {
    final token = await _getToken();
    return await remoteDataSource.updateSale(id, input.toJson(), token: token);
  }

  @override
  Future<void> deleteSale(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteSale(id, token: token);
  }

  @override
  Future<List<AvailableStockEntity>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getAvailableStocks(
      godownId: godownId,
      itemId: itemId,
      search: search,
      token: token,
    );
  }
}
