import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/theme/app_theme.dart';
import 'package:mlf_frontend/features/admin/data/models/godown_model.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_list_entity.dart';
import 'package:mlf_frontend/features/admin/domain/repositories/godown_repository.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/create_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/delete_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_eligible_godown_admins_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godown_by_id_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godowns_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_is_active_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import 'package:mlf_frontend/features/admin/presentation/pages/godown_management_page.dart';

class MockGodownRepository implements GodownRepository {
  List<GodownEntity> godowns = [];
  bool shouldFail = false;

  @override
  Future<GodownListEntity> getGodowns({
    int page = 1,
    int limit = 10,
    String? search,
    GodownType? type,
    bool? isActive,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
  }) async {
    if (shouldFail) throw Exception('Failed to load godowns');
    var filtered = List<GodownEntity>.from(godowns);
    if (type != null) {
      filtered = filtered.where((g) => g.type == type).toList();
    }
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((g) =>
          g.name.toLowerCase().contains(search.toLowerCase()) ||
          g.godownId.toLowerCase().contains(search.toLowerCase())).toList();
    }
    if (isActive != null) {
      filtered = filtered.where((g) => g.isActive == isActive).toList();
    }
    return GodownListEntity(
      godowns: filtered,
      pagination: GodownPaginationEntity(
        currentPage: page,
        totalPages: (filtered.length / limit).ceil().clamp(1, 999),
        totalCount: filtered.length,
        limit: limit,
      ),
    );
  }

  @override
  Future<GodownEntity> getGodownById(String id) async {
    return godowns.firstWhere((g) => g.id == id);
  }

  @override
  Future<String> createGodown({
    required String name,
    String? godownId,
    required GodownType type,
    String? description,
    required String country,
    required String zone,
    required String state,
    required String district,
    required String pincode,
    String? address,
    String? gstin,
    String? phoneNumber,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool isActive = true,
  }) async {
    final newId = 'gd_${godowns.length + 1}';
    final entity = GodownEntity(
      id: newId,
      godownId: godownId ?? 'GD_0${godowns.length + 1}',
      name: name,
      type: type,
      description: description,
      country: country,
      zone: zone,
      state: state,
      district: district,
      pincode: pincode,
      address: address ?? '',
      gstin: gstin ?? '',
      phoneNumber: phoneNumber ?? '',
      isActive: isActive,
      godownManager: godownManagerId != null
          ? AssignedAdminEntity(id: godownManagerId, name: 'Manager 1', employeeId: 'EMP_M1', phoneNumber: '', email: '', role: 'GODOWN_MANAGER')
          : null,
      billingUser: billingUserId != null
          ? AssignedAdminEntity(id: billingUserId, name: 'Billing 1', employeeId: 'EMP_B1', phoneNumber: '', email: '', role: 'BILLING_USER')
          : null,
      supervisors: (supervisorId ?? []).map((id) => AssignedAdminEntity(id: id, name: 'Supervisor', employeeId: 'EMP_S', phoneNumber: '', email: '', role: 'SUPERVISOR')).toList(),
      assistants: (assistantId ?? []).map((id) => AssignedAdminEntity(id: id, name: 'Assistant', employeeId: 'EMP_A', phoneNumber: '', email: '', role: 'ASSISTANT')).toList(),
    );
    godowns.add(entity);
    return newId;
  }

  @override
  Future<void> updateGodown({
    required String id,
    String? name,
    String? godownId,
    GodownType? type,
    String? description,
    String? address,
    String? gstin,
    String? phoneNumber,
    bool? isActive,
    String? godownManagerId,
    bool clearGodownManager = false,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool clearBillingUser = false,
  }) async {
    final idx = godowns.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final old = godowns[idx];
      godowns[idx] = GodownEntity(
        id: old.id,
        godownId: godownId ?? old.godownId,
        name: name ?? old.name,
        type: type ?? old.type,
        description: description ?? old.description,
        address: address ?? old.address,
        gstin: gstin ?? old.gstin,
        phoneNumber: phoneNumber ?? old.phoneNumber,
        country: old.country,
        zone: old.zone,
        state: old.state,
        district: old.district,
        pincode: old.pincode,
        godownManager: clearGodownManager
            ? null
            : (godownManagerId != null
                ? AssignedAdminEntity(
                    id: godownManagerId,
                    name: 'Manager',
                    employeeId: 'EMP_M',
                    phoneNumber: '',
                    email: '',
                    role: 'GODOWN_MANAGER',
                  )
                : old.godownManager),
        billingUser: clearBillingUser
            ? null
            : (billingUserId != null
                ? AssignedAdminEntity(
                    id: billingUserId,
                    name: 'Billing',
                    employeeId: 'EMP_B',
                    phoneNumber: '',
                    email: '',
                    role: 'BILLING_USER',
                  )
                : old.billingUser),
        isActive: isActive ?? old.isActive,
      );
    }
  }

  @override
  Future<void> updateGodownIsActive({
    required List<String> godownIds,
    required bool isActive,
  }) async {
    for (final id in godownIds) {
      final idx = godowns.indexWhere((g) => g.id == id);
      if (idx != -1) {
        final old = godowns[idx];
        godowns[idx] = GodownEntity(
          id: old.id,
          godownId: old.godownId,
          name: old.name,
          type: old.type,
          description: old.description,
          country: old.country,
          zone: old.zone,
          state: old.state,
          district: old.district,
          pincode: old.pincode,
          isActive: isActive,
        );
      }
    }
  }

  @override
  Future<void> deleteGodown(String id) async {
    godowns.removeWhere((g) => g.id == id);
  }

  @override
  Future<List<AssignedAdminEntity>> getEligibleAdmins({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
  }) async {
    return [];
  }
}

