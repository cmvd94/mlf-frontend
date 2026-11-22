import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/error_utils.dart';
import '../../domain/entities/godown_entity.dart';
import '../../domain/entities/godown_list_entity.dart';
import '../../domain/usecases/create_godown_usecase.dart';
import '../../domain/usecases/delete_godown_usecase.dart';
import '../../domain/usecases/get_eligible_godown_admins_usecase.dart';
import '../../domain/usecases/get_godown_by_id_usecase.dart';
import '../../domain/usecases/get_godowns_usecase.dart';
import '../../domain/usecases/update_godown_is_active_usecase.dart';
import '../../domain/usecases/update_godown_usecase.dart';

class GodownController extends ChangeNotifier {
  final GetGodownsUseCase getGodownsUseCase;
  final GetGodownByIdUseCase getGodownByIdUseCase;
  final CreateGodownUseCase createGodownUseCase;
  final UpdateGodownUseCase updateGodownUseCase;
  final UpdateGodownIsActiveUseCase updateGodownIsActiveUseCase;
  final DeleteGodownUseCase deleteGodownUseCase;
  final GetEligibleGodownAdminsUseCase getEligibleGodownAdminsUseCase;

  GodownController({
    required this.getGodownsUseCase,
    required this.getGodownByIdUseCase,
    required this.createGodownUseCase,
    required this.updateGodownUseCase,
    required this.updateGodownIsActiveUseCase,
    required this.deleteGodownUseCase,
    required this.getEligibleGodownAdminsUseCase,
  });

  List<GodownEntity> _godowns = [];
  GodownPaginationEntity _pagination = const GodownPaginationEntity(
    currentPage: 1,
    totalPages: 1,
    totalCount: 0,
    limit: 10,
  );
  GodownEntity? _selectedGodown;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Filters & Pagination
  int _currentPage = 1;
  final int _limit = 10;
  String? _searchQuery;
  GodownType? _typeFilter;
  bool? _isActiveFilter;

  // Getters
  List<GodownEntity> get godowns => _godowns;
  GodownPaginationEntity get pagination => _pagination;
  GodownEntity? get selectedGodown => _selectedGodown;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentPage => _currentPage;
  String? get searchQuery => _searchQuery;
  GodownType? get typeFilter => _typeFilter;
  bool? get isActiveFilter => _isActiveFilter;

  Future<void> fetchGodowns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getGodownsUseCase(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
        type: _typeFilter,
        isActive: _isActiveFilter,
      );

      _godowns = result.godowns;
      _pagination = result.pagination;
      AppLogger().i(
        'Fetched ${_godowns.length} godowns (Total: ${_pagination.totalCount})',
        tag: 'GodownController',
      );
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Failed to fetch godowns: $e', tag: 'GodownController');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String? query) {
    _searchQuery = (query != null && query.trim().isNotEmpty) ? query.trim() : null;
    _currentPage = 1;
    fetchGodowns();
  }

  void setTypeFilter(GodownType? type) {
    _typeFilter = type;
    _currentPage = 1;
    fetchGodowns();
  }

  void setIsActiveFilter(bool? isActive) {
    _isActiveFilter = isActive;
    _currentPage = 1;
    fetchGodowns();
  }

  void setPage(int page) {
    if (page < 1 || (page > _pagination.totalPages && _pagination.totalPages > 0)) {
      return;
    }
    _currentPage = page;
    fetchGodowns();
  }

  Future<GodownEntity?> getGodownDetails(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final godown = await getGodownByIdUseCase(id);
      _selectedGodown = godown;
      return godown;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Failed to fetch godown details: $e', tag: 'GodownController');
      return null;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGodown({
    required String name,
    String? godownId,
    required GodownType type,
    String? description,
    required String country,
    required String zone,
    required String state,
    required String district,
    required String pincode,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool isActive = true,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await createGodownUseCase(
        name: name,
        godownId: godownId,
        type: type,
        description: description,
        country: country,
        zone: zone,
        state: state,
        district: district,
        pincode: pincode,
        godownManagerId: godownManagerId,
        supervisorId: supervisorId,
        assistantId: assistantId,
        billingUserId: billingUserId,
        isActive: isActive,
      );

      _successMessage = 'Godown created successfully!';
      AppLogger().i('Godown created: $name', tag: 'GodownController');
      await fetchGodowns();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Failed to create godown: $e', tag: 'GodownController');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGodown({
    required String id,
    String? name,
    String? godownId,
    GodownType? type,
    String? description,
    bool? isActive,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await updateGodownUseCase(
        id: id,
        name: name,
        godownId: godownId,
        type: type,
        description: description,
        isActive: isActive,
        godownManagerId: godownManagerId,
        supervisorId: supervisorId,
        assistantId: assistantId,
        billingUserId: billingUserId,
      );

      _successMessage = 'Godown updated successfully!';
      AppLogger().i('Godown updated: $id', tag: 'GodownController');
      await fetchGodowns();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Failed to update godown: $e', tag: 'GodownController');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleGodownStatus(String id, bool newStatus) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateGodownIsActiveUseCase(
        godownIds: [id],
        isActive: newStatus,
      );

      _successMessage = 'Godown status updated!';
      // Optimistically update local list
      _godowns = _godowns.map((g) {
        if (g.id == id) {
          return g.copyWith(isActive: newStatus);
        }
        return g;
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Failed to toggle godown status: $e', tag: 'GodownController');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGodown(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await deleteGodownUseCase(id);
      _successMessage = 'Godown deleted successfully!';
      AppLogger().i('Godown deleted: $id', tag: 'GodownController');
      await fetchGodowns();
      return true;
    } catch (e) {
      _errorMessage = cleanErrorMessage(e);
      AppLogger().e('Failed to delete godown: $e', tag: 'GodownController');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<List<AssignedAdminEntity>> fetchEligibleAdmins({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
  }) async {
    try {
      return await getEligibleGodownAdminsUseCase(
        search: search,
        role: role,
        country: country,
        zone: zone,
        state: state,
        district: district,
      );
    } catch (e) {
      AppLogger().e('Failed to fetch eligible admins: $e', tag: 'GodownController');
      return [];
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
