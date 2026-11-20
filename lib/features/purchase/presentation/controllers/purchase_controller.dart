import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/repositories/purchase_repository.dart';

class PurchaseController extends ChangeNotifier {
  final PurchaseRepository repository;

  PurchaseController({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<PurchaseEntity> _purchases = [];
  List<PurchaseEntity> get purchases => _purchases;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _purchases = await repository.getPurchases(search: _searchQuery);
      AppLogger().i('Loaded ${_purchases.length} purchases', tag: 'PurchaseCtrl');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger().e('Failed to load purchases: $e', tag: 'PurchaseCtrl');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Follows aiGuide.txt: Frontend validates received input is right,
  /// should not alter or calculate or modify values sent to backend.
  /// Sends the input values as is to backend.
  Future<bool> createPurchase({
    required DateTime date,
    required String partyId,
    required String purchaseTypeId,
    String? godownId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
    String? itemId,
    String? uomId,
    double? uomQuantity,
    double? actualQuantity,
    double? billedQuantity,
    double? rate,
    String? perId,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.createPurchase(
        date: date,
        partyId: partyId,
        purchaseTypeId: purchaseTypeId,
        godownId: godownId,
        items: items,
        isGstBill: isGstBill,
        gstPercentage: gstPercentage,
        notes: notes,
        itemId: itemId,
        uomId: uomId,
        uomQuantity: uomQuantity,
        actualQuantity: actualQuantity,
        billedQuantity: billedQuantity,
        rate: rate,
        perId: perId,
      );
      AppLogger().i('Purchase entry created successfully', tag: 'PurchaseCtrl');
      await fetchPurchases();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger().e('Failed to create purchase: $e', tag: 'PurchaseCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updatePurchase({
    required String id,
    DateTime? date,
    String? partyId,
    String? purchaseTypeId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updatePurchase(
        id: id,
        date: date,
        partyId: partyId,
        purchaseTypeId: purchaseTypeId,
        items: items,
        isGstBill: isGstBill,
        gstPercentage: gstPercentage,
        notes: notes,
      );
      AppLogger().i('Purchase entry updated successfully', tag: 'PurchaseCtrl');
      await fetchPurchases();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger().e('Failed to update purchase: $e', tag: 'PurchaseCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deletePurchase(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deletePurchase(id);
      AppLogger().i('Purchase entry deleted: $id', tag: 'PurchaseCtrl');
      await fetchPurchases();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger().e('Failed to delete purchase: $e', tag: 'PurchaseCtrl');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
