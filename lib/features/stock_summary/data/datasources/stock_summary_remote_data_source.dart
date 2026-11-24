import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/stock_summary_model.dart';

abstract class StockSummaryRemoteDataSource {
  Future<StockSummaryModel> getStockSummary({
    String? godownId,
    String? groupId,
    String? search,
    String? fromDate,
    String? toDate,
    bool? showZeroStock,
    String? token,
  });

  Future<StockSummaryModel> getGroupStockSummary({
    required String groupId,
    String? godownId,
    String? search,
    String? fromDate,
    String? toDate,
    String? token,
  });
}

class StockSummaryRemoteDataSourceImpl implements StockSummaryRemoteDataSource {
  final ApiClient apiClient;

  StockSummaryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StockSummaryModel> getStockSummary({
    String? godownId,
    String? groupId,
    String? search,
    String? fromDate,
    String? toDate,
    bool? showZeroStock,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (groupId != null && groupId.isNotEmpty) 'groupId': groupId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
      if (showZeroStock != null) 'showZeroStock': showZeroStock.toString(),
    };

    final response = await apiClient.get(
      ApiEndpoints.stockSummary,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>;
    return StockSummaryModel.fromJson(data);
  }

  @override
  Future<StockSummaryModel> getGroupStockSummary({
    required String groupId,
    String? godownId,
    String? search,
    String? fromDate,
    String? toDate,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
    };

    final response = await apiClient.get(
      ApiEndpoints.groupStockSummary(groupId),
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>;
    return StockSummaryModel.fromJson(data);
  }
}
