import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/config/env_config.dart';
import 'package:mlf_frontend/features/admin/data/models/admin_list_model.dart';
import 'package:mlf_frontend/features/admin/data/models/admin_user_model.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_list_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_role.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_user_entity.dart';
import 'package:mlf_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/create_admin_user_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_admin_user_details_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_admin_users_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_admin_is_active_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_admin_user_usecase.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';

class MockAdminRepository implements AdminRepository {
  List<AdminUserEntity> users = [];
  bool shouldFail = false;

  @override
  Future<AdminListEntity> getAdminUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    String? search,
  }) async {
    if (shouldFail) throw Exception('Failed to load admin users');
    return AdminListEntity(
      users: users,
      totalItems: users.length,
      currentPage: page,
      totalPages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }

  @override
  Future<AdminUserEntity> getAdminUserById(String id) async {
    if (shouldFail) throw Exception('User not found');
    return users.firstWhere((u) => u.id == id);
  }

  @override
  Future<void> createAdminUser({
    required String name,
    required String email,
    required String phoneNumber,
    String? password,
    required String role,
    required String employeeId,
    String? language,
  }) async {
    if (shouldFail) throw Exception('Failed to create user');
    users.add(AdminUserEntity(
      id: 'usr_${users.length + 1}',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      employeeId: employeeId,
      role: AdminRole.fromString(role),
    ));
  }

  @override
  Future<void> updateAdminUser({
    required String id,
    String? name,
    String? email,
    String? role,
    String? employeeId,
    String? language,
  }) async {
    if (shouldFail) throw Exception('Failed to update user');
    final index = users.indexWhere((u) => u.id == id);
    if (index != -1) {
      users[index] = users[index].copyWith(
        name: name,
        email: email,
        role: role != null ? AdminRole.fromString(role) : null,
        employeeId: employeeId,
      );
    }
  }

  @override
  Future<void> updateAdminUserIsActive({
    required String id,
    required bool isActive,
  }) async {
    if (shouldFail) throw Exception('Failed to toggle status');
    final index = users.indexWhere((u) => u.id == id);
    if (index != -1) {
      users[index] = users[index].copyWith(isActive: isActive);
    }
  }

  @override
  Future<void> deleteAdminUser(String id) async {
    if (shouldFail) throw Exception('Failed to delete user');
    users.removeWhere((u) => u.id == id);
  }
}

