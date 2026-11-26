import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/bill_print_helper.dart';
import '../../domain/entities/stock_transfer_entity.dart';

class StockTransferChallanDialog extends StatelessWidget {
  final StockTransferEntity transfer;

  const StockTransferChallanDialog({super.key, required this.transfer});

  // Company defaults
  static const String companyName = 'M L FABRIC';
  static const String companyAddress = '22/24 ELANGO NAGAR,3RD CROSS STREET,S.V.COLONY\nTirupur -641604';
  static const String companyGstin = '33AYQPV9246H2ZN';
  static const String companyPhone = '9626298790';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 8 : 24,
      ),
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Action Bar
              _buildTopBar(context),
              const Divider(height: 1, thickness: 1),

              // Printable Challan Sheet Container
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  padding: EdgeInsets.all(isMobile ? 8 : 16),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 780),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: _buildChallanDocument(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              transfer.isGst ? 'Delivery Challan Preview (GST)' : 'Delivery Challan Preview',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Print Challan'),
            onPressed: () => _printDocument(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _printDocument() {
    final html = generateHtmlChallan(transfer);
    BillPrintHelper.printBill(html);
  }

  Widget _buildChallanDocument() {
    final localDate = transfer.date.toLocal();
    final dateStr = '${localDate.day}/${localDate.month}/${localDate.year}';
    final isTax = transfer.isGst;

    final destItem = transfer.destinationItems.isNotEmpty ? transfer.destinationItems.first : null;
    final sourceItem = transfer.sourceItems.isNotEmpty ? transfer.sourceItems.first : null;

    final destGodownName = destItem?.godownName.isNotEmpty == true
        ? destItem!.godownName
        : 'Destination Godown';
    final destAddress = destItem?.godownAddress ?? '';
    final destGstin = destItem?.godownGstin ?? '';
    final destPhone = destItem?.godownPhone ?? '';
    final destState = destItem?.godownState.isNotEmpty == true
        ? destItem!.godownState.toUpperCase()
        : 'TAMILNADU';

    final sourceGodownName = sourceItem?.godownName.isNotEmpty == true
        ? sourceItem!.godownName
        : 'Source Godown';
    final sourceAddress = sourceItem?.godownAddress ?? '';
    final sourceGstin = sourceItem?.godownGstin ?? '';
    final sourcePhone = sourceItem?.godownPhone ?? '';
    final sourceState = sourceItem?.godownState.isNotEmpty == true
        ? sourceItem!.godownState.toUpperCase()
        : 'TAMILNADU';

    final challanNo = transfer.transferNumber;
    final dcNo = destItem?.dcNo.isNotEmpty == true ? destItem!.dcNo : (sourceItem?.dcNo ?? '');

    // Items list (destination items transferred)
    final itemsList = transfer.destinationItems.isNotEmpty
        ? transfer.destinationItems
        : transfer.sourceItems;

    double totalUomQty = 0;
    double totalQty = 0;
    for (final it in itemsList) {
      if (it is StockTransferDestinationItemEntity) {
        totalQty += it.quantity;
        if (it.uomQuantity > 0) totalUomQty += it.uomQuantity;
      } else if (it is StockTransferSourceItemEntity) {
        totalQty += it.quantity;
        if (it.uomQuantity > 0) totalUomQty += it.uomQuantity;
      }
    }

    final primaryUom = itemsList
        .map((it) {
          if (it is StockTransferDestinationItemEntity) return it.uomSymbol.trim();
          if (it is StockTransferSourceItemEntity) return it.uomSymbol.trim();
          return '';
        })
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    final primaryPer = itemsList
        .map((it) {
          if (it is StockTransferDestinationItemEntity) {
            return it.perSymbol.isNotEmpty ? it.perSymbol : it.perName;
          }
          if (it is StockTransferSourceItemEntity) {
            return it.perSymbol.isNotEmpty ? it.perSymbol : it.perName;
          }
          return '';
        })
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    final totalQtyNum = totalQty % 1 == 0 ? totalQty.toInt().toString() : totalQty.toStringAsFixed(2);
    final totalQtyDisplay = primaryPer.isNotEmpty ? '$totalQtyNum $primaryPer' : totalQtyNum;
    final totalUomQtyFormatted = totalUomQty > 0
        ? (totalUomQty % 1 == 0 ? totalUomQty.toInt().toString() : totalUomQty.toStringAsFixed(2))
        : '';
    final totalUomDisplay = totalUomQtyFormatted.isNotEmpty
        ? (primaryUom.isNotEmpty ? '$totalUomQtyFormatted $primaryUom' : totalUomQtyFormatted)
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: Column(
            children: [
              if (isTax) ...[
                const Text(
                  companyName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '22/24 ELANGO NAGAR,3RD CROSS STREET,S.V.COLONY, Tirupur -641604',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, height: 1.25, color: Colors.black),
                ),
                const SizedBox(height: 2),
                const Text(
                  'GSTIN: $companyGstin | Phone: $companyPhone',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 6),
              ] else ...[
                const SizedBox(height: 48),
              ],
              const Text(
                'DELIVERY CHALLAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // Compact Info Strip (DC No on left, Dated on right)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DC No.: $dcNo',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                'Dated: $dateStr',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),

        // Consignor & Consignee (Dispatch From and Delivery To Side-by-Side)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Consignor (Dispatch From)
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 1.2),
                      bottom: BorderSide(color: Colors.black, width: 1.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONSIGNOR / DISPATCH FROM :',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sourceGodownName,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      if (sourceAddress.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          sourceAddress,
                          style: const TextStyle(fontSize: 9.5, height: 1.2, color: Colors.black),
                        ),
                      ],
                      const SizedBox(height: 1),
                      Text(
                        'STATE: $sourceState',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                      if (isTax && sourceGstin.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          'GSTIN/UIN : $sourceGstin',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                      if (isTax && sourcePhone.isNotEmpty)
                        Text(
                          'Phone: $sourcePhone',
                          style: const TextStyle(fontSize: 9.5, color: Colors.black),
                        ),
                    ],
                  ),
                ),
              ),

              // Consignee (Deliver To)
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONSIGNEE / DELIVER TO :',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        destGodownName,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      if (destAddress.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          destAddress,
                          style: const TextStyle(fontSize: 9.5, height: 1.2, color: Colors.black),
                        ),
                      ],
                      const SizedBox(height: 1),
                      Text(
                        'STATE: $destState',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                      if (isTax && destGstin.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          'GSTIN/UIN : $destGstin',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                      if (isTax && destPhone.isNotEmpty)
                        Text(
                          'Phone: $destPhone',
                          style: const TextStyle(fontSize: 9.5, color: Colors.black),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Items Table Header
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: Row(
            children: [
              _buildColHeader('Sl\nNo.', width: 36, align: TextAlign.center),
              _buildColHeader('Description of Goods', flex: 6, align: TextAlign.left),
              _buildColHeader('HSN/SAC', width: 100, align: TextAlign.center),
              _buildColHeader('UOM', width: 100, align: TextAlign.right),
              _buildColHeader('Quantity', width: 120, align: TextAlign.right, isLast: true),
            ],
          ),
        ),

        // Items Lines
        ...itemsList.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final dynamic item = entry.value;

          final String itemName = item.itemName ?? 'Item';
          final String hsnCode = item.hsnCode ?? '-';
          final double qty = item.quantity ?? 0.0;
          final double uomQty = item.uomQuantity ?? 0.0;
          final String uomSym = (item.uomSymbol ?? '').toString().trim();
          final String uomQtyFormatted = uomQty > 0
              ? (uomQty % 1 == 0 ? uomQty.toInt().toString() : uomQty.toStringAsFixed(2))
              : '';
          final String uomValue = uomQtyFormatted.isNotEmpty
              ? (uomSym.isNotEmpty ? '$uomQtyFormatted $uomSym' : uomQtyFormatted)
              : '-';
          final String perSym = (item.perSymbol != null && item.perSymbol.isNotEmpty)
              ? item.perSymbol
              : (item.perName ?? '');
          final String qtyNum = qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
          final String qtyDisplay = perSym.isNotEmpty ? '$qtyNum $perSym' : qtyNum;

          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCell(idx.toString(), width: 36, align: TextAlign.center, isBold: true, fontSize: 11),
                _buildCell(itemName.toUpperCase(), flex: 6, align: TextAlign.left, isBold: true, fontSize: 11),
                _buildCell(hsnCode.isNotEmpty ? hsnCode : '-', width: 100, align: TextAlign.center, isBold: true, fontSize: 11),
                _buildCell(uomValue, width: 100, align: TextAlign.right, isBold: true, fontSize: 11),
                _buildCell(qtyDisplay, width: 120, align: TextAlign.right, isBold: true, fontSize: 11, isLast: true),
              ],
            ),
          );
        }),

        // Spacing if fewer than 5 rows
        if (itemsList.length < 5)
          Container(
            height: (5 - itemsList.length) * 26.0,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.transparent)),
            ),
          ),

        // Grand Total Row
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black, width: 1.2),
              bottom: BorderSide(color: Colors.black, width: 1.2),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 36),
              const Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text(
                    'Total',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 100), // HSN spacer
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  totalUomDisplay,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Container(
                width: 120,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  totalQtyDisplay,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),

        // Narration if present
        if (transfer.narration.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12, width: 0.8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Narration: ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black)),
                Expanded(
                  child: Text(transfer.narration, style: const TextStyle(fontSize: 9.5, color: Colors.black87)),
                ),
              ],
            ),
          ),

        // Signatures & Vehicle Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Receiver's Signature
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    SizedBox(height: 28),
                    Text(
                      'Receiver\'s Signature',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Middle: Vehicle Number
              Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text(
                    'Vehicle No. : ________________',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),

              // Right: Authorised Signatory (with 'For M L FABRIC' if isTax)
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isTax) ...[
                      const Text(
                        'For $companyName',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 18),
                    ] else ...[
                      const SizedBox(height: 28),
                    ],
                    const Text(
                      'Authorised Signatory',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColHeader(String text, {double? width, int? flex, TextAlign align = TextAlign.left, bool isLast = false}) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: isLast ? 0 : 0.8)),
      ),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );

    return width != null ? SizedBox(width: width, child: child) : Expanded(flex: flex ?? 1, child: child);
  }

  Widget _buildCell(
    String text, {
    double? width,
    int? flex,
    TextAlign align = TextAlign.left,
    bool isLast = false,
    bool isBold = false,
    double fontSize = 11.0,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: isLast ? 0 : 0.8)),
      ),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );

    return width != null ? SizedBox(width: width, child: child) : Expanded(flex: flex ?? 1, child: child);
  }

  /// Clean HTML document generation matching the exact delivery challan layout
  static String generateHtmlChallan(StockTransferEntity transfer) {
    final localDate = transfer.date.toLocal();
    final dateStr = '${localDate.day}/${localDate.month}/${localDate.year}';
    final isTax = transfer.isGst;

    final destItem = transfer.destinationItems.isNotEmpty ? transfer.destinationItems.first : null;
    final sourceItem = transfer.sourceItems.isNotEmpty ? transfer.sourceItems.first : null;

    final destGodownName = destItem?.godownName.isNotEmpty == true
        ? destItem!.godownName
        : 'Destination Godown';
    final destAddress = destItem?.godownAddress ?? '';
    final destGstin = destItem?.godownGstin ?? '';
    final destPhone = destItem?.godownPhone ?? '';
    final destState = destItem?.godownState.isNotEmpty == true
        ? destItem!.godownState.toUpperCase()
        : 'TAMILNADU';

    final sourceGodownName = sourceItem?.godownName.isNotEmpty == true
        ? sourceItem!.godownName
        : 'Source Godown';
    final sourceAddress = sourceItem?.godownAddress ?? '';
    final sourceGstin = sourceItem?.godownGstin ?? '';
    final sourcePhone = sourceItem?.godownPhone ?? '';
    final sourceState = sourceItem?.godownState.isNotEmpty == true
        ? sourceItem!.godownState.toUpperCase()
        : 'TAMILNADU';

    final challanNo = transfer.transferNumber;
    final dcNo = destItem?.dcNo.isNotEmpty == true ? destItem!.dcNo : (sourceItem?.dcNo ?? '');

    final itemsList = transfer.destinationItems.isNotEmpty
        ? transfer.destinationItems
        : transfer.sourceItems;

    double totalUomQty = 0;
    double totalQty = 0;

    final rowsHtml = itemsList.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final dynamic it = entry.value;

      final String itemName = it.itemName ?? 'Item';
      final String hsnCode = it.hsnCode ?? '-';
      final double qty = it.quantity ?? 0.0;
      final double uomQty = it.uomQuantity ?? 0.0;
      final String uomSym = (it.uomSymbol ?? '').toString().trim();
      final String uomQtyFormatted = uomQty > 0
          ? (uomQty % 1 == 0 ? uomQty.toInt().toString() : uomQty.toStringAsFixed(2))
          : '';
      final String uomValue = uomQtyFormatted.isNotEmpty
          ? (uomSym.isNotEmpty ? '$uomQtyFormatted $uomSym' : uomQtyFormatted)
          : '-';
      final String perSym = (it.perSymbol != null && it.perSymbol.isNotEmpty)
          ? it.perSymbol
          : (it.perName ?? '');
      final String qtyNum = qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);
      final String qtyDisplay = perSym.isNotEmpty ? '$qtyNum $perSym' : qtyNum;

      totalQty += qty;
      if (uomQty > 0) totalUomQty += uomQty;

      return '''
        <tr>
          <td style="text-align: center; border-right: 1px solid #000; padding: 5px 4px; font-weight: bold; font-size: 11.5px;">$idx</td>
          <td style="text-align: left; border-right: 1px solid #000; padding: 5px 4px; font-weight: bold; font-size: 11.5px;">${itemName.toUpperCase()}</td>
          <td style="text-align: center; border-right: 1px solid #000; padding: 5px 4px; font-weight: bold; font-size: 11.5px;">$hsnCode</td>
          <td style="text-align: right; border-right: 1px solid #000; padding: 5px 4px; font-weight: bold; font-size: 11.5px;">$uomValue</td>
          <td style="text-align: right; padding: 5px 4px; font-weight: bold; font-size: 11.5px;">$qtyDisplay</td>
        </tr>
      ''';
    }).join('\n');

    final primaryUom = itemsList
        .map((it) {
          if (it is StockTransferDestinationItemEntity) return it.uomSymbol.trim();
          if (it is StockTransferSourceItemEntity) return it.uomSymbol.trim();
          return '';
        })
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    final primaryPer = itemsList
        .map((it) {
          if (it is StockTransferDestinationItemEntity) {
            return it.perSymbol.isNotEmpty ? it.perSymbol : it.perName;
          }
          if (it is StockTransferSourceItemEntity) {
            return it.perSymbol.isNotEmpty ? it.perSymbol : it.perName;
          }
          return '';
        })
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    final totalQtyNum = totalQty % 1 == 0 ? totalQty.toInt().toString() : totalQty.toStringAsFixed(2);
    final totalQtyDisplay = primaryPer.isNotEmpty ? '$totalQtyNum $primaryPer' : totalQtyNum;
    final totalUomQtyFormatted = totalUomQty > 0
        ? (totalUomQty % 1 == 0 ? totalUomQty.toInt().toString() : totalUomQty.toStringAsFixed(2))
        : '';
    final totalUomDisplay = totalUomQtyFormatted.isNotEmpty
        ? (primaryUom.isNotEmpty ? '$totalUomQtyFormatted $primaryUom' : totalUomQtyFormatted)
        : '-';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Delivery Challan - $dcNo</title>
  <style>
    @page {
      size: 8in 5in;
      margin: 4mm;
    }
    * {
      box-sizing: border-box;
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
    }
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      background: #fff;
      font-family: Arial, Helvetica, sans-serif;
      font-size: 10.5px;
      color: #000;
    }
    @media print {
      body {
        margin: 0;
        padding: 0;
      }
      .challan-box {
        width: 100% !important;
        max-width: 100% !important;
        min-height: calc(5in - 8mm) !important;
        border: 1.5px solid #000 !important;
        page-break-inside: avoid;
        page-break-after: avoid;
      }
    }
    @media screen {
      body {
        padding: 12px;
        background: #f0f0f0;
      }
      .challan-box {
        width: 8in;
        max-width: 100%;
        min-height: calc(5in - 8mm);
        margin: 0 auto;
        background: #fff;
        border: 1.5px solid #000;
      }
    }
    .challan-box {
      display: flex;
      flex-direction: column;
    }
    .header-company {
      text-align: center;
      font-size: 15px;
      font-weight: bold;
      padding-top: 4px;
    }
    .header-company-info {
      text-align: center;
      font-size: 9.5px;
      margin-top: 1px;
    }
    .header-space {
      height: 36px;
    }
    .header-title {
      text-align: center;
      font-size: 13px;
      font-weight: bold;
      padding: 4px 0;
    }
    .flex-row {
      display: flex;
      width: 100%;
    }
    .border-bottom {
      border-bottom: 1.5px solid #000;
    }
    .border-right {
      border-right: 1.5px solid #000;
    }
    .challan-info-strip {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 4px 8px;
      font-size: 10.5px;
      border-bottom: 1.5px solid #000;
    }
    .seller-box, .buyer-box {
      width: 50%;
      min-height: 80px;
      padding: 5px 8px;
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
    }
    table.items-table {
      width: 100%;
      border-collapse: collapse;
      flex: 1;
    }
    table.items-table th {
      border-top: 1.5px solid #000;
      border-bottom: 1.5px solid #000;
      border-right: 1px solid #000;
      padding: 4px;
      font-size: 10px;
    }
    table.items-table th:last-child {
      border-right: none;
    }
    table.items-table td {
      font-size: 10.5px;
    }
    .total-row-bar {
      display: flex;
      border-top: 1.5px solid #000;
      border-bottom: 1.5px solid #000;
      font-weight: bold;
      padding: 4px 8px;
    }
    .words-box {
      padding: 4px 8px;
      border-bottom: 1.5px solid #000;
      display: flex;
      justify-content: space-between;
    }
    .narration-box {
      padding: 3px 8px;
      border-bottom: 1px solid #000;
      font-size: 9.5px;
    }
    .footer-box {
      display: flex;
      justify-content: space-between;
      align-items: flex-end;
      min-height: 55px;
      padding: 6px 12px;
      box-sizing: border-box;
    }
    .footer-left {
      width: 35%;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      text-align: left;
      min-height: 48px;
    }
    .footer-middle {
      width: 30%;
      text-align: center;
      padding-bottom: 4px;
      font-weight: bold;
      font-size: 10.5px;
    }
    .footer-right {
      width: 35%;
      display: flex;
      flex-direction: column;
      justify-content: flex-end;
      text-align: right;
      min-height: 48px;
    }
  </style>
