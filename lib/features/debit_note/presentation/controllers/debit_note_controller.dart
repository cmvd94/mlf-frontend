import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/error_utils.dart';
import '../../domain/entities/debit_note_entity.dart';
import '../../domain/repositories/debit_note_repository.dart';
import '../../../stock_transfer/domain/entities/available_stock_entity.dart';

class DebitNoteController extends ChangeNotifier {
  final DebitNoteRepository repository;

  DebitNoteController({required this.repository});

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

  List<DebitNoteEntity> _debitNotes = [];
  List<DebitNoteEntity> get debitNotes => _debitNotes;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  List<AvailableStockEntity> _availableStocks = [];
  List<AvailableStockEntity> get availableStocks => _availableStocks;

  DebitNoteEntity? _selectedDebitNote;
  DebitNoteEntity? get selectedDebitNote => _selectedDebitNote;

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
    fetchDebitNotes(page: 1, reset: true);
  }

  void setPartyFilter(String? partyId) {
    _selectedPartyId = partyId;
    fetchDebitNotes(page: 1, reset: true);
  }

  void setGodownFilter(String? godownId) {
    _selectedGodownId = godownId;
    fetchDebitNotes(page: 1, reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    fetchDebitNotes(page: 1, reset: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedPartyId = null;
    _selectedGodownId = null;
    _fromDate = null;
    _toDate = null;
    fetchDebitNotes(page: 1, reset: true);
  }

  Future<void> fetchDebitNotes({int page = 1, bool reset = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fromStr = _fromDate?.toIso8601String().split('T').first;
      final toStr = _toDate?.toIso8601String().split('T').first;

      final result = await repository.getDebitNotes(
        page: page,
        limit: 20,
        search: _searchQuery,
        partyId: _selectedPartyId,
        godownId: _selectedGodownId,
        fromDate: fromStr,
        toDate: toStr,
      );

      _debitNotes = result.debitNotes;
      _totalCount = result.totalCount;
      _totalPages = result.totalPages;
      _currentPage = result.currentPage;
      AppLogger().i('Fetched ${_debitNotes.length} debit notes successfully (Page $_currentPage of $_totalPages)', tag: 'DebitNoteCtrl');
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching debit notes: $e', tag: 'DebitNoteCtrl', stackTrace: stack);
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
      AppLogger().i('Fetched ${_availableStocks.length} available stocks for debit note', tag: 'DebitNoteCtrl');
    } catch (e, stack) {
      AppLogger().e('Error fetching available stocks for debit note: $e', tag: 'DebitNoteCtrl', stackTrace: stack);
    } finally {
      _isLoadingAvailable = false;
      notifyListeners();
    }
  }

  Future<DebitNoteEntity?> getDebitNoteDetails(String id) async {
    try {
      final doc = await repository.getDebitNoteById(id);
      _selectedDebitNote = doc;
      notifyListeners();
      return doc;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching debit note details: $e', tag: 'DebitNoteCtrl', stackTrace: stack);
      notifyListeners();
      return null;
    }
  }

  Future<bool> createDebitNote(DebitNoteCreateInput input) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createDebitNote(input);
      _successMessage = 'Debit note ${created.debitNoteNumber} created successfully';
      AppLogger().i('Created debit note: ${created.debitNoteNumber}', tag: 'DebitNoteCtrl');
      await fetchDebitNotes(page: 1, reset: true);
      return true;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error creating debit note: $e', tag: 'DebitNoteCtrl', stackTrace: stack);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateDebitNote(String id, DebitNoteUpdateInput input) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updateDebitNote(id, input);
      _successMessage = 'Debit note ${updated.debitNoteNumber} updated successfully';
      AppLogger().i('Updated debit note: ${updated.debitNoteNumber}', tag: 'DebitNoteCtrl');
      await fetchDebitNotes(page: _currentPage);
      return true;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error updating debit note: $e', tag: 'DebitNoteCtrl', stackTrace: stack);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDebitNote(String id) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await repository.deleteDebitNote(id);
      _successMessage = 'Debit note deleted successfully and stock reverted';
      AppLogger().i('Deleted debit note: $id', tag: 'DebitNoteCtrl');
      await fetchDebitNotes(page: _currentPage);
      return true;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error deleting debit note: $e', tag: 'DebitNoteCtrl', stackTrace: stack);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
