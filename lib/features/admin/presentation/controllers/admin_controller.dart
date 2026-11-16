import 'package:flutter/foundation.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_list_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_user_entity.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/create_admin_user_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_admin_user_details_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_admin_users_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_admin_is_active_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_admin_user_usecase.dart';

class AdminController extends ChangeNotifier {
  final GetAdminUsersUseCase getAdminUsersUseCase;
  final GetAdminUserDetailsUseCase getAdminUserDetailsUseCase;
  final CreateAdminUserUseCase createAdminUserUseCase;
  final UpdateAdminUserUseCase updateAdminUserUseCase;
  final UpdateAdminIsActiveUseCase updateAdminIsActiveUseCase;
  final DeleteAdminUserUseCase deleteAdminUserUseCase;

  AdminController({
    required this.getAdminUsersUseCase,
    required this.getAdminUserDetailsUseCase,
    required this.createAdminUserUseCase,
    required this.updateAdminUserUseCase,
    required this.updateAdminIsActiveUseCase,
    required this.deleteAdminUserUseCase,
  });

  AdminListEntity _adminList = AdminListEntity.empty();
  AdminUserEntity? _selectedUser;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Filters & Pagination
  int _currentPage = 1;
  final int _limit = 10;
  String? _searchQuery;
  String? _roleFilter;
  bool? _isActiveFilter;

  // Getters
  AdminListEntity get adminList => _adminList;
  AdminUserEntity? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentPage => _currentPage;
  int get limit => _limit;
  String? get searchQuery => _searchQuery;
  String? get roleFilter => _roleFilter;
  bool? get isActiveFilter => _isActiveFilter;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> fetchUsers({int? page}) async {
    if (page != null) {
      _currentPage = page;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    AppLogger().i(
      'Fetching admin users (page: $_currentPage, limit: $_limit, role: $_roleFilter, isActive: $_isActiveFilter, search: $_searchQuery)',
      tag: 'AdminCtrl',
    );

    try {
      _adminList = await getAdminUsersUseCase.execute(
        page: _currentPage,
        limit: _limit,
        role: _roleFilter,
        isActive: _isActiveFilter,
        search: _searchQuery,
      );
      AppLogger().i(
        'Fetched ${_adminList.users.length} users successfully (total items: ${_adminList.totalItems}, total pages: ${_adminList.totalPages})',
        tag: 'AdminCtrl',
      );
    } catch (e, st) {
      AppLogger().e('Failed to fetch admin users: $e', tag: 'AdminCtrl', error: e, stackTrace: st);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    _currentPage = 1;
    fetchUsers();
  }

  void setRoleFilter(String? role) {
    _roleFilter = role;
    _currentPage = 1;
    fetchUsers();
  }

  void setIsActiveFilter(bool? isActive) {
    _isActiveFilter = isActive;
    _currentPage = 1;
    fetchUsers();
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String phoneNumber,
    String? password,
    required String role,
    String? employeeId,
    String? language,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await createAdminUserUseCase.execute(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
        employeeId: employeeId,
        language: language,
      );
      _successMessage = 'Admin user created successfully';
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String id,
    String? name,
    String? email,
    String? role,
    String? employeeId,
    String? language,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await updateAdminUserUseCase.execute(
        id: id,
        name: name,
        email: email,
        role: role,
        employeeId: employeeId,
        language: language,
      );
      _successMessage = 'Admin user updated successfully';
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleUserStatus(String id, bool newStatus) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      await updateAdminIsActiveUseCase.execute(
        id: id,
        isActive: newStatus,
      );
      _successMessage = 'User status updated successfully';
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await deleteAdminUserUseCase.execute(id);
      _successMessage = 'Admin user deleted successfully';
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserDetails(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedUser = await getAdminUserDetailsUseCase.execute(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