</head>
<body>
  <div class="challan-box">
    <div style="border-bottom: 1.5px solid #000; padding-bottom: 4px;">
      ${isTax ? '''
      <div class="header-company">$companyName</div>
      <div class="header-company-info">22/24 ELANGO NAGAR,3RD CROSS STREET,S.V.COLONY, Tirupur -641604</div>
      <div class="header-company-info" style="font-weight: bold;">GSTIN: $companyGstin | Phone: $companyPhone</div>
      <div style="height: 4px;"></div>
      ''' : '''
      <div class="header-space"></div>
      '''}
      <div class="header-title">DELIVERY CHALLAN</div>
    </div>

    <div class="challan-info-strip">
      <div><strong>DC No.:</strong> $dcNo</div>
      <div><strong>Dated:</strong> $dateStr</div>
    </div>

    <div class="flex-row border-bottom">
      <div class="seller-box border-right">
        <div style="font-weight: bold;">CONSIGNOR / DISPATCH FROM :</div>
        <div style="font-size: 12px; font-weight: bold; margin-top: 2px;">$sourceGodownName</div>
        ${sourceAddress.isNotEmpty ? '<div style="margin-top: 2px;">$sourceAddress</div>' : ''}
        <div style="font-weight: 600; margin-top: 2px;">STATE: $sourceState</div>
        ${isTax && sourceGstin.isNotEmpty ? '<div style="font-weight: bold; margin-top: 2px;">GSTIN/UIN : $sourceGstin</div>' : ''}
        ${isTax && sourcePhone.isNotEmpty ? '<div>Phone: $sourcePhone</div>' : ''}
      </div>
      <div class="buyer-box">
        <div style="font-weight: bold;">CONSIGNEE / DELIVER TO :</div>
        <div style="font-size: 12px; font-weight: bold; margin-top: 2px;">$destGodownName</div>
        ${destAddress.isNotEmpty ? '<div style="margin-top: 2px;">$destAddress</div>' : ''}
        <div style="font-weight: 600; margin-top: 2px;">STATE: $destState</div>
        ${isTax && destGstin.isNotEmpty ? '<div style="font-weight: bold; margin-top: 2px;">GSTIN/UIN : $destGstin</div>' : ''}
        ${isTax && destPhone.isNotEmpty ? '<div>Phone: $destPhone</div>' : ''}
      </div>
    </div>

    <table class="items-table">
      <thead>
        <tr>
          <th style="width: 40px; text-align: center;">Sl<br>No.</th>
          <th style="text-align: left;">Description of Goods</th>
          <th style="width: 100px; text-align: center;">HSN/SAC</th>
          <th style="width: 100px; text-align: right;">UOM</th>
          <th style="width: 120px; text-align: right;">Quantity</th>
        </tr>
      </thead>
      <tbody>
        $rowsHtml
      </tbody>
      <tfoot>
        <tr style="border-top: 1.5px solid #000; border-bottom: 1.5px solid #000; font-weight: bold; font-size: 11px;">
          <td colspan="3" style="padding: 5px 6px; text-align: left; border-right: 1px solid #000;">Total</td>
          <td style="padding: 5px 6px; text-align: right; border-right: 1px solid #000;">$totalUomDisplay</td>
          <td style="padding: 5px 6px; text-align: right;">$totalQtyDisplay</td>
        </tr>
      </tfoot>
    </table>

    ${transfer.narration.isNotEmpty ? '''
    <div class="narration-box">
      <strong>Narration:</strong> ${transfer.narration}
    </div>
    ''' : ''}

    <div class="footer-box">
      <div class="footer-left">
        <div style="font-weight: bold; font-size: 10.5px;">Receiver's Signature</div>
      </div>
      <div class="footer-middle">
        Vehicle No. : ________________
      </div>
      <div class="footer-right">
        ${isTax ? '<div style="font-weight: bold; font-size: 11px;">For ' + companyName + '</div><div style="height: 18px;"></div>' : '<div style="height: 28px;"></div>'}
        <div style="font-weight: bold; font-size: 10.5px;">Authorised Signatory</div>
      </div>
    </div>
  </div>
</body>
</html>
''';
  }
}
