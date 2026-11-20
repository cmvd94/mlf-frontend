import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/stock_summary_entity.dart';
import '../../domain/repositories/stock_summary_repository.dart';
import '../datasources/stock_summary_remote_data_source.dart';

class StockSummaryRepositoryImpl implements StockSummaryRepository {
  final StockSummaryRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  StockSummaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<StockSummaryEntity> getStockSummary({
    String? godownId,
    String? groupId,
    String? search,
    String? fromDate,
    String? toDate,
    bool? showZeroStock,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getStockSummary(
      godownId: godownId,
      groupId: groupId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      showZeroStock: showZeroStock,
      token: token,
    );
  }

  @override
  Future<StockSummaryEntity> getGroupStockSummary({
    required String groupId,
    String? godownId,
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getGroupStockSummary(
      groupId: groupId,
      godownId: godownId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      token: token,
    );
  }
}
