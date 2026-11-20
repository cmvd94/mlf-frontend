import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/features/admin/domain/entities/access_scope_entity.dart';
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
import 'package:mlf_frontend/features/admin/presentation/pages/main_layout_page.dart';
import 'package:mlf_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:mlf_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:mlf_frontend/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/create_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/delete_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_eligible_godown_admins_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godown_by_id_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godowns_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_is_active_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import 'godown_test.dart';
import 'mocks/mock_inventory_purchase.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/controllers/stock_transfer_controller.dart';
import 'package:mlf_frontend/features/stock_summary/domain/usecases/get_stock_summary_usecase.dart';
import 'package:mlf_frontend/features/stock_summary/presentation/controllers/stock_summary_controller.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {}

  @override
  Future<void> clearAuth() async {}

  @override
  Future<void> saveAuthToken(String token) async {}

  @override
  Future<String?> getAuthToken() async => 'mock_token';

  @override
  Future<UserEntity?> getCurrentUser() async => const UserEntity(
        id: '1',
        name: 'Vishnudas',
        email: 'vishnudassonyz2@gmail.com',
        phoneNumber: '9626298790',
        token: 'mock_token',
      );

  @override
  Future<UserEntity> loginWithPhoneAndPassword({required String phoneNumber, required String password}) async =>
      const UserEntity(
        id: '1',
        name: 'Vishnudas',
        email: 'vishnudassonyz2@gmail.com',
        phoneNumber: '9626298790',
        token: 'mock_token',
      );

  @override
  Future<void> logout() async {}

  @override
  Future<void> logoutAll() async {}
}

class FakeAdminRepository implements AdminRepository {
  List<AdminUserEntity> users = [
    const AdminUserEntity(
      id: '1',
      name: 'Vishnudas',
      email: 'vishnudassonyz2@gmail.com',
      phoneNumber: '9626298790',
      employeeId: 'mlf_01',
      role: AdminRole.superAdmin,
      isActive: true,
    ),
    const AdminUserEntity(
      id: '2',
      name: 'Manager One',
      email: 'manager@mlf.com',
      phoneNumber: '9876543210',
      employeeId: 'mlf_02',
      role: AdminRole.generalManager,
      isActive: true,
    ),
  ];

