import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/error_utils.dart';
import '../../domain/entities/credit_note_entity.dart';
import '../../domain/repositories/credit_note_repository.dart';

class CreditNoteController extends ChangeNotifier {
  final CreditNoteRepository repository;

  CreditNoteController({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<CreditNoteEntity> _creditNotes = [];
  List<CreditNoteEntity> get creditNotes => _creditNotes;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  CreditNoteEntity? _selectedCreditNote;
  CreditNoteEntity? get selectedCreditNote => _selectedCreditNote;

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
    fetchCreditNotes(page: 1, reset: true);
  }

  void setPartyFilter(String? partyId) {
    _selectedPartyId = partyId;
    fetchCreditNotes(page: 1, reset: true);
  }

  void setGodownFilter(String? godownId) {
    _selectedGodownId = godownId;
    fetchCreditNotes(page: 1, reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    fetchCreditNotes(page: 1, reset: true);
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedPartyId = null;
    _selectedGodownId = null;
    _fromDate = null;
    _toDate = null;
    fetchCreditNotes(page: 1, reset: true);
  }

  Future<void> fetchCreditNotes({int page = 1, bool reset = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fromStr = _fromDate?.toIso8601String().split('T').first;
      final toStr = _toDate?.toIso8601String().split('T').first;

      final result = await repository.getCreditNotes(
        page: page,
        limit: 20,
        search: _searchQuery,
        partyId: _selectedPartyId,
        godownId: _selectedGodownId,
        fromDate: fromStr,
        toDate: toStr,
      );

      _creditNotes = result.creditNotes;
      _totalCount = result.totalCount;
      _totalPages = result.totalPages;
      _currentPage = result.currentPage;
      AppLogger().i('Fetched ${_creditNotes.length} credit notes successfully (Page $_currentPage of $_totalPages)', tag: 'CreditNoteCtrl');
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching credit notes: $e', tag: 'CreditNoteCtrl', stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CreditNoteEntity?> getCreditNoteDetails(String id) async {
    try {
      final doc = await repository.getCreditNoteById(id);
      _selectedCreditNote = doc;
      notifyListeners();
      return doc;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error fetching credit note details: $e', tag: 'CreditNoteCtrl', stackTrace: stack);
      notifyListeners();
      return null;
    }
  }

  Future<bool> createCreditNote(CreditNoteCreateInput input) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await repository.createCreditNote(input);
      _successMessage = 'Credit note ${created.creditNoteNumber} created successfully';
      AppLogger().i('Created credit note: ${created.creditNoteNumber}', tag: 'CreditNoteCtrl');
      await fetchCreditNotes(page: 1, reset: true);
      return true;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error creating credit note: $e', tag: 'CreditNoteCtrl', stackTrace: stack);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCreditNote(String id, CreditNoteUpdateInput input) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await repository.updateCreditNote(id, input);
      _successMessage = 'Credit note ${updated.creditNoteNumber} updated successfully';
      AppLogger().i('Updated credit note: ${updated.creditNoteNumber}', tag: 'CreditNoteCtrl');
      await fetchCreditNotes(page: _currentPage);
      return true;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error updating credit note: $e', tag: 'CreditNoteCtrl', stackTrace: stack);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCreditNote(String id) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await repository.deleteCreditNote(id);
      _successMessage = 'Credit note deleted successfully and stock reverted';
      AppLogger().i('Deleted credit note: $id', tag: 'CreditNoteCtrl');
      await fetchCreditNotes(page: _currentPage);
      return true;
    } catch (e, stack) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Error deleting credit note: $e', tag: 'CreditNoteCtrl', stackTrace: stack);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
