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
import 'package:mlf_frontend/core/theme/app_theme.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';
import 'package:mlf_frontend/features/admin/presentation/pages/main_layout_page.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/create_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/delete_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_eligible_godown_admins_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godown_by_id_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godowns_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_is_active_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_usecase.dart';
import 'godown_test.dart';
import 'mocks/mock_inventory_purchase.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:mlf_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:mlf_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:mlf_frontend/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:mlf_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:mlf_frontend/features/auth/presentation/controllers/login_controller.dart';
import 'package:mlf_frontend/features/auth/presentation/pages/login_page.dart';

class MockAuthRepo implements AuthRepository {
  @override
  Future<void> changePassword({required String currentPassword, required String newPassword, required String confirmPassword}) async {}
  @override
  Future<void> clearAuth() async {}
  @override
  Future<void> saveAuthToken(String token) async {}
  @override
  Future<String?> getAuthToken() async => 'mock';
  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<UserEntity> loginWithPhoneAndPassword({required String phoneNumber, required String password}) async {
    return const UserEntity(
      id: '1',
      name: 'Vishnudas',
      email: 'vishnudassonyz2@gmail.com',
      phoneNumber: '9626298790',
      token: 'mock_jwt_token',
    );
  }
  @override
  Future<void> logout() async {}

  @override
  Future<void> logoutAll() async {}
}

class MockAdminRepo implements AdminRepository {
  @override
  Future<Map<String, dynamic>> getStaticData() async => {};

  @override
  Future<AdminListEntity> getAdminUsers({int page = 1, int limit = 10, String? role, bool? isActive, String? search}) async {
    return const AdminListEntity(
      users: [
        AdminUserEntity(
          id: '6afadef30f47f69a6e89d88c',
          name: 'Vishnudas',
          email: 'vishnudassonyz2@gmail.com',
          phoneNumber: '9626298790',
          employeeId: 'mlf_01',
          role: AdminRole.superAdmin,
          isActive: true,
        ),
      ],
      totalItems: 1,
      currentPage: 1,
      totalPages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }

  @override
  Future<AdminUserEntity> getAdminUserById(String id) async => throw UnimplementedError();
  @override
  Future<void> createAdminUser({required String name, required String email, required String phoneNumber, String? password, required String role, AccessScopeEntity? accessScope, String? employeeId, String? language}) async {}
  @override
  Future<void> deleteAdminUser(String id) async {}
  @override
  Future<void> updateAdminUser({required String id, String? name, String? email, String? role, AccessScopeEntity? accessScope, String? employeeId, String? language}) async {}
  @override
  Future<void> updateAdminUserIsActive({required String id, required bool isActive}) async {}
}

void main() {
  setUp(() {
    ServiceLocator.instance.reset();
    final sl = ServiceLocator.instance;
    final authRepo = MockAuthRepo();
    final adminRepo = MockAdminRepo();
    sl.register<AuthRepository>(authRepo);
    sl.register<ChangePasswordUseCase>(ChangePasswordUseCase(authRepo));
    final loginUseCase = LoginWithPhoneAndPasswordUseCase(authRepo);
    sl.register<LoginWithPhoneAndPasswordUseCase>(loginUseCase);
    sl.register<LoginController>(LoginController(loginUseCase: loginUseCase));
    sl.register<AdminController>(AdminController(
      getAdminUsersUseCase: GetAdminUsersUseCase(adminRepo),
      getAdminUserDetailsUseCase: GetAdminUserDetailsUseCase(adminRepo),
      createAdminUserUseCase: CreateAdminUserUseCase(adminRepo),
      updateAdminUserUseCase: UpdateAdminUserUseCase(adminRepo),
      updateAdminIsActiveUseCase: UpdateAdminIsActiveUseCase(adminRepo),
      deleteAdminUserUseCase: DeleteAdminUserUseCase(adminRepo),
    ));

    final godownRepo = MockGodownRepository();
    sl.register<GodownController>(GodownController(
      getGodownsUseCase: GetGodownsUseCase(godownRepo),
      getGodownByIdUseCase: GetGodownByIdUseCase(godownRepo),
      createGodownUseCase: CreateGodownUseCase(godownRepo),
      updateGodownUseCase: UpdateGodownUseCase(godownRepo),
      updateGodownIsActiveUseCase: UpdateGodownIsActiveUseCase(godownRepo),
      deleteGodownUseCase: DeleteGodownUseCase(godownRepo),
      getEligibleGodownAdminsUseCase: GetEligibleGodownAdminsUseCase(godownRepo),
    ));

    final invRepo = MockInventoryRepository();
    sl.register<InventoryController>(InventoryController(repository: invRepo));

    final purchaseRepo = MockPurchaseRepository();
    sl.register<PurchaseController>(PurchaseController(repository: purchaseRepo));
  });

  testWidgets('Login and transition flow at 1440x900', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: const LoginPage()));
    await tester.pumpAndSettle();

    // Enter phone and password
    await tester.enterText(find.byType(TextFormField).at(0), '9626298790');
    await tester.enterText(find.byType(TextFormField).at(1), 'mlf@123');

    // Click Sign In
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Admin Management'), findsOneWidget);
  });

  testWidgets('MainLayoutPage at 1024x768 (small desktop)', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
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
      token: 'mock_jwt_token',
    );

    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: MainLayoutPage(currentUser: user)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Admin Management'), findsOneWidget);
  });

  testWidgets('MainLayoutPage at 390x844 (mobile phone view)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
      token: 'mock_jwt_token',
    );

    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: MainLayoutPage(currentUser: user)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Admin Management'), findsOneWidget);
  });
}
