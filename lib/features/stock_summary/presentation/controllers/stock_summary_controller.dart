import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import '../../domain/entities/stock_summary_entity.dart';
import '../../domain/usecases/get_stock_summary_usecase.dart';

class StockSummaryController extends ChangeNotifier {
  final GetStockSummaryUseCase getStockSummaryUseCase;

  StockSummaryController({required this.getStockSummaryUseCase});

  StockSummaryEntity? _stockSummary;
  StockSummaryEntity? get stockSummary => _stockSummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // View state: Condensed (Image 1) vs Detailed (Image 2 & 3)
  bool _isDetailedView = false;
  bool get isDetailedView => _isDetailedView;

  // Single Group Drill-down (Image 3)
  StockSummaryGroupEntity? _selectedGroup;
  StockSummaryGroupEntity? get selectedGroup => _selectedGroup;
  bool get isSingleGroupMode => _selectedGroup != null;

  // Filters
  String? _selectedGodownId;
  String? get selectedGodownId => _selectedGodownId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  DateTime? _fromDate;
  DateTime? get fromDate => _fromDate;

  DateTime? _toDate;
  DateTime? get toDate => _toDate;

  bool _showZeroStock = false;
  bool get showZeroStock => _showZeroStock;

  Future<void> init() async {
    await fetchStockSummary();
  }

  void toggleDetailedView() {
    _isDetailedView = !_isDetailedView;
    AppLogger().i('Toggled detailed view: $_isDetailedView', tag: 'StockSummary');
    notifyListeners();
  }

  void drillDownGroup(StockSummaryGroupEntity group) {
    _selectedGroup = group;
    // In Tally, when drilling into a single group, Detailed view is active by default to show batches
    _isDetailedView = true;
    AppLogger().i('Drilled into group: ${group.groupName}', tag: 'StockSummary');
    notifyListeners();
  }

  void navigateBackToAllGroups() {
    _selectedGroup = null;
    AppLogger().i('Navigated back to All Groups Summary', tag: 'StockSummary');
    notifyListeners();
  }

  void setGodownFilter(String? godownId) {
    if (_selectedGodownId == godownId) return;
    _selectedGodownId = godownId;
    _selectedGroup = null;
    fetchStockSummary();
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchStockSummary();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _fromDate = start;
    _toDate = end;
    fetchStockSummary();
  }

  void toggleZeroStock() {
    _showZeroStock = !_showZeroStock;
    fetchStockSummary();
  }

  Future<void> fetchStockSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summary = await getStockSummaryUseCase.execute(
        godownId: _selectedGodownId,
        groupId: _selectedGroup?.groupId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        fromDate: _fromDate?.toIso8601String(),
        toDate: _toDate?.toIso8601String(),
        showZeroStock: _showZeroStock,
      );

      _stockSummary = summary;

      // Update selectedGroup instance if currently drilling down
      if (_selectedGroup != null) {
        StockSummaryGroupEntity? found;
        for (final g in summary.groups) {
          if (g.groupId == _selectedGroup!.groupId) {
            found = g;
            break;
          }
        }
        _selectedGroup = found;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger().e('Failed to load stock summary: $e', tag: 'StockSummary');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
