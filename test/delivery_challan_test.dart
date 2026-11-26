import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/features/admin/data/models/godown_model.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import 'package:mlf_frontend/features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/stock_transfer_entity.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/widgets/stock_transfer_challan_dialog.dart';

void main() {
  group('Godown Address, GST, and Phone Tests', () {
    test('GodownModel parses and preserves address, gstin, and phoneNumber from JSON', () {
      final json = {
        '_id': 'gd_123',
        'godownId': 'GD_01',
        'name': 'Jobwork Unit Alpha',
        'type': 'jobwork godown',
        'country': 'India',
        'zone': 'SouthZone',
        'state': 'TamilNadu',
        'district': 'Tirupur',
        'pincode': '641604',
        'address': '123 Textile Avenue, Cotton City',
        'gstin': '33AABCT1234A1Z5',
        'phoneNumber': '9876543210',
        'isActive': true,
      };

      final model = GodownModel.fromJson(json);
      expect(model.id, 'gd_123');
      expect(model.name, 'Jobwork Unit Alpha');
      expect(model.type, GodownType.jobworkGodown);
      expect(model.address, '123 Textile Avenue, Cotton City');
      expect(model.gstin, '33AABCT1234A1Z5');
      expect(model.phoneNumber, '9876543210');
    });

    test('GodownModel.toCreatePayload and toUpdatePayload include address, gstin, phoneNumber', () {
      final createPayload = GodownModel.toCreatePayload(
        name: 'Unit Beta',
        type: GodownType.jobworkGodown,
        country: 'India',
        zone: 'SouthZone',
        state: 'TamilNadu',
        district: 'Tirupur',
        pincode: '641604',
        address: '456 Mill Street',
        gstin: '33AABCT9999A1Z9',
        phoneNumber: '9123456780',
      );

      expect(createPayload['address'], '456 Mill Street');
      expect(createPayload['gstin'], '33AABCT9999A1Z9');
      expect(createPayload['phoneNumber'], '9123456780');

      final updatePayload = GodownModel.toUpdatePayload(
        name: 'Unit Beta Updated',
        address: '789 Industrial Park',
        gstin: '33AABCT8888A1Z8',
        phoneNumber: '9000000000',
      );

      expect(updatePayload['address'], '789 Industrial Park');
      expect(updatePayload['gstin'], '33AABCT8888A1Z8');
      expect(updatePayload['phoneNumber'], '9000000000');
    });
  });

  group('StockTransfer isGst and Delivery Challan Tests', () {
    final transferWithGst = StockTransferEntity(
      id: 'st_1',
      transferNumber: 'ST_0001',
      date: DateTime(2026, 11, 25),
      isGst: true,
      narration: 'Transfer for bleaching',
      createdByName: 'Admin User',
      sourceItems: const [
        StockTransferSourceItemEntity(
          godownStockId: 'stk_1',
          itemId: 'itm_1',
          itemName: 'Cotton Yarn 40s',
          godownId: 'gd_source',
          godownName: 'Main Yarn Godown',
          godownAddress: '10 Yarn Street, Tirupur',
          godownGstin: '33AABCM1234A1Z1',
          godownPhone: '9876543210',
          godownState: 'TamilNadu',
          quantity: 50.0,
          rate: 200.0,
          amount: 10000.0,
          uomSymbol: 'Bag',
          uomQuantity: 2.0,
          perSymbol: 'Kg',
        ),
      ],
      destinationItems: const [
        StockTransferDestinationItemEntity(
          itemId: 'itm_2',
          itemName: 'Bleached Yarn 40s',
          godownId: 'gd_dest',
          godownName: 'Shree Krishna Jobwork Unit',
          godownAddress: '42 Bleaching Road, Tirupur - 641602',
          godownGstin: '33XYZPA1234L1ZT',
          godownPhone: '9443322110',
          godownState: 'TamilNadu',
          hsnCode: '5205',
          dcNo: 'DC_8899',
          lotNo: 'LOT_A1',
          quantity: 48.5,
          rate: 220.0,
          amount: 10670.0,
          uomSymbol: 'Bag',
          uomQuantity: 2.0,
          perSymbol: 'Kg',
        ),
      ],
      totalSourceQuantity: 50.0,
      totalDestinationQuantity: 48.5,
      totalDestinationAmount: 10670.0,
    );

    final transferWithoutGst = StockTransferEntity(
      id: 'st_2',
      transferNumber: 'ST_0002',
      date: DateTime(2026, 11, 25),
      isGst: false,
      narration: 'Internal warehouse move',
      createdByName: 'Supervisor',
      sourceItems: const [
        StockTransferSourceItemEntity(
          godownStockId: 'stk_2',
          itemId: 'itm_1',
          itemName: 'Grey Fabric 30s',
          godownId: 'gd_source',
          godownName: 'Godown A',
          quantity: 100.0,
          rate: 150.0,
          amount: 15000.0,
          uomSymbol: 'Box',
          uomQuantity: 5.0,
          perSymbol: 'Mtr',
        ),
      ],
      destinationItems: const [
        StockTransferDestinationItemEntity(
          itemId: 'itm_1',
          itemName: 'Grey Fabric 30s',
          godownId: 'gd_dest2',
          godownName: 'Godown B',
          godownAddress: 'Internal Yard',
          godownState: 'TamilNadu',
          hsnCode: '5208',
          dcNo: 'DC_1001',
          quantity: 100.0,
          rate: 150.0,
          amount: 15000.0,
          uomSymbol: 'Box',
          uomQuantity: 5.0,
          perSymbol: 'Mtr',
        ),
      ],
      totalSourceQuantity: 100.0,
      totalDestinationQuantity: 100.0,
      totalDestinationAmount: 15000.0,
    );

    test('StockTransferModel parses isGst and destination godown address/gstin', () {
      final json = {
        '_id': 'st_99',
        'transferNumber': 'ST_0099',
        'date': '2026-11-25T00:00:00.000Z',
        'isGst': true,
        'sourceItems': [],
        'destinationItems': [
          {
            'itemId': {'_id': 'it_1', 'name': 'Dyed Fabric', 'hsnCode': '5208'},
            'godownId': {
              '_id': 'gd_j1',
              'name': 'Dyeing Mill',
              'address': 'Mill Compound, Tirupur',
              'gstin': '33AABCT0000A1Z1',
              'phoneNumber': '9988776655',
              'state': 'TamilNadu',
            },
            'dcNo': 'DC_55',
            'quantity': 120.0,
            'rate': 250.0,
            'amount': 30000.0,
          }
        ],
        'totalDestinationQuantity': 120.0,
        'totalDestinationAmount': 30000.0,
      };

      final model = StockTransferModel.fromJson(json);
      expect(model.isGst, true);
      expect(model.destinationItems.length, 1);
      final dest = model.destinationItems.first;
      expect(dest.godownName, 'Dyeing Mill');
      expect(dest.godownAddress, 'Mill Compound, Tirupur');
      expect(dest.godownGstin, '33AABCT0000A1Z1');
      expect(dest.godownPhone, '9988776655');
      expect(dest.hsnCode, '5208');
    });

    test('generateHtmlChallan includes company address, GSTIN and jobworker details for GST transfer', () {
      final html = StockTransferChallanDialog.generateHtmlChallan(transferWithGst);
      expect(html, contains('DELIVERY CHALLAN'));
      expect(html, contains('size: 8in 5in;'));
      expect(html, contains('M L FABRIC'));
      expect(html, contains('33AYQPV9246H2ZN')); // Company GSTIN
      expect(html, contains('9626298790')); // Company Phone
      expect(html, contains('Shree Krishna Jobwork Unit')); // Recipient
      expect(html, contains('33XYZPA1234L1ZT')); // Recipient GSTIN
      expect(html, contains('42 Bleaching Road, Tirupur')); // Recipient Address
      expect(html, contains('BLEACHED YARN 40S')); // Item uppercase
      expect(html, contains('5205')); // HSN
      expect(html, contains('>UOM</th>')); // UOM Header
      expect(html, contains('2 Bag')); // UOM quantity + unit
      expect(html, contains('48.50 Kg')); // Qty with per
      expect(html, isNot(contains('<th>DC / Lot #</th>')));
      expect(html, isNot(contains('<th>Rate</th>')));
      expect(html, isNot(contains('<th>Amount</th>')));
      // Check side-by-side layout: info strip present, meta-box removed
      expect(html, contains('challan-info-strip'));
      expect(html, contains('DC No.:'));
      expect(html, contains('Dated:'));
      expect(html, isNot(contains('Challan No.:')));
      expect(html, isNot(contains('Issued under Section')));
      expect(html, contains('CONSIGNOR / DISPATCH FROM :'));
      expect(html, contains('Main Yarn Godown')); // Consignor is source godown
      expect(html, contains('10 Yarn Street, Tirupur')); // Consignor address
      expect(html, contains('33AABCM1234A1Z1')); // Consignor GSTIN
      expect(html, contains('CONSIGNEE / DELIVER TO :'));
      expect(html, isNot(contains('Source Consumption:')));
      expect(html, isNot(contains('meta-box')));
      expect(html, isNot(contains('Mode of Transport')));
      // Check footer: declaration removed, vehicle number in middle, receiver signature on left, M L FABRIC on right
      expect(html, contains('For M L FABRIC'));
      expect(html, contains('Vehicle No. : ________________'));
      expect(html, contains("Receiver's Signature"));
      expect(html, contains("Authorised Signatory"));
      expect(html, isNot(contains('Declaration')));
    });

    testWidgets('StockTransferChallanDialog renders preview with GST details side by side', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockTransferChallanDialog(transfer: transferWithGst),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DELIVERY CHALLAN'), findsOneWidget);
      expect(find.text('Delivery Challan Preview (GST)'), findsOneWidget);
      expect(find.textContaining('DC No.: DC_8899'), findsOneWidget);
      expect(find.textContaining('Challan No.'), findsNothing);
      expect(find.textContaining('Issued under Section'), findsNothing);
      expect(find.text('CONSIGNOR / DISPATCH FROM :'), findsOneWidget);
      expect(find.text('Main Yarn Godown'), findsOneWidget); // Source godown
      expect(find.text('10 Yarn Street, Tirupur'), findsOneWidget); // Source address
      expect(find.textContaining('33AABCM1234A1Z1'), findsOneWidget); // Source GSTIN
      expect(find.text('CONSIGNEE / DELIVER TO :'), findsOneWidget);
      expect(find.text('Source Consumption:'), findsNothing);
      expect(find.text('Rate'), findsNothing);
      expect(find.text('Amount'), findsNothing);
      expect(find.text('DC / Lot #'), findsNothing);
      expect(find.text('UOM'), findsOneWidget);
      expect(find.text('2 Bag'), findsWidgets);
      expect(find.text('48.50 Kg'), findsWidgets);
      expect(find.text('M L FABRIC'), findsOneWidget); // Only top company header
      expect(find.text('For M L FABRIC'), findsOneWidget); // Footer
      expect(find.text('Vehicle No. : ________________'), findsOneWidget);
      expect(find.text("Receiver's Signature"), findsOneWidget);
      expect(find.text("Authorised Signatory"), findsOneWidget);
      expect(find.text('Declaration'), findsNothing);
      expect(find.textContaining('33AYQPV9246H2ZN'), findsNWidgets(1));
      expect(find.text('Shree Krishna Jobwork Unit'), findsOneWidget);
      expect(find.textContaining('33XYZPA1234L1ZT'), findsOneWidget);
      expect(find.textContaining('42 Bleaching Road'), findsOneWidget);
      expect(find.text('Print Challan'), findsOneWidget);
    });

    testWidgets('StockTransferChallanDialog renders preview without GST details', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockTransferChallanDialog(transfer: transferWithoutGst),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DELIVERY CHALLAN'), findsOneWidget);
      expect(find.text('Delivery Challan Preview'), findsOneWidget);
      expect(find.textContaining('DC No.: DC_1001'), findsOneWidget);
      expect(find.textContaining('Challan No.'), findsNothing);
      expect(find.textContaining('Issued under Section'), findsNothing);
      expect(find.text('For M L FABRIC'), findsNothing); // Non-GST footer only has Authorised Signatory
      expect(find.text('Authorised Signatory'), findsOneWidget);
      expect(find.text('Vehicle No. : ________________'), findsOneWidget);
      expect(find.text("Receiver's Signature"), findsOneWidget);
      expect(find.text('Declaration'), findsNothing);
      expect(find.text('Source Consumption:'), findsNothing);
      expect(find.text('UOM'), findsOneWidget);
      expect(find.text('5 Box'), findsWidgets);
      expect(find.text('100 Mtr'), findsWidgets);
      expect(find.text('Rate'), findsNothing);
      expect(find.text('Amount'), findsNothing);
      expect(find.text('DC / Lot #'), findsNothing);
      expect(find.text('Godown A'), findsOneWidget);
      expect(find.text('Godown B'), findsOneWidget);
      expect(find.text('Print Challan'), findsOneWidget);
    });
  });
}
