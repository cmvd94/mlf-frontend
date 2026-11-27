import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/error_utils.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../../stock_transfer/domain/entities/available_stock_entity.dart';

class SalesController extends ChangeNotifier {
  final SalesRepository repository;

  SalesController({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isLoadingAvailable = false;
  bool get isLoadingAvailable => _isLoadingAvailable;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<SaleEntity> _sales = [];
  List<SaleEntity> get sales => _sales;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  List<AvailableStockEntity> _availableStocks = [];
  List<AvailableStockEntity> get availableStocks => _availableStocks;

  SaleEntity? _selectedSale;
  SaleEntity? get selectedSale => _selectedSale;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  String? _selectedPartyId;
  String? get selectedPartyId => _selectedPartyId;

  String? _selectedGodownId;
  String? get selectedGodownId => _selectedGodownId;

  DateTime? _fromDate;
  DateTime? get fromDate => _fromDate;

  DateTime? _toDate;
  DateTime? get toDate => _toDate;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setSearchQuery(String? search) {
    _searchQuery = search;
    fetchSales(page: 1, reset: true);
  }

  void setPartyFilter(String? partyId) {
    _selectedPartyId = partyId;
    fetchSales(page: 1, reset: true);
  }

  void setGodownFilter(String? godownId) {
    _selectedGodownId = godownId;
    fetchSales(page: 1, reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    fetchSales(page: 1, reset: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedPartyId = null;
    _selectedGodownId = null;
    _fromDate = null;
    _toDate = null;
    fetchSales(page: 1, reset: true);
  }

  Future<void> fetchSales({int page = 1, bool reset = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fromStr = _fromDate?.toIso8601String().split('T').first;
      final toStr = _toDate?.toIso8601String().split('T').first;

      final result = await repository.getSales(
        page: page,
        limit: 20,
        search: _searchQuery,
        partyId: _selectedPartyId,
        godownId: _selectedGodownId,
        fromDate: fromStr,
        toDate: toStr,
      );

      _sales = result.sales;
      _totalCount = result.totalCount;
      _totalPages = result.totalPages;
      _currentPage = result.currentPage;

      AppLogger().i(
        'Fetched ${_sales.length} sales records (Page $page of $_totalPages)',
        tag: 'SalesCtrl',
      );
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching sales: $e', tag: 'SalesCtrl');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableStocks({String? godownId, String? itemId, String? search, String? saleId}) async {
    _isLoadingAvailable = true;
    notifyListeners();

    try {
      _availableStocks = await repository.getAvailableStocks(
        godownId: godownId,
        itemId: itemId,
        search: search,
        saleId: saleId,
      );
      AppLogger().i(
        'Fetched ${_availableStocks.length} available stocks for sales',
        tag: 'SalesCtrl',
      );
    } catch (e) {
      AppLogger().e('Error fetching available stocks: $e', tag: 'SalesCtrl');
    } finally {
      _isLoadingAvailable = false;
      notifyListeners();
    }
  }

  Future<SaleEntity?> fetchSaleById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sale = await repository.getSaleById(id);
      _selectedSale = sale;
      return sale;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching sale details: $e', tag: 'SalesCtrl');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSale(SaleCreateInput input) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createSale(input);
      _successMessage = 'Sale voucher ${created.salesNumber} created successfully!';
      AppLogger().i('Sale created: ${created.salesNumber}', tag: 'SalesCtrl');
      await fetchSales(page: 1, reset: true);
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error creating sale: $e', tag: 'SalesCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateSale(String id, SaleUpdateInput input) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updateSale(id, input);
      _successMessage = 'Sale voucher ${updated.salesNumber} updated successfully!';
      AppLogger().i('Sale updated: ${updated.salesNumber}', tag: 'SalesCtrl');
      await fetchSales(page: _currentPage, reset: true);
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error updating sale: $e', tag: 'SalesCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSale(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await repository.deleteSale(id);
      _successMessage = 'Sale voucher deleted and stock restored successfully!';
      AppLogger().i('Sale deleted: $id', tag: 'SalesCtrl');
      await fetchSales(page: _currentPage, reset: true);
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error deleting sale: $e', tag: 'SalesCtrl');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
