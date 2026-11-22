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

  PurchasePaginationEntity _pagination = const PurchasePaginationEntity();
  PurchasePaginationEntity get pagination => _pagination;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _limit = 20;
  int get limit => _limit;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchPurchases();
  }

  void setPage(int page) {
    if (page < 1 || (page > _pagination.totalPages && _pagination.totalPages > 0)) {
      return;
    }
    _currentPage = page;
    fetchPurchases();
  }

  void nextPage() {
    if (_pagination.hasNextPage) {
      setPage(_currentPage + 1);
    }
  }

  void previousPage() {
    if (_pagination.hasPreviousPage) {
      setPage(_currentPage - 1);
    }
  }

  void setLimit(int newLimit) {
    if (_limit == newLimit) return;
    _limit = newLimit;
    _currentPage = 1;
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getPurchases(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
      );
      _purchases = result.purchases;
      _pagination = result.pagination;
      _currentPage = result.pagination.currentPage;
      AppLogger().i(
        'Loaded ${_purchases.length} purchases (Page $_currentPage of ${_pagination.totalPages}, Total: ${_pagination.totalCount})',
        tag: 'PurchaseCtrl',
      );
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
    required String companyGodownId,
    String? godownId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
    String? itemId,
    String? dcNo,
    String? lotNo,
    String? batchNo,
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
        companyGodownId: companyGodownId,
        godownId: godownId,
        items: items,
        isGstBill: isGstBill,
        gstPercentage: gstPercentage,
        notes: notes,
        itemId: itemId,
        dcNo: dcNo,
        lotNo: lotNo,
        batchNo: batchNo,
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
    String? companyGodownId,
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
        companyGodownId: companyGodownId,
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
