import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_data_source.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  PurchaseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<PurchaseListResultEntity> getPurchases({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? itemId,
    String? purchaseTypeId,
    String? godownId,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getPurchases(
      page: page,
      limit: limit,
      search: search,
      partyId: partyId,
      itemId: itemId,
      purchaseTypeId: purchaseTypeId,
      godownId: godownId,
      token: token,
    );
  }

  @override
  Future<PurchaseEntity> getPurchaseById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getPurchaseById(id, token: token);
  }

  @override
  Future<PurchaseEntity> createPurchase({
    required DateTime date,
    required String partyId,
    required String purchaseTypeId,
    String? godownId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
    String? itemId,
    String? batchNo,
    String? uomId,
    double? uomQuantity,
    double? actualQuantity,
    double? billedQuantity,
    double? rate,
    String? perId,
  }) async {
    final token = await _getToken();
    final List<Map<String, dynamic>> itemsPayload = [];
    if (items != null && items.isNotEmpty) {
      itemsPayload.addAll(items.map((i) => i.toJson()));
    } else if (itemId != null && uomId != null && perId != null) {
      itemsPayload.add({
        'itemId': itemId,
        'godownId': godownId ?? '',
        'batchNo': batchNo ?? '',
        'uomId': uomId,
        'uomQuantity': uomQuantity ?? actualQuantity ?? 1.0,
        'actualQuantity': actualQuantity ?? 0.0,
        'billedQuantity': billedQuantity ?? 0.0,
        'rate': rate ?? 0.0,
        'perId': perId,
      });
    }

    final body = PurchaseModel.toCreatePayload(
      date: date,
      partyId: partyId,
      purchaseTypeId: purchaseTypeId,
      godownId: godownId,
      items: itemsPayload,
      batchNo: batchNo,
      isGstBill: isGstBill,
      gstPercentage: gstPercentage,
      notes: notes,
    );
    return await remoteDataSource.createPurchase(body, token: token);
  }

  @override
  Future<PurchaseEntity> updatePurchase({
    required String id,
    DateTime? date,
    String? partyId,
    String? purchaseTypeId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
  }) async {
    final token = await _getToken();
    final List<Map<String, dynamic>>? itemsPayload =
        items?.map((i) => i.toJson()).toList();

    final body = PurchaseModel.toUpdatePayload(
      date: date,
      partyId: partyId,
      purchaseTypeId: purchaseTypeId,
      items: itemsPayload,
      isGstBill: isGstBill,
      gstPercentage: gstPercentage,
      notes: notes,
    );
    return await remoteDataSource.updatePurchase(id, body, token: token);
  }

  @override
  Future<void> deletePurchase(String id) async {
    final token = await _getToken();
    await remoteDataSource.deletePurchase(id, token: token);
  }
}
