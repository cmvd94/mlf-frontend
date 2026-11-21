import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/stock_transfer_model.dart';
import '../models/available_stock_model.dart';
import '../../domain/entities/stock_transfer_entity.dart';

abstract class StockTransferRemoteDataSource {
  Future<StockTransferListResultEntity> getStockTransfers({
    int page = 1,
    int limit = 20,
    String? search,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  });

  Future<StockTransferModel> getStockTransferById(String id, {String? token});

  Future<List<AvailableStockModel>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
    String? token,
  });

  Future<StockTransferModel> createStockTransfer(Map<String, dynamic> body, {String? token});

  Future<StockTransferModel> updateStockTransfer(String id, Map<String, dynamic> body, {String? token});

  Future<void> deleteStockTransfer(String id, {String? token});
}

class StockTransferRemoteDataSourceImpl implements StockTransferRemoteDataSource {
  final ApiClient apiClient;

  StockTransferRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StockTransferListResultEntity> getStockTransfers({
    int page = 1,
    int limit = 20,
    String? search,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
    };

    final response = await apiClient.get(
      ApiEndpoints.getStockTransferList,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final rawTransfers = (data['transfers'] as List?) ?? [];
    final transfers = rawTransfers
        .map((e) => StockTransferModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final totalCount = (data['totalCount'] as num?)?.toInt() ?? transfers.length;
    final totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
    final currentPage = (data['currentPage'] as num?)?.toInt() ?? page;

    return StockTransferListResultEntity(
      transfers: transfers,
      pagination: StockTransferPaginationEntity(
        currentPage: currentPage,
        totalPages: totalPages,
        totalCount: totalCount,
        limit: limit,
      ),
    );
  }

  @override
  Future<StockTransferModel> getStockTransferById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getStockTransferById(id),
      token: token,
    );
    return StockTransferModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<AvailableStockModel>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (itemId != null && itemId.isNotEmpty) 'itemId': itemId,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await apiClient.get(
      ApiEndpoints.availableStockForTransfer,
      queryParams: queryParams,
      token: token,
    );

    final rawList = (response['data'] as List?) ?? [];
    return rawList
        .map((e) => AvailableStockModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StockTransferModel> createStockTransfer(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(
      ApiEndpoints.createStockTransfer,
      body: body,
      token: token,
    );
    return StockTransferModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<StockTransferModel> updateStockTransfer(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(
      ApiEndpoints.updateStockTransfer(id),
      body: body,
      token: token,
    );
    return StockTransferModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteStockTransfer(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deleteStockTransfer(id),
      token: token,
    );
  }
}
