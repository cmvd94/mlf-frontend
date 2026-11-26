import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/error_utils.dart';
import '../../domain/entities/stock_transfer_entity.dart';
import '../../domain/entities/available_stock_entity.dart';
import '../../domain/repositories/stock_transfer_repository.dart';

class StockTransferController extends ChangeNotifier {
  final StockTransferRepository repository;

  StockTransferController({required this.repository});

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

  List<StockTransferEntity> _transfers = [];
  List<StockTransferEntity> get transfers => _transfers;

  StockTransferPaginationEntity _pagination = const StockTransferPaginationEntity();
  StockTransferPaginationEntity get pagination => _pagination;

  List<AvailableStockEntity> _availableStocks = [];
  List<AvailableStockEntity> get availableStocks => _availableStocks;

  StockTransferEntity? _selectedTransfer;
  StockTransferEntity? get selectedTransfer => _selectedTransfer;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

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

  void setGodownFilter(String? godownId) {
    _selectedGodownId = godownId;
    fetchStockTransfers(page: 1, reset: true);
  }

  void setSearchQuery(String? search) {
    _searchQuery = search;
    fetchStockTransfers(page: 1, reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    fetchStockTransfers(page: 1, reset: true);
  }

  Future<void> fetchStockTransfers({int page = 1, bool reset = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getStockTransfers(
        page: page,
        limit: 20,
        search: _searchQuery,
        godownId: _selectedGodownId,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      _transfers = result.transfers;
      _pagination = result.pagination;
      AppLogger().i(
        'Fetched ${_transfers.length} stock transfers (Page $page of ${_pagination.totalPages})',
        tag: 'StockTransferCtrl',
      );
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching stock transfers: $e', tag: 'StockTransferCtrl');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableStocks({String? godownId, String? itemId, String? search}) async {
    _isLoadingAvailable = true;
    notifyListeners();

    try {
      _availableStocks = await repository.getAvailableStocks(
        godownId: godownId,
        itemId: itemId,
        search: search,
      );
      AppLogger().i(
        'Fetched ${_availableStocks.length} available stock batch records',
        tag: 'StockTransferCtrl',
      );
    } catch (e) {
      AppLogger().e('Error fetching available stocks: $e', tag: 'StockTransferCtrl');
    } finally {
      _isLoadingAvailable = false;
      notifyListeners();
    }
  }

  Future<StockTransferEntity?> fetchTransferById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transfer = await repository.getStockTransferById(id);
      _selectedTransfer = transfer;
      return transfer;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching transfer details: $e', tag: 'StockTransferCtrl');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createStockTransfer({
    required DateTime date,
    required List<CreateStockTransferSourceInput> sourceItems,
    required List<CreateStockTransferDestinationInput> destinationItems,
    String? narration,
    bool isGst = false,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createStockTransfer(
        date: date,
        sourceItems: sourceItems,
        destinationItems: destinationItems,
        narration: narration,
        isGst: isGst,
      );

      _successMessage = 'Stock transfer ${created.transferNumber} created successfully!';
      AppLogger().i('Stock transfer created: ${created.transferNumber}', tag: 'StockTransferCtrl');
      await fetchStockTransfers(page: 1, reset: true);
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error creating stock transfer: $e', tag: 'StockTransferCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateStockTransfer({
    required String id,
    DateTime? date,
    List<CreateStockTransferSourceInput>? sourceItems,
    List<CreateStockTransferDestinationInput>? destinationItems,
    String? narration,
    bool? isGst,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updateStockTransfer(
        id: id,
        date: date,
        sourceItems: sourceItems,
        destinationItems: destinationItems,
        narration: narration,
        isGst: isGst,
      );

      _successMessage = 'Stock transfer ${updated.transferNumber} updated successfully!';
      AppLogger().i('Stock transfer updated: ${updated.transferNumber}', tag: 'StockTransferCtrl');
      await fetchStockTransfers(page: _pagination.currentPage, reset: true);
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error updating stock transfer: $e', tag: 'StockTransferCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStockTransfer(String id) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await repository.deleteStockTransfer(id);
      _successMessage = 'Stock transfer voucher deleted and stock restored successfully!';
      AppLogger().i('Stock transfer deleted: $id', tag: 'StockTransferCtrl');
      await fetchStockTransfers(page: 1, reset: true);
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error deleting stock transfer: $e', tag: 'StockTransferCtrl');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