void main() {
  late MockGodownRepository repository;
  late GodownController controller;

  setUp(() {
    repository = MockGodownRepository();
    controller = GodownController(
      getGodownsUseCase: GetGodownsUseCase(repository),
      getGodownByIdUseCase: GetGodownByIdUseCase(repository),
      createGodownUseCase: CreateGodownUseCase(repository),
      updateGodownUseCase: UpdateGodownUseCase(repository),
      updateGodownIsActiveUseCase: UpdateGodownIsActiveUseCase(repository),
      deleteGodownUseCase: DeleteGodownUseCase(repository),
      getEligibleGodownAdminsUseCase: GetEligibleGodownAdminsUseCase(repository),
    );
  });

  group('GodownModel payload tests', () {
    test('toCreatePayload for company godown includes admin users', () {
      final payload = GodownModel.toCreatePayload(
        name: 'Coimbatore Main',
        type: GodownType.companyGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Coimbatore',
        pincode: '641001',
        godownManagerId: '64f8a1234567890abcdef123',
        billingUserId: '64f8a1234567890abcdef124',
        supervisorId: ['64f8a1234567890abcdef125'],
        assistantId: ['64f8a1234567890abcdef126'],
      );

      expect(payload['type'], 'company godown');
      expect(payload['godownManagerId'], '64f8a1234567890abcdef123');
      expect(payload['billingUserId'], '64f8a1234567890abcdef124');
      expect(payload['supervisorId'], ['64f8a1234567890abcdef125']);
      expect(payload['assistantId'], ['64f8a1234567890abcdef126']);
    });

    test('toCreatePayload for jobwork godown does not require or include admin user fields', () {
      final payload = GodownModel.toCreatePayload(
        name: 'Tirupur Dyeing Unit',
        type: GodownType.jobworkGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Tirupur',
        pincode: '641601',
        godownManagerId: '64f8a1234567890abcdef123', // Even if passed, should be omitted
        billingUserId: '64f8a1234567890abcdef124',
        supervisorId: ['64f8a1234567890abcdef125'],
        assistantId: ['64f8a1234567890abcdef126'],
      );

      expect(payload['type'], 'jobwork godown');
      expect(payload.containsKey('godownManagerId'), isFalse);
      expect(payload.containsKey('billingUserId'), isFalse);
      expect(payload.containsKey('supervisorId'), isFalse);
      expect(payload.containsKey('assistantId'), isFalse);
    });

    test('toUpdatePayload for jobwork godown nulls/clears admin staff assignments', () {
      final payload = GodownModel.toUpdatePayload(
        name: 'Updated Jobwork Unit',
        type: GodownType.jobworkGodown,
        godownManagerId: 'some_id',
      );

      expect(payload['type'], 'jobwork godown');
      expect(payload['godownManagerId'], isNull);
      expect(payload['billingUserId'], isNull);
      expect(payload['supervisorId'], isEmpty);
      expect(payload['assistantId'], isEmpty);
    });

    test('toUpdatePayload sets godownManagerId and billingUserId to null when clear flags are true or empty strings passed', () {
      final payloadCleared = GodownModel.toUpdatePayload(
        name: 'Updated Company Godown',
        type: GodownType.companyGodown,
        clearGodownManager: true,
        clearBillingUser: true,
      );

      expect(payloadCleared['godownManagerId'], isNull);
      expect(payloadCleared['billingUserId'], isNull);

      final payloadEmpty = GodownModel.toUpdatePayload(
        name: 'Updated Company Godown',
        type: GodownType.companyGodown,
        godownManagerId: '',
        billingUserId: '',
      );

      expect(payloadEmpty['godownManagerId'], isNull);
      expect(payloadEmpty['billingUserId'], isNull);

      final payloadUntouched = GodownModel.toUpdatePayload(
        name: 'Only Name Updated',
        type: GodownType.companyGodown,
      );

      expect(payloadUntouched.containsKey('godownManagerId'), isFalse);
      expect(payloadUntouched.containsKey('billingUserId'), isFalse);
    });
  });

  group('GodownController sub-tab and filtering tests', () {
    test('setTypeFilter filters godowns by type and updates state', () async {
      await repository.createGodown(
        name: 'Company Godown 1',
        type: GodownType.companyGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Coimbatore',
        pincode: '641001',
      );
      await repository.createGodown(
        name: 'Jobwork Godown 1',
        type: GodownType.jobworkGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Tirupur',
        pincode: '641601',
      );

      // Filter Company Godowns
      controller.setTypeFilter(GodownType.companyGodown);
      await controller.fetchGodowns();
      expect(controller.godowns.length, 1);
      expect(controller.godowns.first.name, 'Company Godown 1');
      expect(controller.godowns.first.type, GodownType.companyGodown);

      // Filter Jobwork Godowns
      controller.setTypeFilter(GodownType.jobworkGodown);
      await controller.fetchGodowns();
      expect(controller.godowns.length, 1);
      expect(controller.godowns.first.name, 'Jobwork Godown 1');
      expect(controller.godowns.first.type, GodownType.jobworkGodown);
    });

    test('updateGodown clears manager and billing user when clear flags are set', () async {
      final id = await repository.createGodown(
        name: 'Godown With Staff',
        type: GodownType.companyGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Coimbatore',
        pincode: '641001',
        godownManagerId: 'mgr_1',
        billingUserId: 'bill_1',
      );

      await controller.fetchGodowns();
      final created = controller.godowns.firstWhere((g) => g.id == id);
      expect(created.godownManager?.id, 'mgr_1');
      expect(created.billingUser?.id, 'bill_1');

      // Update and clear staff
      final success = await controller.updateGodown(
        id: id,
        name: 'Godown Without Staff',
        clearGodownManager: true,
        clearBillingUser: true,
      );

      expect(success, isTrue);
      await controller.fetchGodowns();
      final updated = controller.godowns.firstWhere((g) => g.id == id);
      expect(updated.godownManager, isNull);
      expect(updated.billingUser, isNull);
    });
  });

  group('GodownManagementPage UI Sub-Tabs test', () {
    testWidgets('Renders Company and Jobwork sub tabs under godown tab', (tester) async {
      await repository.createGodown(
        name: 'Coimbatore Mill Godown',
        type: GodownType.companyGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Coimbatore',
        pincode: '641001',
      );
      await repository.createGodown(
        name: 'Erode Knitting Partner',
        type: GodownType.jobworkGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Erode',
        pincode: '638001',
      );

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GodownManagementPage(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify sub-tabs exist
      expect(find.text('Company Godowns'), findsOneWidget);
      expect(find.text('Jobwork Godowns'), findsOneWidget);

      // By default, Company Godowns tab is selected
      expect(find.text('Coimbatore Mill Godown'), findsOneWidget);
      expect(find.text('Erode Knitting Partner'), findsNothing);

      // Switch to Jobwork Godowns sub-tab
      await tester.tap(find.text('Jobwork Godowns'));
      await tester.pumpAndSettle();

      // Now Jobwork Godowns are displayed
      expect(find.text('Erode Knitting Partner'), findsOneWidget);
      expect(find.text('Coimbatore Mill Godown'), findsNothing);
    });
  });
}
