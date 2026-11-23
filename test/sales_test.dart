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
import 'package:mlf_frontend/features/sales/data/models/sale_model.dart';
import 'package:mlf_frontend/features/sales/domain/entities/sale_entity.dart';
import 'package:mlf_frontend/features/sales/domain/repositories/sales_repository.dart';
import 'package:mlf_frontend/features/sales/presentation/controllers/sales_controller.dart';
import 'package:mlf_frontend/features/sales/presentation/pages/sales_page.dart';
import 'package:mlf_frontend/features/sales/presentation/widgets/sales_detail_dialog.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/available_stock_entity.dart';
import 'godown_test.dart';
import 'mocks/mock_inventory_purchase.dart';

class MockSalesRepository implements SalesRepository {
  List<SaleEntity> sales = [];
  List<AvailableStockEntity> availableStocks = [];

  @override
  Future<({List<SaleEntity> sales, int totalCount, int totalPages, int currentPage})> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? godownId,
    String? fromDate,
    String? toDate,
  }) async {
    return (
      sales: sales,
      totalCount: sales.length,
      totalPages: (sales.length / limit).ceil() == 0 ? 1 : (sales.length / limit).ceil(),
      currentPage: page,
    );
  }

  @override
  Future<SaleEntity> getSaleById(String id) async {
    return sales.firstWhere((s) => s.id == id);
  }

  @override
  Future<SaleEntity> createSale(SaleCreateInput input) async {
    final newItems = input.items.map((i) {
      return SaleItemEntity(
        id: 'sale_item_${DateTime.now().millisecondsSinceEpoch}',
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

    double subTotal = newItems.fold(0.0, (sum, it) => sum + it.amount);
    double gstAmount = input.isGstBill ? (subTotal * (input.gstPercentage ?? 18)) / 100 : 0.0;
    double totalAmount = subTotal + gstAmount;

    final sale = SaleEntity(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      salesNumber: 'SAL_000${sales.length + 1}',
      date: input.date,
      salesTypeId: input.salesTypeId,
      salesTypeName: 'Local Sale',
      salesTypeCode: 'LOCAL',
      partyId: input.partyId,
      partyName: 'ABC Textiles',
      partyCode: 'PTY_ABC',
      dcNo: input.dcNo ?? '',
      companyGodownId: input.companyGodownId ?? 'gd_01',
      companyGodownName: 'Main Storage Godown',
      items: newItems,
      subTotal: subTotal,
      isGstBill: input.isGstBill,
      gstPercentage: input.isGstBill ? (input.gstPercentage ?? 18) : 0.0,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      totalActualQuantity: newItems.fold(0.0, (sum, it) => sum + it.actualQuantity),
      totalBilledQuantity: newItems.fold(0.0, (sum, it) => sum + it.billedQuantity),
      totalQuantity: newItems.fold(0.0, (sum, it) => sum + it.actualQuantity),
      notes: input.notes ?? '',
      narration: input.narration ?? '',
      createdByName: 'Vishnudas',
      createdAt: DateTime.now(),
    );

    sales.add(sale);
    return sale;
  }

  @override
  Future<SaleEntity> updateSale(String id, SaleUpdateInput input) async {
    final idx = sales.indexWhere((s) => s.id == id);
    if (idx == -1) throw Exception('Sale not found');

    final existing = sales[idx];
    final updated = SaleEntity(
      id: existing.id,
      salesNumber: existing.salesNumber,
      date: input.date ?? existing.date,
      salesTypeId: input.salesTypeId ?? existing.salesTypeId,
      salesTypeName: existing.salesTypeName,
      salesTypeCode: existing.salesTypeCode,
      partyId: input.partyId ?? existing.partyId,
      partyName: existing.partyName,
      partyCode: existing.partyCode,
      dcNo: input.dcNo ?? existing.dcNo,
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

    sales[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteSale(String id) async {
    sales.removeWhere((s) => s.id == id);
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locator = ServiceLocator.instance;

  late MockSalesRepository salesRepo;
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
    inventoryRepo.uoms = [const UomEntity(id: 'uom_1', name: 'Kilograms', symbol: 'KG')];
    inventoryRepo.perUnits = [const PerUnitEntity(id: 'per_1', name: 'Kilogram', symbol: 'KG', multiplier: 1)];

    locator.register<InventoryController>(InventoryController(repository: inventoryRepo));

    salesRepo = MockSalesRepository();
    salesRepo.availableStocks = [
      const AvailableStockEntity(
        godownStockId: 'stock_doc_123',
        godownId: 'gd_01',
        godownName: 'Main Storage Godown',
        companyGodownId: 'gd_01',
        companyGodownName: 'Main Storage Godown',
        itemId: 'item_1',
        itemName: 'Cotton Yarn 40s',
        itemCode: 'CY40',
        dcNo: 'DC_1001',
        lotNo: 'LOT_A',
        currentStock: 150.0,
        rate: 280.0,
        uomId: 'uom_1',
        uomSymbol: 'KG',
        uomQuantity: 3.0,
        perId: 'per_1',
        perSymbol: 'KG',
      ),
    ];

    locator.register<SalesController>(SalesController(repository: salesRepo));
  });

  group('Sales Entity & Model Tests', () {
    test('SaleModel parses JSON correctly and preserves godownStockId in items', () {
      final json = {
        '_id': 'sale_1',
        'salesNumber': 'SAL_0001',
        'date': '2026-11-22T00:00:00.000Z',
        'partyId': {'_id': 'party_1', 'name': 'ABC Textiles', 'partyCode': 'PTY_ABC'},
        'companyGodownId': {'_id': 'gd_01', 'name': 'Main Storage Godown', 'godownId': 'GDN_01'},
        'items': [
          {
            '_id': 'item_line_1',
            'godownStockId': {'_id': 'stock_doc_123', 'dcNo': 'DC_1001', 'lotNo': 'LOT_A'},
            'itemId': {'_id': 'item_1', 'name': 'Cotton Yarn 40s', 'itemCode': 'CY40'},
            'godownId': {'_id': 'gd_01', 'name': 'Main Storage Godown', 'godownId': 'GDN_01'},
            'companyGodownId': {'_id': 'gd_01', 'name': 'Main Storage Godown'},
            'dcNo': 'DC_1001',
            'lotNo': 'LOT_A',
            'uomId': {'_id': 'uom_1', 'name': 'Kilograms', 'symbol': 'KG'},
            'uomQuantity': 2,
            'quantity': 50.0,
            'rate': 280.0,
            'perId': {'_id': 'per_1', 'name': 'Kilogram', 'symbol': 'KG', 'multiplier': 1},
            'amount': 14000.0,
          }
        ],
        'subTotal': 14000.0,
        'isGstBill': true,
        'gstPercentage': 18.0,
        'gstAmount': 2520.0,
        'totalAmount': 16520.0,
        'totalQuantity': 50.0,
        'narration': 'Test sales invoice',
        'createdBy': {'name': 'Vishnudas'},
      };

      final model = SaleModel.fromJson(json);

      expect(model.id, 'sale_1');
      expect(model.salesNumber, 'SAL_0001');
      expect(model.partyName, 'ABC Textiles');
      expect(model.isGstBill, true);
      expect(model.totalAmount, 16520.0);
      expect(model.items.length, 1);

      final item = model.items.first;
      expect(item.godownStockId, 'stock_doc_123'); // Verified godownStockId stored!
      expect(item.itemName, 'Cotton Yarn 40s');
      expect(item.dcNo, 'DC_1001');
      expect(item.quantity, 50.0);
      expect(item.rate, 280.0);
      expect(item.amount, 14000.0);
    });

    test('SaleItemInput formats JSON payload with godownStockId correctly', () {
      const input = SaleItemInput(
        godownStockId: 'stock_doc_123',
        actualQuantity: 25.0,
        billedQuantity: 25.0,
        rate: 300.0,
        uomQuantity: 1.0,
        uomId: 'uom_1',
        perId: 'per_1',
        dcNo: 'DC_1001',
      );

      final json = input.toJson();
      expect(json['godownStockId'], 'stock_doc_123');
      expect(json['actualQuantity'], 25.0);
      expect(json['billedQuantity'], 25.0);
      expect(json['rate'], 300.0);
      expect(json['dcNo'], 'DC_1001');
    });
  });

  group('SalesController CRUD Tests', () {
    test('createSale creates voucher and fetches list', () async {
      final controller = locator.get<SalesController>();

      final success = await controller.createSale(
        SaleCreateInput(
          date: DateTime(2026, 11, 22),
          salesTypeId: 'st1',
          partyId: 'party_1',
          dcNo: 'DC_1001',
          companyGodownId: 'gd_01',
          items: const [
            SaleItemInput(
              godownStockId: 'stock_doc_123',
              actualQuantity: 20.0,
              billedQuantity: 20.0,
              rate: 280.0,
            ),
          ],
          isGstBill: true,
          gstPercentage: 18.0,
          narration: 'Initial Sale',
        ),
      );

      expect(success, true);
      expect(controller.sales.length, 1);
      expect(controller.sales.first.salesNumber, 'SAL_0001');
      expect(controller.sales.first.items.first.godownStockId, 'stock_doc_123');
      expect(controller.sales.first.subTotal, 5600.0);
      expect(controller.sales.first.totalAmount, 6608.0); // 5600 + 18% GST (1008)
    });

    test('deleteSale removes voucher and updates state', () async {
      final controller = locator.get<SalesController>();

      await controller.createSale(
        SaleCreateInput(
          date: DateTime(2026, 11, 22),
          salesTypeId: 'st1',
          partyId: 'party_1',
          dcNo: 'DC_1001',
          items: const [
            SaleItemInput(
              godownStockId: 'stock_doc_123',
              actualQuantity: 10.0,
              billedQuantity: 10.0,
              rate: 200.0,
            ),
          ],
        ),
      );

      expect(controller.sales.length, 1);
      final saleId = controller.sales.first.id;

      final deleted = await controller.deleteSale(saleId);
      expect(deleted, true);
      expect(controller.sales.isEmpty, true);
    });

    test('fetchAvailableStocks populates stock batch records', () async {
      final controller = locator.get<SalesController>();

      await controller.fetchAvailableStocks();

      expect(controller.availableStocks.length, 1);
      expect(controller.availableStocks.first.godownStockId, 'stock_doc_123');
      expect(controller.availableStocks.first.itemName, 'Cotton Yarn 40s');
      expect(controller.availableStocks.first.currentStock, 150.0);
    });
  });

  group('Sales UI Widget Tests', () {
    testWidgets('SalesPage renders top bar, filters, and empty state', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SalesPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sales Management'), findsOneWidget);
      expect(find.text('New Sale Entry'), findsOneWidget);
      expect(find.text('No Sales Vouchers Found'), findsOneWidget);
    });

    testWidgets('SalesDetailDialog displays voucher header, party, and items table', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final sale = SaleEntity(
        id: 'sale_101',
        salesNumber: 'SAL_0042',
        date: DateTime(2026, 11, 22),
        salesTypeId: 'st1',
        salesTypeName: 'Local Sale',
        partyId: 'party_1',
        partyName: 'ABC Textiles',
        partyCode: 'PTY_ABC',
        dcNo: 'DC_1001',
        companyGodownId: 'gd_01',
        companyGodownName: 'Main Storage Godown',
        items: const [
          SaleItemEntity(
            godownStockId: 'stock_doc_123',
            itemId: 'item_1',
            itemName: 'Cotton Yarn 40s',
            itemCode: 'CY40',
            godownId: 'gd_01',
            godownName: 'Main Storage Godown',
            dcNo: 'DC_1001',
            lotNo: 'LOT_A',
            uomId: 'uom_1',
            uomSymbol: 'KG',
            uomQuantity: 2.0,
            actualQuantity: 50.0,
            billedQuantity: 50.0,
            quantity: 50.0,
            rate: 300.0,
            perId: 'per_1',
            perSymbol: 'KG',
            amount: 15000.0,
          ),
        ],
        subTotal: 15000.0,
        isGstBill: true,
        gstPercentage: 18.0,
        gstAmount: 2700.0,
        totalAmount: 17700.0,
        totalActualQuantity: 50.0,
        totalBilledQuantity: 50.0,
        totalQuantity: 50.0,
        narration: 'Urgent delivery order',
        createdByName: 'Vishnudas',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SalesDetailDialog(sale: sale),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sale Invoice: SAL_0042'), findsOneWidget);
      expect(find.text('ABC Textiles'), findsOneWidget);
      expect(find.text('Sold Items Breakdown'), findsOneWidget);
      expect(find.text('Cotton Yarn 40s\n(CY40)'), findsOneWidget);
      expect(find.text('₹ 17700.00'), findsOneWidget);
    });
  });
}
