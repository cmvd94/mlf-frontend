import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/theme/app_theme.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/inventory/presentation/pages/account_inventory_page.dart';
import 'package:mlf_frontend/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:mlf_frontend/features/purchase/presentation/pages/purchase_management_page.dart';
import 'package:mlf_frontend/features/purchase/presentation/widgets/purchase_entry_dialog.dart';
import 'package:mlf_frontend/features/purchase/data/models/purchase_model.dart';
import 'package:mlf_frontend/features/purchase/domain/entities/purchase_entity.dart';
import 'mocks/mock_inventory_purchase.dart';

void main() {
  late MockInventoryRepository mockInvRepo;
  late MockPurchaseRepository mockPurchaseRepo;
  late InventoryController inventoryController;
  late PurchaseController purchaseController;

  setUp(() {
    ServiceLocator.instance.reset();
    mockInvRepo = MockInventoryRepository();
    mockPurchaseRepo = MockPurchaseRepository();
    inventoryController = InventoryController(repository: mockInvRepo);
    purchaseController = PurchaseController(repository: mockPurchaseRepo);

    ServiceLocator.instance.register<InventoryController>(inventoryController);
    ServiceLocator.instance.register<PurchaseController>(purchaseController);
  });

  group('InventoryController Master CRUD Tests', () {
    test('fetchMasters loads all dynamic masters', () async {
      await inventoryController.fetchMasters();

      expect(inventoryController.parties.length, 1);
      expect(inventoryController.parties.first.name, 'Alpha Steel Corp');
      expect(inventoryController.purchaseTypes.length, 1);
      expect(inventoryController.purchaseTypes.first.name, 'Local Purchase');
      expect(inventoryController.itemGroups.length, 1);
      expect(inventoryController.itemGroups.first.name, 'Raw Material');
      expect(inventoryController.uoms.length, 2);
      expect(inventoryController.perUnits.length, 1);
      expect(inventoryController.items.length, 1);
      expect(inventoryController.items.first.name, 'Steel Rod 12mm');
      expect(inventoryController.items.first.currentStock, 100.0);
    });

    test('createParty adds a new party and updates list', () async {
      final success = await inventoryController.createParty(
        name: 'Beta Steels',
        partyCode: 'PRT_002',
        phoneNumber: '9123456789',
      );

      expect(success, isTrue);
      expect(mockInvRepo.parties.length, 2);
      expect(mockInvRepo.parties.any((p) => p.name == 'Beta Steels'), isTrue);
    });

    test('createPurchaseType adds a new purchase type', () async {
      final success = await inventoryController.createPurchaseType(
        name: 'Interstate Purchase',
        code: 'INTERSTATE',
      );

      expect(success, isTrue);
      expect(mockInvRepo.purchaseTypes.length, 2);
      expect(mockInvRepo.purchaseTypes.any((t) => t.name == 'Interstate Purchase'), isTrue);
    });

    test('createItemGroup adds a new item group', () async {
      final success = await inventoryController.createItemGroup(
        name: 'Finished Goods',
        code: 'FINISHED',
        description: 'Complete manufactured goods',
      );

      expect(success, isTrue);
      expect(mockInvRepo.itemGroups.length, 2);
      expect(mockInvRepo.itemGroups.any((g) => g.name == 'Finished Goods'), isTrue);
    });

    test('updateItemGroup modifies item group details', () async {
      final success = await inventoryController.updateItemGroup(
        'g1',
        name: 'Raw Materials & Supplies',
        code: 'RAW_MAT',
      );

      expect(success, isTrue);
      final updated = mockInvRepo.itemGroups.firstWhere((g) => g.id == 'g1');
      expect(updated.name, 'Raw Materials & Supplies');
      expect(updated.code, 'RAW_MAT');
    });

    test('deleteItemGroup removes item group', () async {
      final success = await inventoryController.deleteItemGroup('g1');

      expect(success, isTrue);
      expect(mockInvRepo.itemGroups.any((g) => g.id == 'g1'), isFalse);
    });

    test('createUom adds a new unit of measurement', () async {
      final success = await inventoryController.createUom(
        name: 'Meters',
        symbol: 'MTR',
      );

      expect(success, isTrue);
      expect(mockInvRepo.uoms.length, 3);
      expect(mockInvRepo.uoms.any((u) => u.symbol == 'MTR'), isTrue);
    });

    test('createPerUnit adds a new per unit', () async {
      final success = await inventoryController.createPerUnit(
        name: 'per 100 Pcs',
        symbol: '100pcs',
        multiplier: 100.0,
      );

      expect(success, isTrue);
      expect(mockInvRepo.perUnits.length, 2);
      expect(mockInvRepo.perUnits.any((p) => p.symbol == '100pcs'), isTrue);
    });

    test('createItem adds a new item with default UOM, Per, ItemGroup and Opening stock', () async {
      final success = await inventoryController.createItem(
        name: 'Iron Angle 50mm',
        itemCode: 'ITM_002',
        itemGroupId: 'g1',
        defaultUomId: 'u1',
        defaultPerId: 'pu1',
        standardRate: 60.0,
        openingStock: 250.0,
      );

      expect(success, isTrue);
      expect(mockInvRepo.items.length, 2);
      final created = mockInvRepo.items.firstWhere((i) => i.itemCode == 'ITM_002');
      expect(created.name, 'Iron Angle 50mm');
      expect(created.itemGroupId, 'g1');
      expect(created.currentStock, 250.0);
    });
  });

  group('PurchaseController & Stock Reflection Tests', () {
    test('createPurchase sends raw input to backend and creates purchase entry', () async {
      final now = DateTime.now();
      final success = await purchaseController.createPurchase(
        date: now,
        partyId: 'p1',
        purchaseTypeId: 't1',
        companyGodownId: 'gd1',
        itemId: 'i1',
        uomId: 'u1',
        actualQuantity: 50.0,
        billedQuantity: 48.0,
        rate: 55.0,
        perId: 'pu1',
        godownId: 'gd1',
        notes: 'Invoice #101',
      );

      expect(success, isTrue);
      expect(purchaseController.purchases.length, 1);
      final created = purchaseController.purchases.first;
      expect(created.purchaseNumber, 'PUR_0001');
      expect(created.actualQuantity, 50.0);
      expect(created.billedQuantity, 48.0);
      expect(created.rate, 55.0);
      expect(created.godownId, 'gd1');
      expect(created.godownName, 'Main Central Godown');
      // Backend calculated amount: 48 * 55 = 2640.0
      expect(created.amount, 2640.0);
    });

    test('createPurchase with multiple items and uomQuantity creates tabular items entry with individual assigned godowns', () async {
      final now = DateTime.now();
      final items = [
        const PurchaseItemInput(
          itemId: 'i1',
          godownId: 'gd1',
          uomId: 'u1',
          uomQuantity: 10.0,
          actualQuantity: 100.0,
          billedQuantity: 95.0,
          rate: 50.0,
          perId: 'pu1',
        ),
        const PurchaseItemInput(
          itemId: 'i2',
          godownId: 'gd2',
          uomId: 'u2',
          uomQuantity: 5.0,
          actualQuantity: 50.0,
          billedQuantity: 50.0,
          rate: 80.0,
          perId: 'pu2',
        ),
      ];

      final success = await purchaseController.createPurchase(
        date: now,
        partyId: 'p1',
        purchaseTypeId: 't1',
        companyGodownId: 'gd1',
        godownId: 'gd1',
        items: items,
        notes: 'Multi-item invoice',
      );

      expect(success, isTrue);
      expect(purchaseController.purchases.length, 1);
      final created = purchaseController.purchases.first;
      expect(created.items.length, 2);
      expect(created.items[0].godownId, 'gd1');
      expect(created.items[0].uomQuantity, 10.0);
      expect(created.items[0].actualQuantity, 100.0);
      expect(created.items[0].amount, 95.0 * 50.0);
      expect(created.items[1].godownId, 'gd2');
      expect(created.items[1].uomQuantity, 5.0);
      expect(created.items[1].actualQuantity, 50.0);
      expect(created.items[1].amount, 50.0 * 80.0);
      expect(created.totalActualQuantity, 150.0);
      expect(created.totalBilledQuantity, 145.0);
      expect(created.totalAmount, (95.0 * 50.0) + (50.0 * 80.0));
      expect(created.godownId, 'gd1');
    });

    test('deletePurchase removes entry from purchases', () async {
      await purchaseController.createPurchase(
        date: DateTime.now(),
        partyId: 'p1',
        purchaseTypeId: 't1',
        companyGodownId: 'gd1',
        itemId: 'i1',
        uomId: 'u1',
        actualQuantity: 20.0,
        billedQuantity: 20.0,
        rate: 50.0,
        perId: 'pu1',
        godownId: 'gd1',
      );

      expect(purchaseController.purchases.length, 1);
      final id = purchaseController.purchases.first.id;

      final deleted = await purchaseController.deletePurchase(id);
      expect(deleted, isTrue);
      expect(purchaseController.purchases.isEmpty, isTrue);
    });

    test('InventoryController masters contains accessible godowns for delivered selection', () async {
      await inventoryController.fetchMasters();
      expect(inventoryController.godowns.isNotEmpty, isTrue);
      expect(inventoryController.godowns.first.id, 'gd1');
      expect(inventoryController.godowns.first.name, 'Main Central Godown');
      expect(inventoryController.godowns.first.godownId, 'GD_01');
    });

    test('PurchaseModel serialization includes godownId in toCreatePayload', () {
      final payload = PurchaseModel.toCreatePayload(
        date: DateTime(2026, 11, 19),
        partyId: 'p1',
        purchaseTypeId: 't1',
        companyGodownId: 'gd1',
        itemId: 'i1',
        uomId: 'u1',
        actualQuantity: 100.0,
        billedQuantity: 100.0,
        rate: 55.0,
        perId: 'pu1',
        godownId: 'gd1',
        notes: 'Delivered to main godown',
      );

      expect(payload['godownId'], 'gd1');
      expect(payload['companyGodownId'], 'gd1');
      expect(payload['partyId'], 'p1');
      expect(payload['actualQuantity'], 100.0);
    });
  });

  group('Widget UI Flow Tests for Purchase and Master selection', () {
    testWidgets('AccountInventoryPage renders all master sub tabs and switches cleanly', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AccountInventoryPage(controller: inventoryController),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account & Inventory Info'), findsOneWidget);
      expect(find.text('Parties'), findsWidgets);
      expect(find.text('Purchase Types'), findsOneWidget);
      expect(find.text('Item Groups'), findsOneWidget);
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Units (UOM)'), findsOneWidget);
      expect(find.text('Per Units'), findsOneWidget);

      // Verify Party table displays party
      expect(find.text('Alpha Steel Corp'), findsOneWidget);

      // Switch to Item Groups sub-tab
      await tester.tap(find.text('Item Groups'));
      await tester.pumpAndSettle();

      // Verify Item Group table displays group
      expect(find.text('Raw Material'), findsOneWidget);

      // Switch to Items sub-tab
      await tester.tap(find.text('Items'));
      await tester.pumpAndSettle();

      // Verify Item table displays item, stock and group
      expect(find.text('Steel Rod 12mm'), findsOneWidget);
      expect(find.text('100.00 KGS'), findsOneWidget);
      expect(find.text('Raw Material'), findsOneWidget);
    });

    testWidgets('PurchaseManagementPage renders purchase UI and opens PurchaseEntryDialog', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PurchaseManagementPage(
              purchaseController: purchaseController,
              inventoryController: inventoryController,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Purchase Entries'), findsOneWidget);
      expect(find.text('New Purchase Entry'), findsOneWidget);

      // Tap on New Purchase Entry
      await tester.tap(find.text('New Purchase Entry'));
      await tester.pumpAndSettle();

      // Verify PurchaseEntryDialog is open with dynamic master dropdowns, individual item godowns, and GST controls
      expect(find.byType(PurchaseEntryDialog), findsOneWidget);
      expect(find.text('Company Godown *'), findsOneWidget);
      expect(find.text('Party / Supplier Name *'), findsOneWidget);
      expect(find.text('Purchase Type *'), findsOneWidget);
      expect(find.text('Item Name *'), findsOneWidget);
      expect(find.text('DC # *'), findsOneWidget);
      expect(find.text('Delivered Godown *'), findsOneWidget);
      expect(find.text('UOM *'), findsOneWidget);
      expect(find.text('Actual Qty *'), findsOneWidget);
      expect(find.text('Billed Qty *'), findsOneWidget);
      expect(find.text('Rate (₹) *'), findsOneWidget);
      expect(find.text('Per *'), findsOneWidget);
      expect(find.text('Apply GST / Tax Invoice'), findsOneWidget);
      expect(find.text('Items Subtotal'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
    });

    test('Purchase with GST enabled calculates subtotal + GST percentage', () async {
      final purchaseWithGst = await purchaseController.createPurchase(
        date: DateTime.now(),
        partyId: 'p1',
        purchaseTypeId: 't1',
        companyGodownId: 'gd1',
        items: [
          PurchaseItemInput(
            itemId: 'i1',
            godownId: 'gd1',
            uomId: 'u1',
            uomQuantity: 10,
            actualQuantity: 10,
            billedQuantity: 10,
            rate: 100, // 10 * 100 = 1000
            perId: 'pu1',
          ),
        ],
        isGstBill: true,
        gstPercentage: 18.0,
      );
      expect(purchaseWithGst, isTrue);
      expect(purchaseController.purchases.isNotEmpty, isTrue);
      final last = purchaseController.purchases.last;
      expect(last.isGstBill, isTrue);
      expect(last.subTotal, 1000.0);
      expect(last.gstAmount, 180.0);
      expect(last.totalAmount, 1180.0);
    });

    test('Purchase update modifies purchase and recalculates GST', () async {
      await purchaseController.createPurchase(
        date: DateTime.now(),
        partyId: 'p1',
        purchaseTypeId: 't1',
        companyGodownId: 'gd1',
        items: [
          PurchaseItemInput(
            itemId: 'i1',
            godownId: 'gd1',
            uomId: 'u1',
            uomQuantity: 10,
            actualQuantity: 10,
            billedQuantity: 10,
            rate: 50,
            perId: 'pu1',
          ),
        ],
        isGstBill: true,
        gstPercentage: 18.0,
      );

      final purchase = purchaseController.purchases.first;
      final updated = await purchaseController.updatePurchase(
        id: purchase.id,
        partyId: 'p1',
        purchaseTypeId: 't1',
        items: [
          PurchaseItemInput(
            itemId: 'i1',
            godownId: 'gd1',
            uomId: 'u1',
            uomQuantity: 20,
            actualQuantity: 20,
            billedQuantity: 20,
            rate: 100, // 20 * 100 = 2000
            perId: 'pu1',
          ),
        ],
        isGstBill: false,
      );
      expect(updated, isTrue);
      final edited = purchaseController.purchases.firstWhere((p) => p.id == purchase.id);
      expect(edited.isGstBill, isFalse);
      expect(edited.subTotal, 2000.0);
      expect(edited.totalAmount, 2000.0);
    });
  });
}
