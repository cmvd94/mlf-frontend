import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/theme/app_theme.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/create_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/delete_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_eligible_godown_admins_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godown_by_id_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/get_godowns_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_is_active_usecase.dart';
import 'package:mlf_frontend/features/admin/domain/usecases/update_godown_usecase.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/party_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/item_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/uom_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/per_unit_entity.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/available_stock_entity.dart';

// Debit Note
import 'package:mlf_frontend/features/debit_note/data/models/debit_note_model.dart';
import 'package:mlf_frontend/features/debit_note/domain/entities/debit_note_entity.dart';
import 'package:mlf_frontend/features/debit_note/domain/repositories/debit_note_repository.dart';
import 'package:mlf_frontend/features/debit_note/presentation/controllers/debit_note_controller.dart';
import 'package:mlf_frontend/features/debit_note/presentation/pages/debit_note_page.dart';
import 'package:mlf_frontend/features/debit_note/presentation/widgets/debit_note_detail_dialog.dart';
import 'package:mlf_frontend/features/debit_note/presentation/widgets/debit_note_entry_dialog.dart';

// Credit Note
import 'package:mlf_frontend/features/credit_note/data/models/credit_note_model.dart';
import 'package:mlf_frontend/features/credit_note/domain/entities/credit_note_entity.dart';
import 'package:mlf_frontend/features/credit_note/domain/repositories/credit_note_repository.dart';
import 'package:mlf_frontend/features/credit_note/presentation/controllers/credit_note_controller.dart';
import 'package:mlf_frontend/features/credit_note/presentation/pages/credit_note_page.dart';
import 'package:mlf_frontend/features/credit_note/presentation/widgets/credit_note_detail_dialog.dart';
import 'package:mlf_frontend/features/credit_note/presentation/widgets/credit_note_entry_dialog.dart';

import 'godown_test.dart';
import 'mocks/mock_inventory_purchase.dart';

class MockDebitNoteRepository implements DebitNoteRepository {
  List<DebitNoteEntity> debitNotes = [];
  List<AvailableStockEntity> availableStocks = [];

