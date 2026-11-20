import '../entities/purchase_entity.dart';

abstract class PurchaseRepository {
  Future<List<PurchaseEntity>> getPurchases({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? itemId,
    String? purchaseTypeId,
    String? godownId,
  });

  Future<PurchaseEntity> getPurchaseById(String id);

  Future<PurchaseEntity> createPurchase({
    required DateTime date,
    required String partyId,
    required String purchaseTypeId,
    String? godownId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
    // Optional legacy single-item parameters
    String? itemId,
    String? uomId,
    double? uomQuantity,
    double? actualQuantity,
    double? billedQuantity,
    double? rate,
    String? perId,
  });

  Future<PurchaseEntity> updatePurchase({
    required String id,
    DateTime? date,
    String? partyId,
    String? purchaseTypeId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
  });

  Future<void> deletePurchase(String id);
}
