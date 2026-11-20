import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/purchase_model.dart';

abstract class PurchaseRemoteDataSource {
  Future<List<PurchaseModel>> getPurchases({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? itemId,
    String? purchaseTypeId,
    String? godownId,
    String? token,
  });

  Future<PurchaseModel> getPurchaseById(String id, {String? token});

  Future<PurchaseModel> createPurchase(Map<String, dynamic> body, {String? token});

  Future<PurchaseModel> updatePurchase(String id, Map<String, dynamic> body, {String? token});

  Future<void> deletePurchase(String id, {String? token});
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final ApiClient apiClient;

  PurchaseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PurchaseModel>> getPurchases({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? itemId,
    String? purchaseTypeId,
    String? godownId,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (partyId != null && partyId.isNotEmpty) 'partyId': partyId,
      if (itemId != null && itemId.isNotEmpty) 'itemId': itemId,
      if (purchaseTypeId != null && purchaseTypeId.isNotEmpty) 'purchaseTypeId': purchaseTypeId,
      if (godownId != null && godownId.isNotEmpty) 'godownId': godownId,
    };

    final response = await apiClient.get(
      ApiEndpoints.getPurchaseList,
      queryParams: queryParams,
      token: token,
    );

    final list = response['data']?['purchases'] as List? ?? [];
    return list.map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PurchaseModel> getPurchaseById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getPurchaseById(id),
      token: token,
    );
    return PurchaseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PurchaseModel> createPurchase(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(
      ApiEndpoints.createPurchase,
      body: body,
      token: token,
    );
    return PurchaseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PurchaseModel> updatePurchase(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(
      ApiEndpoints.updatePurchase(id),
      body: body,
      token: token,
    );
    return PurchaseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePurchase(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deletePurchase(id),
      token: token,
    );
  }
}