  @override
  Future<AdminListEntity> getAdminUsers({int page = 1, int limit = 10, String? role, bool? isActive, String? search}) async {
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
  Future<AdminUserEntity> getAdminUserById(String id) async => users.firstWhere((u) => u.id == id);

  @override
  Future<Map<String, dynamic>> getStaticData() async => {
        'adminAccessScope': {
          'India': {
            'SouthZone': {
              'TamilNadu': {
                'Coimbatore': {'pincodes': []},
              },
            },
          },
        },
      };

  @override
  Future<void> createAdminUser({
    required String name,
    required String email,
    required String phoneNumber,
    String? password,
    required String role,
    AccessScopeEntity? accessScope,
    String? employeeId,
    String? language,
  }) async {}

  @override
  Future<void> deleteAdminUser(String id) async {}

  @override
  Future<void> updateAdminUser({
    required String id,
    String? name,
    String? email,
    String? role,
    AccessScopeEntity? accessScope,
    String? employeeId,
    String? language,
  }) async {}

  @override
  Future<void> updateAdminUserIsActive({required String id, required bool isActive}) async {}
}

void main() {
  setUp(() {
    final authRepo = FakeAuthRepository();
    final adminRepo = FakeAdminRepository();

    ServiceLocator.instance.reset();
    final sl = ServiceLocator.instance;
    sl.register<AuthRepository>(authRepo);
    sl.register<ChangePasswordUseCase>(ChangePasswordUseCase(authRepo));

    final getAdminUsersUseCase = GetAdminUsersUseCase(adminRepo);
    final getAdminUserDetailsUseCase = GetAdminUserDetailsUseCase(adminRepo);
    final createAdminUserUseCase = CreateAdminUserUseCase(adminRepo);
    final updateAdminUserUseCase = UpdateAdminUserUseCase(adminRepo);
    final updateAdminIsActiveUseCase = UpdateAdminIsActiveUseCase(adminRepo);
    final deleteAdminUserUseCase = DeleteAdminUserUseCase(adminRepo);

    final adminCtrl = AdminController(
      getAdminUsersUseCase: getAdminUsersUseCase,
      getAdminUserDetailsUseCase: getAdminUserDetailsUseCase,
      createAdminUserUseCase: createAdminUserUseCase,
      updateAdminUserUseCase: updateAdminUserUseCase,
      updateAdminIsActiveUseCase: updateAdminIsActiveUseCase,
      deleteAdminUserUseCase: deleteAdminUserUseCase,
    );
    sl.register<AdminController>(adminCtrl);

    final godownRepo = MockGodownRepository();
    final godownCtrl = GodownController(
      getGodownsUseCase: GetGodownsUseCase(godownRepo),
      getGodownByIdUseCase: GetGodownByIdUseCase(godownRepo),
      createGodownUseCase: CreateGodownUseCase(godownRepo),
      updateGodownUseCase: UpdateGodownUseCase(godownRepo),
      updateGodownIsActiveUseCase: UpdateGodownIsActiveUseCase(godownRepo),
      deleteGodownUseCase: DeleteGodownUseCase(godownRepo),
      getEligibleGodownAdminsUseCase: GetEligibleGodownAdminsUseCase(godownRepo),
    );
    sl.register<GodownController>(godownCtrl);

    final invRepo = MockInventoryRepository();
    sl.register<InventoryController>(InventoryController(repository: invRepo));

    final purchaseRepo = MockPurchaseRepository();
    sl.register<PurchaseController>(PurchaseController(repository: purchaseRepo));

    final transferRepo = MockStockTransferRepository();
    sl.register<StockTransferController>(StockTransferController(repository: transferRepo));

    final stockSummaryRepo = MockStockSummaryRepository();
    final getStockSummaryUseCase = GetStockSummaryUseCase(stockSummaryRepo);
    sl.register<StockSummaryController>(StockSummaryController(getStockSummaryUseCase: getStockSummaryUseCase));
  });

  testWidgets('MainLayoutPage renders Admin Management and responds to user clicks', (tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const user = UserEntity(
      id: '1',
      name: 'Vishnudas',
      email: 'vishnudassonyz2@gmail.com',
      phoneNumber: '9626298790',
      token: 'mock_token',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MainLayoutPage(currentUser: user),
      ),
    );

    // Initial pump & settle post frame callbacks (e.g. fetchUsers)
    await tester.pumpAndSettle();

    // Verify header renders
    expect(find.text('Admin Management'), findsOneWidget);
    expect(find.text('Vishnudas'), findsWidgets);
    expect(find.text('Add Admin'), findsOneWidget);

    // Verify user list loaded into table
    expect(find.text('Manager One'), findsOneWidget);
    expect(find.text('mlf_01'), findsOneWidget);
    expect(find.text('mlf_02'), findsOneWidget);

    // Test clicking Add Admin button
    await tester.tap(find.text('Add Admin'));
    await tester.pumpAndSettle();

    // Verify AdminFormDialog is displayed
    expect(find.text('Create New Admin User'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Open popup sidebar drawer via Menu button
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Test switching tabs to Dashboard
    await tester.tap(find.widgetWithText(ListTile, 'Dashboard'));
    await tester.pumpAndSettle();

    // Verify Dashboard is rendered
    expect(find.text('Welcome, Vishnudas!'), findsOneWidget);

    // Open popup sidebar drawer via Menu button again
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Test switching back to Admin Users via sidebar
    await tester.tap(find.widgetWithText(ListTile, 'Admin Users'));
    await tester.pumpAndSettle();
    expect(find.text('Admin Management'), findsOneWidget);
  });
}