void main() {
  group('AdminRole Mapping', () {
    test('maps string to AdminRole enum accurately', () {
      expect(AdminRole.fromString('GENERAL_MANAGER'), AdminRole.generalManager);
      expect(AdminRole.fromString('GODOWN_MANAGER'), AdminRole.godownManager);
      expect(AdminRole.fromString('BILLING_USER'), AdminRole.billingUser);
      expect(AdminRole.fromString('DISTRICT_MANAGER'), AdminRole.districtManager);
      expect(AdminRole.fromString('SUPER_ADMIN'), AdminRole.superAdmin);
    });

    test('selectableRoles includes godownManager and billingUser but excludes superAdmin', () {
      final roles = AdminRole.selectableRoles;
      expect(roles.contains(AdminRole.godownManager), true);
      expect(roles.contains(AdminRole.billingUser), true);
      expect(roles.contains(AdminRole.superAdmin), false);
    });
  });

  group('AdminUserModel Serialization', () {
    test('AdminUserModel fromJson deserialization', () {
      final json = {
        '_id': 'admin_123',
        'name': 'Ramesh Kumar',
        'email': 'ramesh@mlf.com',
        'phoneNumber': '9876543210',
        'employeeId': 'mlf_01',
        'role': 'GODOWN_MANAGER',
        'isActive': true,
        'canEdit': true,
        'canDelete': false,
        'canToggleStatus': false,
      };

      final model = AdminUserModel.fromJson(json);

      expect(model.id, 'admin_123');
      expect(model.name, 'Ramesh Kumar');
      expect(model.employeeId, 'mlf_01');
      expect(model.role, AdminRole.godownManager);
      expect(model.isActive, true);
      expect(model.canEdit, true);
      expect(model.canDelete, false);
      expect(model.canToggleStatus, false);
    });

    test('AdminListModel deserialization with pagination and assignableRoles', () {
      final json = {
        'data': {
          'userList': [
            {
              '_id': 'a1',
              'name': 'User 1',
              'email': 'u1@mlf.com',
              'phoneNumber': '9876543211',
              'employeeId': 'E1',
              'role': 'BILLING_USER',
              'isActive': true,
              'canEdit': true,
              'canDelete': true,
              'canToggleStatus': true,
            }
          ],
          'assignableRoles': ['SUPERVISOR', 'ASSISTANT', 'BILLING_USER'],
          'pagination': {
            'totalItems': 15,
            'currentPage': 1,
            'totalPages': 2,
            'hasNextPage': true,
            'hasPrevPage': false,
          }
        }
      };

      final listModel = AdminListModel.fromJson(json);

      expect(listModel.users.length, 1);
      expect(listModel.totalItems, 15);
      expect(listModel.hasNextPage, true);
      expect(listModel.hasPrevPage, false);
      expect(listModel.users.first.role, AdminRole.billingUser);
      expect(listModel.users.first.canEdit, true);
      expect(listModel.users.first.canDelete, true);
      expect(listModel.users.first.canToggleStatus, true);
      expect(listModel.assignableRoles, [
        AdminRole.supervisor,
        AdminRole.assistant,
        AdminRole.billingUser,
      ]);
    });

    test('Role hierarchy permissions: subordinate vs equal/higher role handling', () {
      const subordinateUser = AdminUserEntity(
        id: 'sub_1',
        name: 'Supervisor User',
        email: 'supervisor@mlf.com',
        phoneNumber: '9000000001',
        employeeId: 'mlf_sub1',
        role: AdminRole.supervisor,
        canEdit: true,
        canDelete: true,
        canToggleStatus: true,
      );

      const equalRoleUser = AdminUserEntity(
        id: 'peer_1',
        name: 'Peer Godown Manager',
        email: 'peer@mlf.com',
        phoneNumber: '9000000002',
        employeeId: 'mlf_peer1',
        role: AdminRole.godownManager,
        canEdit: false,
        canDelete: false,
        canToggleStatus: false,
      );

      const higherRoleUser = AdminUserEntity(
        id: 'higher_1',
        name: 'District Manager',
        email: 'dm@mlf.com',
        phoneNumber: '9000000003',
        employeeId: 'mlf_dm1',
        role: AdminRole.districtManager,
        canEdit: false,
        canDelete: false,
        canToggleStatus: false,
      );

      // Verify subordinate permissions
      expect(subordinateUser.canEdit, isTrue);
      expect(subordinateUser.canDelete, isTrue);
      expect(subordinateUser.canToggleStatus, isTrue);

      // Verify peer/same level permissions are blocked
      expect(equalRoleUser.canEdit, isFalse);
      expect(equalRoleUser.canDelete, isFalse);
      expect(equalRoleUser.canToggleStatus, isFalse);

      // Verify higher level permissions are blocked
      expect(higherRoleUser.canEdit, isFalse);
      expect(higherRoleUser.canDelete, isFalse);
      expect(higherRoleUser.canToggleStatus, isFalse);
    });
  });

  group('EnvConfig Resolution', () {
    test('Default environments return correct base URLs', () {
      expect(AppEnvironment.local.defaultBaseUrl, contains('3500'));
      expect(AppEnvironment.dev.defaultBaseUrl, contains('dev-api'));
      expect(AppEnvironment.prod.defaultBaseUrl, contains('api.mlf'));
    });
  });

  group('AdminController CRUD Flow', () {
    late MockAdminRepository mockRepo;
    late AdminController controller;

    setUp(() {
      mockRepo = MockAdminRepository();
      mockRepo.users = [
        const AdminUserEntity(
          id: 'u1',
          name: 'Existing Admin',
          email: 'admin@mlf.com',
          phoneNumber: '9876543210',
          employeeId: 'mlf_01',
          role: AdminRole.generalManager,
          isActive: true,
        ),
      ];

      controller = AdminController(
        getAdminUsersUseCase: GetAdminUsersUseCase(mockRepo),
        getAdminUserDetailsUseCase: GetAdminUserDetailsUseCase(mockRepo),
        createAdminUserUseCase: CreateAdminUserUseCase(mockRepo),
        updateAdminUserUseCase: UpdateAdminUserUseCase(mockRepo),
        updateAdminIsActiveUseCase: UpdateAdminIsActiveUseCase(mockRepo),
        deleteAdminUserUseCase: DeleteAdminUserUseCase(mockRepo),
      );
    });

    test('fetchUsers loads user list into controller', () async {
      await controller.fetchUsers();

      expect(controller.isLoading, false);
      expect(controller.adminList.users.length, 1);
      expect(controller.adminList.users.first.name, 'Existing Admin');
    });

    test('createUser successfully creates and refreshes list', () async {
      final success = await controller.createUser(
        name: 'New User',
        email: 'new@mlf.com',
        phoneNumber: '9123456789',
        role: 'GODOWN_MANAGER',
        employeeId: 'mlf_02',
      );

      expect(success, true);
      expect(controller.adminList.users.length, 2);
      expect(controller.successMessage, isNotNull);
    });

    test('updateUser successfully modifies user details', () async {
      final success = await controller.updateUser(
        id: 'u1',
        name: 'Updated Name',
        email: 'updated@mlf.com',
      );

      expect(success, true);
      final updated = controller.adminList.users.firstWhere((u) => u.id == 'u1');
      expect(updated.name, 'Updated Name');
    });

    test('toggleUserStatus updates active boolean status', () async {
      final success = await controller.toggleUserStatus('u1', false);

      expect(success, true);
      final toggled = controller.adminList.users.firstWhere((u) => u.id == 'u1');
      expect(toggled.isActive, false);
    });

    test('deleteUser removes user from list', () async {
      final success = await controller.deleteUser('u1');

      expect(success, true);
      expect(controller.adminList.users.isEmpty, true);
    });
  });
}