  @override
  Future<({List<DebitNoteEntity> debitNotes, int totalCount, int totalPages, int currentPage})> getDebitNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  }) async {
    return (
      debitNotes: debitNotes,
      totalCount: debitNotes.length,
      totalPages: (debitNotes.length / limit).ceil() == 0 ? 1 : (debitNotes.length / limit).ceil(),
      currentPage: page,
    );
  }

  @override
  Future<DebitNoteEntity> getDebitNoteById(String id) async {
    return debitNotes.firstWhere((dn) => dn.id == id);
  }

  @override
  Future<DebitNoteEntity> createDebitNote(DebitNoteCreateInput input) async {
    final items = input.items.map((i) {
      return DebitNoteItemEntity(
        id: 'dn_item_${DateTime.now().millisecondsSinceEpoch}',
        godownStockId: i.godownStockId,
        itemId: i.itemId ?? 'item_1',
        itemName: 'Cotton Yarn 40s',
        itemCode: 'CY40',
        godownId: i.godownId ?? 'gd_01',
        godownName: 'Main Storage Godown',
        godownCode: 'GDN_01',
        companyGodownId: i.companyGodownId,
        dcNo: i.dcNo,
        lotNo: i.lotNo,
        uomId: i.uomId ?? 'uom_1',
        uomSymbol: 'KG',
        uomQuantity: i.uomQuantity,
        actualQuantity: i.actualQuantity,
        billedQuantity: i.billedQuantity,
        quantity: i.actualQuantity,
        rate: i.rate,
        perId: i.perId ?? 'per_1',
        perSymbol: 'KG',
        amount: i.billedQuantity * i.rate,
      );
    }).toList();

    double subTotal = items.fold(0.0, (sum, it) => sum + it.amount);
    double gstAmount = input.isGstBill ? (subTotal * (input.gstPercentage ?? 18)) / 100 : 0.0;
    double totalAmount = subTotal + gstAmount;

    final note = DebitNoteEntity(
      id: 'dn_${DateTime.now().millisecondsSinceEpoch}',
      debitNoteNumber: 'DN_000${debitNotes.length + 1}',
      date: input.date,
      debitNoteTypeId: input.debitNoteTypeId,
      debitNoteTypeName: 'Debit Return',
      debitNoteTypeCode: 'DR_RET',
      partyId: input.partyId,
      partyName: 'ABC Textiles',
      partyCode: 'PTY_ABC',
      dcNo: input.dcNo ?? '',
      companyGodownId: input.companyGodownId ?? 'gd_01',
      companyGodownName: 'Main Storage Godown',
      items: items,
      subTotal: subTotal,
      isGstBill: input.isGstBill,
      gstPercentage: input.isGstBill ? (input.gstPercentage ?? 18) : 0.0,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      totalActualQuantity: items.fold(0.0, (sum, it) => sum + it.actualQuantity),
      totalBilledQuantity: items.fold(0.0, (sum, it) => sum + it.billedQuantity),
      totalQuantity: items.fold(0.0, (sum, it) => sum + it.actualQuantity),
      notes: input.notes ?? '',
      narration: input.narration ?? '',
      createdByName: 'Vishnudas',
      createdAt: DateTime.now(),
    );

    debitNotes.add(note);
    return note;
  }

  @override
  Future<DebitNoteEntity> updateDebitNote(String id, DebitNoteUpdateInput input) async {
    final idx = debitNotes.indexWhere((n) => n.id == id);
    if (idx == -1) throw Exception('Debit note not found');

    final existing = debitNotes[idx];
    final updated = DebitNoteEntity(
      id: existing.id,
      debitNoteNumber: existing.debitNoteNumber,
      date: input.date ?? existing.date,
      debitNoteTypeId: input.debitNoteTypeId ?? existing.debitNoteTypeId,
      debitNoteTypeName: existing.debitNoteTypeName,
      debitNoteTypeCode: existing.debitNoteTypeCode,
      partyId: input.partyId ?? existing.partyId,
      partyName: existing.partyName,
      partyCode: existing.partyCode,
      dcNo: existing.dcNo,
      companyGodownId: input.companyGodownId ?? existing.companyGodownId,
      companyGodownName: existing.companyGodownName,
      items: existing.items,
      subTotal: existing.subTotal,
      isGstBill: input.isGstBill ?? existing.isGstBill,
      gstPercentage: input.gstPercentage ?? existing.gstPercentage,
      gstAmount: existing.gstAmount,
      totalAmount: existing.totalAmount,
      totalActualQuantity: existing.totalActualQuantity,
      totalBilledQuantity: existing.totalBilledQuantity,
      totalQuantity: existing.totalQuantity,
      notes: input.notes ?? existing.notes,
      narration: input.narration ?? existing.narration,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,
    );
    debitNotes[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteDebitNote(String id) async {
    debitNotes.removeWhere((n) => n.id == id);
  }

  @override
  Future<List<AvailableStockEntity>> getAvailableStocks({
    String? godownId,
    String? itemId,
    String? search,
  }) async {
    return availableStocks;
  }
}

class MockCreditNoteRepository implements CreditNoteRepository {
  List<CreditNoteEntity> creditNotes = [];

  @override
  Future<({List<CreditNoteEntity> creditNotes, int totalCount, int totalPages, int currentPage})> getCreditNotes({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  }) async {
    return (
      creditNotes: creditNotes,
      totalCount: creditNotes.length,
      totalPages: (creditNotes.length / limit).ceil() == 0 ? 1 : (creditNotes.length / limit).ceil(),
      currentPage: page,
    );
  }

  @override
  Future<CreditNoteEntity> getCreditNoteById(String id) async {
    return creditNotes.firstWhere((cn) => cn.id == id);
  }

  @override
  Future<CreditNoteEntity> createCreditNote(CreditNoteCreateInput input) async {
    final items = input.items.map((i) {
      return CreditNoteItemEntity(
        id: 'cn_item_${DateTime.now().millisecondsSinceEpoch}',
        itemId: i.itemId,
        itemName: 'Cotton Yarn 40s',
        itemCode: 'CY40',
        godownId: i.godownId,
        godownName: 'Main Storage Godown',
        godownCode: 'GDN_01',
        dcNo: i.dcNo,
        lotNo: i.lotNo,
        uomId: i.uomId,
        uomSymbol: 'KG',
        uomQuantity: i.uomQuantity,
        actualQuantity: i.actualQuantity,
        billedQuantity: i.billedQuantity,
        rate: i.rate,
        perId: i.perId,
        perSymbol: 'KG',
        amount: i.billedQuantity * i.rate,
      );
    }).toList();

    double subTotal = items.fold(0.0, (sum, it) => sum + it.amount);
    double gstAmount = input.isGstBill ? (subTotal * (input.gstPercentage ?? 18)) / 100 : 0.0;
    double totalAmount = subTotal + gstAmount;

    final note = CreditNoteEntity(
      id: 'cn_${DateTime.now().millisecondsSinceEpoch}',
      creditNoteNumber: 'CN_000${creditNotes.length + 1}',
      date: input.date,
      creditNoteTypeId: input.creditNoteTypeId,
      creditNoteTypeName: 'Credit Return',
      creditNoteTypeCode: 'CR_RET',
      partyId: input.partyId,
      partyName: 'ABC Textiles',
      partyCode: 'PTY_ABC',
      dcNo: input.items.isNotEmpty ? input.items.first.dcNo : '',
      companyGodownId: input.companyGodownId,
      companyGodownName: 'Main Storage Godown',
      items: items,
      subTotal: subTotal,
      isGstBill: input.isGstBill,
      gstPercentage: input.isGstBill ? (input.gstPercentage ?? 18) : 0.0,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      totalActualQuantity: items.fold(0.0, (sum, it) => sum + it.actualQuantity),
      totalBilledQuantity: items.fold(0.0, (sum, it) => sum + it.billedQuantity),
      totalQuantity: items.fold(0.0, (sum, it) => sum + it.actualQuantity),
      notes: input.notes ?? '',
      createdByName: 'Vishnudas',
      createdAt: DateTime.now(),
    );

    creditNotes.add(note);
    return note;
  }

  @override
  Future<CreditNoteEntity> updateCreditNote(String id, CreditNoteUpdateInput input) async {
    final idx = creditNotes.indexWhere((n) => n.id == id);
    if (idx == -1) throw Exception('Credit note not found');

    final existing = creditNotes[idx];
    final updated = CreditNoteEntity(
      id: existing.id,
      creditNoteNumber: existing.creditNoteNumber,
      date: input.date ?? existing.date,
      creditNoteTypeId: input.creditNoteTypeId ?? existing.creditNoteTypeId,
      creditNoteTypeName: existing.creditNoteTypeName,
      creditNoteTypeCode: existing.creditNoteTypeCode,
      partyId: input.partyId ?? existing.partyId,
      partyName: existing.partyName,
      partyCode: existing.partyCode,
      dcNo: existing.dcNo,
      companyGodownId: input.companyGodownId ?? existing.companyGodownId,
      companyGodownName: existing.companyGodownName,
      items: existing.items,
      subTotal: existing.subTotal,
      isGstBill: input.isGstBill ?? existing.isGstBill,
      gstPercentage: input.gstPercentage ?? existing.gstPercentage,
      gstAmount: existing.gstAmount,
      totalAmount: existing.totalAmount,
      totalActualQuantity: existing.totalActualQuantity,
      totalBilledQuantity: existing.totalBilledQuantity,
      totalQuantity: existing.totalQuantity,
      notes: input.notes ?? existing.notes,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,
    );
    creditNotes[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteCreditNote(String id) async {
    creditNotes.removeWhere((n) => n.id == id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locator = ServiceLocator.instance;

  late MockDebitNoteRepository debitNoteRepo;
  late MockCreditNoteRepository creditNoteRepo;
  late MockInventoryRepository inventoryRepo;
  late MockGodownRepository godownRepo;

  setUp(() {
    locator.reset();

    godownRepo = MockGodownRepository();
    godownRepo.godowns = [
      const GodownEntity(
        id: 'gd_01',
        godownId: 'GDN_01',
        name: 'Main Storage Godown',
        country: 'India',
        zone: 'South',
        state: 'Tamil Nadu',
        district: 'Coimbatore',
        pincode: '641001',
        type: GodownType.companyGodown,
        isActive: true,
      ),
    ];

    locator.register<GodownController>(GodownController(
      getGodownsUseCase: GetGodownsUseCase(godownRepo),
      getGodownByIdUseCase: GetGodownByIdUseCase(godownRepo),
      createGodownUseCase: CreateGodownUseCase(godownRepo),
      updateGodownUseCase: UpdateGodownUseCase(godownRepo),
      updateGodownIsActiveUseCase: UpdateGodownIsActiveUseCase(godownRepo),
      deleteGodownUseCase: DeleteGodownUseCase(godownRepo),
      getEligibleGodownAdminsUseCase: GetEligibleGodownAdminsUseCase(godownRepo),
    ));

    inventoryRepo = MockInventoryRepository();
    inventoryRepo.godowns = godownRepo.godowns;
    inventoryRepo.parties = [
      const PartyEntity(
        id: 'party_1',
        partyCode: 'PTY_ABC',
        name: 'ABC Textiles',
        phoneNumber: '9876543210',
        isActive: true,
      ),
    ];
    inventoryRepo.items = [
      const ItemEntity(
        id: 'item_1',
        name: 'Cotton Yarn 40s',
        itemCode: 'CY40',
        defaultUomId: 'uom_1',
        defaultPerId: 'per_1',
        currentStock: 500,
        isActive: true,
      ),
    ];
    inventoryRepo.uoms = [
      const UomEntity(id: 'uom_1', name: 'Kilograms', symbol: 'KG'),
    ];
    inventoryRepo.perUnits = [
      const PerUnitEntity(id: 'per_1', name: 'Kilogram', symbol: 'KG', multiplier: 1),
    ];

    locator.register<InventoryController>(InventoryController(repository: inventoryRepo));

    debitNoteRepo = MockDebitNoteRepository();
    locator.register<DebitNoteController>(DebitNoteController(repository: debitNoteRepo));

    creditNoteRepo = MockCreditNoteRepository();
    locator.register<CreditNoteController>(CreditNoteController(repository: creditNoteRepo));
  });

  group('Debit Note Controller Tests', () {
    test('creates and retrieves debit notes with stock check', () async {
      final controller = locator.get<DebitNoteController>();

      debitNoteRepo.availableStocks = [
        const AvailableStockEntity(
          godownStockId: 'stk_01',
          itemId: 'item_1',
          itemName: 'Cotton Yarn 40s',
          itemCode: 'CY40',
          godownId: 'gd_01',
          godownName: 'Main Storage Godown',
          companyGodownId: 'gd_01',
          companyGodownName: 'Main Storage Godown',
          dcNo: 'DC_101',
          lotNo: 'LOT_A',
          currentStock: 100.0,
          rate: 250.0,
          uomId: 'uom_1',
          uomSymbol: 'KG',
          uomQuantity: 1.0,
          perId: 'per_1',
          perSymbol: 'KG',
        ),
      ];

      await controller.fetchAvailableStocks(godownId: 'gd_01');
      expect(controller.availableStocks.length, 1);
      expect(controller.availableStocks.first.currentStock, 100.0);

      final success = await controller.createDebitNote(
        DebitNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          isGstBill: true,
          gstPercentage: 18.0,
          items: const [
            DebitNoteItemInput(
              godownStockId: 'stk_01',
              itemId: 'item_1',
              godownId: 'gd_01',
              actualQuantity: 10.0,
              billedQuantity: 10.0,
              rate: 250.0,
            ),
          ],
        ),
      );

      expect(success, isTrue);
      expect(controller.debitNotes.length, 1);
      expect(controller.debitNotes.first.debitNoteNumber, 'DN_0001');
      expect(controller.debitNotes.first.totalAmount, 2950.0);
    });

    test('updates and deletes debit note', () async {
      final controller = locator.get<DebitNoteController>();

      await controller.createDebitNote(
        DebitNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          items: const [
            DebitNoteItemInput(
              godownStockId: 'stk_01',
              actualQuantity: 5.0,
              billedQuantity: 5.0,
              rate: 200.0,
            ),
          ],
        ),
      );

      final id = controller.debitNotes.first.id;
      final updateSuccess = await controller.updateDebitNote(
        id,
        const DebitNoteUpdateInput(notes: 'Updated note message'),
      );
      expect(updateSuccess, isTrue);
      expect(controller.debitNotes.first.notes, 'Updated note message');

      final deleteSuccess = await controller.deleteDebitNote(id);
      expect(deleteSuccess, isTrue);
      expect(controller.debitNotes, isEmpty);
    });
  });

  group('Credit Note Controller Tests', () {
    test('creates and retrieves credit notes', () async {
      final controller = locator.get<CreditNoteController>();

      final success = await controller.createCreditNote(
        CreditNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          isGstBill: true,
          gstPercentage: 12.0,
          items: const [
            CreditNoteItemInput(
              itemId: 'item_1',
              godownId: 'gd_01',
              uomQuantity: 1.0,
              actualQuantity: 20.0,
              billedQuantity: 20.0,
              rate: 300.0,
              uomId: 'uom_1',
              perId: 'per_1',
            ),
          ],
        ),
      );

      expect(success, isTrue);
      expect(controller.creditNotes.length, 1);
      expect(controller.creditNotes.first.creditNoteNumber, 'CN_0001');
      expect(controller.creditNotes.first.subTotal, 6000.0);
      expect(controller.creditNotes.first.gstAmount, 720.0);
      expect(controller.creditNotes.first.totalAmount, 6720.0);
    });

    test('updates and deletes credit note', () async {
      final controller = locator.get<CreditNoteController>();

      await controller.createCreditNote(
        CreditNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          items: const [
            CreditNoteItemInput(
              itemId: 'item_1',
              godownId: 'gd_01',
              uomQuantity: 1.0,
              actualQuantity: 10.0,
              billedQuantity: 10.0,
              rate: 150.0,
              uomId: 'uom_1',
              perId: 'per_1',
            ),
          ],
        ),
      );

      final id = controller.creditNotes.first.id;
      final updateSuccess = await controller.updateCreditNote(
        id,
        const CreditNoteUpdateInput(notes: 'Returned due to damage'),
      );
      expect(updateSuccess, isTrue);
      expect(controller.creditNotes.first.notes, 'Returned due to damage');

      final deleteSuccess = await controller.deleteCreditNote(id);
      expect(deleteSuccess, isTrue);
      expect(controller.creditNotes, isEmpty);
    });
  });

  group('Debit Note UI Widget Tests', () {
    testWidgets('renders DebitNotePage and list items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = locator.get<DebitNoteController>();
      await controller.createDebitNote(
        DebitNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          items: const [
            DebitNoteItemInput(
              godownStockId: 'stk_01',
              actualQuantity: 15.0,
              billedQuantity: 15.0,
              rate: 100.0,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: DebitNotePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Debit Notes'), findsOneWidget);
      expect(find.text('DN_0001'), findsOneWidget);
      expect(find.text('ABC Textiles'), findsOneWidget);
    });

    testWidgets('shows DebitNoteDetailDialog on view', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = locator.get<DebitNoteController>();
      await controller.createDebitNote(
        DebitNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          items: const [
            DebitNoteItemInput(
              godownStockId: 'stk_01',
              actualQuantity: 10.0,
              billedQuantity: 10.0,
              rate: 100.0,
            ),
          ],
        ),
      );

      final debitNote = controller.debitNotes.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showDialog(
                  context: ctx,
                  builder: (_) => DebitNoteDetailDialog(debitNote: debitNote),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Debit Note: DN_0001'), findsOneWidget);
      expect(find.text('ABC Textiles'), findsOneWidget);
    });

    testWidgets('opens DebitNoteEntryDialog and renders UOM * column', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: DebitNotePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('New Debit Note'));
      await tester.pumpAndSettle();

      expect(find.byType(DebitNoteEntryDialog), findsOneWidget);
      expect(find.text('UOM *'), findsOneWidget);
    });
  });

  group('Credit Note UI Widget Tests', () {
    testWidgets('renders CreditNotePage and list items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = locator.get<CreditNoteController>();
      await controller.createCreditNote(
        CreditNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          items: const [
            CreditNoteItemInput(
              itemId: 'item_1',
              godownId: 'gd_01',
              uomQuantity: 1.0,
              actualQuantity: 25.0,
              billedQuantity: 25.0,
              rate: 120.0,
              uomId: 'uom_1',
              perId: 'per_1',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CreditNotePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Credit Notes'), findsOneWidget);
      expect(find.text('CN_0001'), findsOneWidget);
      expect(find.text('ABC Textiles'), findsOneWidget);
    });

    testWidgets('shows CreditNoteDetailDialog on view', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = locator.get<CreditNoteController>();
      await controller.createCreditNote(
        CreditNoteCreateInput(
          date: DateTime.parse('2026-11-23'),
          partyId: 'party_1',
          companyGodownId: 'gd_01',
          items: const [
            CreditNoteItemInput(
              itemId: 'item_1',
              godownId: 'gd_01',
              uomQuantity: 1.0,
              actualQuantity: 5.0,
              billedQuantity: 5.0,
              rate: 200.0,
              uomId: 'uom_1',
              perId: 'per_1',
            ),
          ],
        ),
      );

      final creditNote = controller.creditNotes.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showDialog(
                  context: ctx,
                  builder: (_) => CreditNoteDetailDialog(creditNote: creditNote),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Credit Note: CN_0001'), findsOneWidget);
      expect(find.text('ABC Textiles'), findsOneWidget);
    });

    testWidgets('opens CreditNoteEntryDialog and renders UOM * column', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CreditNotePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('New Credit Note'));
      await tester.pumpAndSettle();

      expect(find.byType(CreditNoteEntryDialog), findsOneWidget);
      expect(find.text('UOM *'), findsOneWidget);
    });
  });
}
