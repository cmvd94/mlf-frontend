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
import 'package:mlf_frontend/features/inventory/domain/entities/item_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/uom_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/per_unit_entity.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/stock_transfer/data/models/available_stock_model.dart';
import 'package:mlf_frontend/features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/available_stock_entity.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/stock_transfer_entity.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/controllers/stock_transfer_controller.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/pages/stock_transfer_page.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/widgets/stock_transfer_entry_dialog.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/widgets/stock_transfer_detail_dialog.dart';
import 'godown_test.dart';
import 'mocks/mock_inventory_purchase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sl = ServiceLocator.instance;

  late MockStockTransferRepository transferRepo;
  late MockInventoryRepository inventoryRepo;
  late MockGodownRepository godownRepo;

  setUp(() {
    sl.reset();

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
      const GodownEntity(
        id: 'gd_02',
        godownId: 'GDN_02',
        name: 'Shivamurugan Processing Godown',
        country: 'India',
        zone: 'South',
        state: 'Tamil Nadu',
        district: 'Tirupur',
        pincode: '641601',
        type: GodownType.jobworkGodown,
        isActive: true,
      ),
    ];

    sl.register<GodownController>(GodownController(
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
    inventoryRepo.uoms = [const UomEntity(id: 'uom_1', name: 'Kilograms', symbol: 'KG')];
    inventoryRepo.perUnits = [const PerUnitEntity(id: 'per_1', name: 'Per Kg', symbol: 'KG', multiplier: 1.0)];
    inventoryRepo.items = [
      const ItemEntity(
        id: 'itm_1',
        name: '20s Combed VL',
        itemCode: 'YRN_20S',
        defaultUomId: 'uom_1',
        defaultPerId: 'per_1',
        standardRate: 250.0,
      ),
      const ItemEntity(
        id: 'itm_2',
        name: 'Grey Knitted Single Jersey Fabric',
        itemCode: 'FBR_SJ01',
        defaultUomId: 'uom_1',
        defaultPerId: 'per_1',
        standardRate: 320.0,
      ),
    ];
    sl.register<InventoryController>(InventoryController(repository: inventoryRepo));

    transferRepo = MockStockTransferRepository();
    transferRepo.availableStocks = [
      const AvailableStockEntity(
        godownStockId: 'stk_001',
        godownId: 'gd_01',
        godownName: 'Main Storage Godown',
        itemId: 'itm_1',
        itemName: '20s Combed VL',
        batchNo: 'Dc174/7-10-26',
        currentStock: 500.0,
        rate: 250.0,
        amount: 125000.0,
        uomSymbol: 'KG',
      ),
    ];

    sl.register<StockTransferController>(StockTransferController(repository: transferRepo));
  });

  group('Stock Transfer Entity & Model serialization tests', () {
    test('AvailableStockModel parses JSON correctly', () {
      final json = {
        'godownStockId': 'stk_123',
        'godownId': 'gd_1',
        'godownName': 'Main Godown',
        'companyGodownId': 'gd_comp_1',
        'companyGodownName': 'Central Godown',
        'itemId': 'itm_1',
        'itemName': 'Cotton Yarn',
        'dcNo': 'DC10',
        'lotNo': 'L2',
        'currentStock': 600,
        'rate': 150.0,
        'amount': 30000.0,
        'uomSymbol': 'BAG',
        'uomQuantity': 20,
        'perSymbol': 'kg',
      };

      final model = AvailableStockModel.fromJson(json);
      expect(model.godownStockId, 'stk_123');
      expect(model.companyGodownId, 'gd_comp_1');
      expect(model.companyGodownName, 'Central Godown');
      expect(model.itemName, 'Cotton Yarn');
      expect(model.dcNo, 'DC10');
      expect(model.lotNo, 'L2');
      expect(model.currentStock, 600.0);
      expect(model.uomQuantity, 20.0);
      expect(model.perSymbol, 'kg');
      expect(model.displayName, contains('Cotton Yarn'));
      expect(model.displayName, contains('DC: DC10'));
      expect(model.displayName, contains('Lot: L2'));
      expect(model.displayName, contains('20 BAG | 600 kg'));
    });

    test('CreateStockTransferSourceInput includes uomQuantity and perId in toJson', () {
      const input = CreateStockTransferSourceInput(
        godownStockId: 'stk_123',
        uomQuantity: 5.0,
        quantity: 150.0,
        perId: 'per_1',
      );
      final json = input.toJson();
      expect(json['godownStockId'], 'stk_123');
      expect(json['uomQuantity'], 5.0);
      expect(json['quantity'], 150.0);
      expect(json['perId'], 'per_1');
    });

    test('StockTransferModel parses voucher JSON correctly with perId and pairs', () {
      final json = {
        '_id': 'st_123',
        'transferNumber': 'ST_0001',
        'date': '2026-11-20T10:00:00.000Z',
        'sourceItems': [
          {
            'godownStockId': 'stk_001',
            'itemId': {'_id': 'itm_1', 'name': '20s Combed VL', 'itemCode': 'YRN_20S'},
            'godownId': {'_id': 'gd_01', 'name': 'Main Godown'},
            'dcNo': '3',
            'lotNo': 'y2',
            'uomQuantity': 20,
            'quantity': 600,
            'rate': 250,
            'amount': 25000,
            'uomId': {'_id': 'uom_1', 'symbol': 'BAG'},
            'perId': {'_id': 'per_1', 'name': 'Per Kg', 'symbol': 'kg'},
          }
        ],
        'destinationItems': [
          {
            'itemId': {'_id': 'itm_2', 'name': 'Grey Knitted Fabric', 'itemCode': 'FBR_01'},
            'godownId': {'_id': 'gd_02', 'name': 'Shivamurugan'},
            'dcNo': 'dc5',
            'lotNo': 'y2',
            'uomQuantity': 10,
            'quantity': 600,
            'rate': 280,
            'amount': 26600,
            'uomId': {'_id': 'uom_1', 'symbol': 'BAG'},
            'perId': {'_id': 'per_1', 'name': 'Per Kg', 'symbol': 'kg'},
          }
        ],
        'totalSourceQuantity': 600,
        'totalSourceAmount': 0,
        'totalDestinationQuantity': 600,
        'totalDestinationAmount': 0,
        'narration': 'Yarn issued to jobwork for knitting',
        'createdBy': {'name': 'Vishnudas'},
      };

      final model = StockTransferModel.fromJson(json);
      expect(model.transferNumber, 'ST_0001');
      expect(model.sourceItems.length, 1);
      expect(model.sourceItems.first.dcNo, '3');
      expect(model.sourceItems.first.lotNo, 'y2');
      expect(model.sourceItems.first.uomQuantity, 20.0);
      expect(model.sourceItems.first.uomSymbol, 'BAG');
      expect(model.sourceItems.first.quantity, 600.0);
      expect(model.sourceItems.first.perSymbol, 'kg');

      expect(model.destinationItems.first.dcNo, 'dc5');
      expect(model.destinationItems.first.lotNo, 'y2');
      expect(model.destinationItems.first.uomQuantity, 10.0);
      expect(model.destinationItems.first.uomSymbol, 'BAG');
      expect(model.destinationItems.first.quantity, 600.0);
      expect(model.destinationItems.first.perSymbol, 'kg');
      expect(model.totalSourceQuantity, 600.0);
      expect(model.totalDestinationQuantity, 600.0);
      expect(model.narration, 'Yarn issued to jobwork for knitting');
    });

    test('StockTransferModel deserializes cleanly without amount fields (pure stock mode)', () {
      final json = {
        '_id': 'st_002',
        'transferNumber': 'ST_0002',
        'date': '2026-11-21T00:00:00.000Z',
        'sourceItems': [
          {
            'godownStockId': 'gs_1',
            'itemId': {'_id': 'itm_1', 'name': 'Cotton Yarn 30s', 'itemCode': 'YRN_30'},
            'godownId': {'_id': 'gd_01', 'name': 'Main Godown'},
            'batchNo': 'Dc174/7-10-26',
            'quantity': 100,
            'uomSymbol': 'KG',
          }
        ],
        'destinationItems': [
          {
            'itemId': {'_id': 'itm_2', 'name': 'Grey Knitted Fabric', 'itemCode': 'FBR_01'},
            'godownId': {'_id': 'gd_02', 'name': 'Shivamurugan'},
            'batchNo': 'FAB_LOT_99',
            'quantity': 95,
            'uomSymbol': 'KG',
          }
        ],
        'totalSourceQuantity': 100,
        'totalDestinationQuantity': 95,
        'narration': 'Pure stock transfer without amount storage',
      };

      final model = StockTransferModel.fromJson(json);
      expect(model.transferNumber, 'ST_0002');
      expect(model.totalSourceQuantity, 100.0);
      expect(model.totalDestinationQuantity, 95.0);
      expect(model.totalSourceAmount, 0.0);
      expect(model.totalDestinationAmount, 0.0);
      expect(model.sourceItems.first.amount, 0.0);
      expect(model.destinationItems.first.amount, 0.0);
    });
  });

  group('StockTransferController unit tests', () {
    test('fetchAvailableStocks populates controller available stocks', () async {
      final ctrl = sl.get<StockTransferController>();
      await ctrl.fetchAvailableStocks();

      expect(ctrl.availableStocks.length, 1);
      expect(ctrl.availableStocks.first.batchNo, 'Dc174/7-10-26');
      expect(ctrl.availableStocks.first.currentStock, 500.0);
    });

    test('createStockTransfer creates voucher, deducts source and records transfer', () async {
      final ctrl = sl.get<StockTransferController>();

      final created = await ctrl.createStockTransfer(
        date: DateTime.now(),
        sourceItems: [
          const CreateStockTransferSourceInput(
            godownStockId: 'stk_001',
            quantity: 100.0,
            rate: 250.0,
          ),
        ],
        destinationItems: [
          const CreateStockTransferDestinationInput(
            itemId: 'itm_2',
            godownId: 'gd_02',
            batchNo: 'FAB_LOT_101',
            quantity: 98.0,
            rate: 270.0,
          ),
        ],
        narration: 'Material issue for knitting process',
      );

      expect(created, true);
      expect(ctrl.transfers.length, 1);
      expect(ctrl.transfers.first.transferNumber, 'ST_0001');
      expect(ctrl.transfers.first.sourceItems.first.quantity, 100.0);
      expect(ctrl.transfers.first.destinationItems.first.batchNo, 'FAB_LOT_101');
      expect(ctrl.transfers.first.destinationItems.first.quantity, 98.0);
    });

    test('updateStockTransfer updates existing voucher successfully', () async {
      final ctrl = sl.get<StockTransferController>();

      await ctrl.createStockTransfer(
        date: DateTime(2026, 11, 20),
        sourceItems: [
          const CreateStockTransferSourceInput(
            godownStockId: 'stk_001',
            quantity: 50.0,
            rate: 250.0,
          ),
        ],
        destinationItems: [
          const CreateStockTransferDestinationInput(
            itemId: 'itm_2',
            godownId: 'gd_02',
            batchNo: 'FAB_LOT_OLD',
            quantity: 48.0,
            rate: 270.0,
          ),
        ],
        narration: 'Original transfer narration',
      );

      final transferId = ctrl.transfers.first.id;

      final updated = await ctrl.updateStockTransfer(
        id: transferId,
        date: DateTime(2026, 11, 21),
        sourceItems: [
          const CreateStockTransferSourceInput(
            godownStockId: 'stk_001',
            quantity: 60.0,
            rate: 250.0,
          ),
        ],
        destinationItems: [
          const CreateStockTransferDestinationInput(
            itemId: 'itm_2',
            godownId: 'gd_02',
            batchNo: 'FAB_LOT_NEW',
            quantity: 58.0,
            rate: 280.0,
          ),
        ],
        narration: 'Updated transfer narration',
      );

      expect(updated, true);
      expect(ctrl.transfers.first.narration, 'Updated transfer narration');
      expect(ctrl.transfers.first.sourceItems.first.quantity, 60.0);
      expect(ctrl.transfers.first.destinationItems.first.batchNo, 'FAB_LOT_NEW');
      expect(ctrl.transfers.first.destinationItems.first.quantity, 58.0);
    });

    test('deleteStockTransfer deletes voucher and refreshes list', () async {
      final ctrl = sl.get<StockTransferController>();

      await ctrl.createStockTransfer(
        date: DateTime(2026, 11, 20),
        sourceItems: [
          const CreateStockTransferSourceInput(
            godownStockId: 'stk_001',
            quantity: 30.0,
            rate: 250.0,
          ),
        ],
        destinationItems: [
          const CreateStockTransferDestinationInput(
            itemId: 'itm_2',
            godownId: 'gd_02',
            batchNo: 'FAB_LOT_DEL',
            quantity: 28.0,
            rate: 270.0,
          ),
        ],
        narration: 'Transfer to be deleted',
      );

      expect(ctrl.transfers.isNotEmpty, true);
      final idToDelete = ctrl.transfers.first.id;

      final deleted = await ctrl.deleteStockTransfer(idToDelete);
      expect(deleted, true);
      expect(ctrl.transfers.isEmpty, true);
    });
  });

  group('StockTransfer UI Widget tests', () {
    testWidgets('StockTransferPage renders header, table and opens Entry dialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const StockTransferPage(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Stock Transfer / Inventory Transfer'), findsOneWidget);
      expect(find.text('New Stock Transfer'), findsOneWidget);

      // Tap New Stock Transfer button
      await tester.tap(find.text('New Stock Transfer'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Check that StockTransferEntryDialog opened
      expect(find.text('Inventory Voucher Creation - Stock Journal'), findsOneWidget);
      expect(find.text('Source (Consumption)'), findsOneWidget);
      expect(find.text('Destination (Production)'), findsOneWidget);
      expect(find.text('Save Stock Transfer'), findsOneWidget);
    });

    testWidgets('StockTransferEntryDialog displays both company and jobwork godowns even if godownController was filtered', (tester) async {
      tester.view.physicalSize = const Size(2200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Simulate godown controller having jobworkGodown filter set from admin page
      final gCtrl = sl.get<GodownController>();
      gCtrl.setTypeFilter(GodownType.jobworkGodown);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: StockTransferEntryDialog(),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap the destination godown dropdown to open options
      final destGodownFinder = find.byWidgetPredicate(
        (w) => w is DropdownButtonFormField<String> &&
               w.decoration.labelText == 'Destination Godown',
      );
      expect(destGodownFinder, findsOneWidget);

      await tester.tap(destGodownFinder);
      await tester.pumpAndSettle();

      // Check both Company Godown and Jobwork Godown appear in the destination list
      expect(find.textContaining('Main Storage Godown (Company)'), findsWidgets);
      expect(find.textContaining('Shivamurugan Processing Godown (Jobwork)'), findsWidgets);
    });

    testWidgets('StockTransferDetailDialog displays voucher breakdown', (tester) async {
      final transfer = StockTransferEntity(
        id: 'st_001',
        transferNumber: 'ST_0149',
        date: DateTime(2026, 11, 20),
        sourceItems: const [
          StockTransferSourceItemEntity(
            godownStockId: 'stk_001',
            itemId: 'itm_1',
            itemName: '20s Combed VL',
            godownId: 'gd_01',
            godownName: 'Main Storage Godown',
            batchNo: 'Dc174/7-10-26',
            quantity: 120.0,
            rate: 250.0,
            amount: 30000.0,
            uomSymbol: 'KG',
          ),
        ],
        destinationItems: const [
          StockTransferDestinationItemEntity(
            itemId: 'itm_2',
            itemName: 'Grey Knitted Single Jersey Fabric',
            godownId: 'gd_02',
            godownName: 'Shivamurugan Godown',
            batchNo: 'FBR_BATCH_149',
            quantity: 115.0,
            rate: 290.0,
            amount: 33350.0,
            uomSymbol: 'KG',
          ),
        ],
        totalSourceQuantity: 120.0,
        totalSourceAmount: 30000.0,
        totalDestinationQuantity: 115.0,
        totalDestinationAmount: 33350.0,
        narration: 'Yarn converted to fabric under stock journal 149',
        createdByName: 'Vishnudas',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StockTransferDetailDialog(transfer: transfer),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Stock Journal: ST_0149'), findsOneWidget);
      expect(find.text('20s Combed VL'), findsOneWidget);
      expect(find.text('DC: Dc174/7-10-26'), findsOneWidget);
      expect(find.text('Grey Knitted Single Jersey Fabric'), findsOneWidget);
      expect(find.text('New DC: FBR_BATCH_149'), findsOneWidget);
      expect(find.text('Yarn converted to fabric under stock journal 149'), findsOneWidget);
    });

    testWidgets('StockTransferPage opens edit dialog when edit button is tapped', (tester) async {
      tester.view.physicalSize = const Size(2200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final ctrl = sl.get<StockTransferController>();
      await ctrl.createStockTransfer(
        date: DateTime(2026, 11, 20),
        sourceItems: [
          const CreateStockTransferSourceInput(
            godownStockId: 'stk_001',
            quantity: 40.0,
            rate: 250.0,
          ),
        ],
        destinationItems: [
          const CreateStockTransferDestinationInput(
            itemId: 'itm_2',
            godownId: 'gd_02',
            batchNo: 'FAB_LOT_EDIT',
            quantity: 38.0,
            rate: 270.0,
          ),
        ],
        narration: 'Voucher before edit',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const StockTransferPage(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byTooltip('Edit Voucher'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit Voucher'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Check edit dialog opened with alteration title and update button
      expect(find.textContaining('Inventory Voucher Alteration'), findsOneWidget);
      expect(find.text('Update Stock Transfer'), findsOneWidget);
    });

    testWidgets('StockTransferPage opens delete dialog and confirms deletion', (tester) async {
      tester.view.physicalSize = const Size(2200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final ctrl = sl.get<StockTransferController>();
      await ctrl.createStockTransfer(
        date: DateTime(2026, 11, 20),
        sourceItems: [
          const CreateStockTransferSourceInput(
            godownStockId: 'stk_001',
            quantity: 25.0,
            rate: 250.0,
          ),
        ],
        destinationItems: [
          const CreateStockTransferDestinationInput(
            itemId: 'itm_2',
            godownId: 'gd_02',
            batchNo: 'FAB_LOT_DEL',
            quantity: 24.0,
            rate: 270.0,
          ),
        ],
        narration: 'Voucher to test delete dialog',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const StockTransferPage(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byTooltip('Delete Voucher'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete Voucher'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Delete Stock Transfer'), findsOneWidget);
      expect(find.text('Delete & Restore Stock'), findsOneWidget);

      await tester.tap(find.text('Delete & Restore Stock'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(ctrl.transfers.isEmpty, true);
    });

    testWidgets('StockTransferDetailDialog triggers onEdit and onDelete callbacks', (tester) async {
      bool editCalled = false;
      bool deleteCalled = false;

      final transfer = StockTransferEntity(
        id: 'st_001',
        transferNumber: 'ST_0001',
        date: DateTime(2026, 11, 20),
        sourceItems: const [],
        destinationItems: const [],
        totalSourceQuantity: 0,
        totalSourceAmount: 0,
        totalDestinationQuantity: 0,
        totalDestinationAmount: 0,
        narration: 'Test voucher',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StockTransferDetailDialog(
              transfer: transfer,
              onEdit: () => editCalled = true,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(editCalled, true);
    });
  });
}
