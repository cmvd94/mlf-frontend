import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/sale_model.dart';
import '../../../stock_transfer/data/models/available_stock_model.dart';

abstract class SalesRemoteDataSource {
  Future<({List<SaleModel> sales, int totalCount, int totalPages, int currentPage})> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  });

  Future<SaleModel> getSaleById(String id, {String? token});

  Future<SaleModel> createSale(Map<String, dynamic> body, {String? token});

  Future<SaleModel> updateSale(String id, Map<String, dynamic> body, {String? token});

  Future<void> deleteSale(String id, {String? token});

  Future<List<AvailableStockModel>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
    String? saleId,
    String? token,
  });
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient apiClient;

  SalesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({List<SaleModel> sales, int totalCount, int totalPages, int currentPage})> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
    };

    final response = await apiClient.get(
      ApiEndpoints.getSaleList,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final salesList = (data['sales'] as List<dynamic>? ?? [])
        .map((e) => SaleModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final totalCount = (pagination['totalCount'] as num?)?.toInt() ?? salesList.length;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    final currentPage = (pagination['currentPage'] as num?)?.toInt() ?? page;

    return (
      sales: salesList,
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  Future<SaleModel> getSaleById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getSaleById(id),
      token: token,
    );
    return SaleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SaleModel> createSale(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(
      ApiEndpoints.createSale,
      body: body,
      token: token,
    );
    return SaleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SaleModel> updateSale(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(
      ApiEndpoints.updateSale(id),
      body: body,
      token: token,
    );
    return SaleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSale(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deleteSale(id),
      token: token,
    );
  }

  @override
  Future<List<AvailableStockModel>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
    String? saleId,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
      if (itemId != null && itemId.isNotEmpty) 'itemId': itemId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (saleId != null && saleId.isNotEmpty) 'saleId': saleId,
    };

    final response = await apiClient.get(
      ApiEndpoints.availableStockForSale,
      queryParams: queryParams,
      token: token,
    );

    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => AvailableStockModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
