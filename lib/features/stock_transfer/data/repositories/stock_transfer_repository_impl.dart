import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/stock_transfer_entity.dart';
import '../../domain/entities/available_stock_entity.dart';
import '../../domain/repositories/stock_transfer_repository.dart';
import '../datasources/stock_transfer_remote_data_source.dart';

class StockTransferRepositoryImpl implements StockTransferRepository {
  final StockTransferRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  StockTransferRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<StockTransferListResultEntity> getStockTransfers({
    int page = 1,
    int limit = 20,
    String? search,
    String? godownId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getStockTransfers(
      page: page,
      limit: limit,
      search: search,
      godownId: godownId,
      fromDate: fromDate?.toIso8601String(),
      toDate: toDate?.toIso8601String(),
      token: token,
    );
  }

  @override
  Future<StockTransferEntity> getStockTransferById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getStockTransferById(id, token: token);
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

  @override
  Future<StockTransferEntity> createStockTransfer({
    required DateTime date,
    required List<CreateStockTransferSourceInput> sourceItems,
    required List<CreateStockTransferDestinationInput> destinationItems,
    String? narration,
  }) async {
    final token = await _getToken();

    final body = {
      'date': '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}',
      'sourceItems': sourceItems.map((s) => s.toJson()).toList(),
      'destinationItems': destinationItems.map((d) => d.toJson()).toList(),
      if (narration != null && narration.isNotEmpty) 'narration': narration,
    };

    return await remoteDataSource.createStockTransfer(body, token: token);
  }
}
