import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/number_to_words_indian.dart';
import 'package:mlf_frontend/core/utils/bill_print_helper.dart';
import '../../domain/entities/sale_entity.dart';

class SalesBillDialog extends StatelessWidget {
  final SaleEntity sale;

  const SalesBillDialog({super.key, required this.sale});

  // Company defaults for tax invoice
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
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 920),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
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

              // Printable Invoice Sheet Container
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
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: _buildBillDocument(),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            sale.isGstBill ? 'Tax Invoice Preview' : 'Estimation Preview',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Print Bill'),
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
    final html = generateHtmlBill(sale);
    BillPrintHelper.printBill(html);
  }

  Widget _buildBillDocument() {
    final localDate = sale.date.toLocal();
    final dateStr =
        '${localDate.day}/${localDate.month}/${localDate.year}';

    // Rounding & Tax Calculations
    final subTotal = sale.subTotal;
    final isTax = sale.isGstBill;
    final invoiceNumber = sale.invoiceNo.isNotEmpty ? sale.invoiceNo : sale.salesNumber;
    final gstPercentage = sale.gstPercentage;
    final gstAmount = sale.gstAmount;
    final totalAmount = sale.totalAmount;
    final roundedTotal = totalAmount.roundToDouble();
    final roundOff = (roundedTotal - totalAmount);
    final finalPayable = roundedTotal > 0 ? roundedTotal : totalAmount;

    final amountInWords = NumberToWordsIndian.convert(finalPayable);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Invoice Title Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: Text(
            isTax ? 'Tax Invoice' : 'Estimation',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
        ),

        // Seller & Invoice Meta Top Block
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seller Detail
              Expanded(
                flex: 11,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 105),
                  padding: const EdgeInsets.all(8),
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
                        'SELLER DETAIL :',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 3),
                      if (isTax) ...[
                        const Text(
                          companyName,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          companyAddress,
                          style: TextStyle(fontSize: 10, height: 1.25, color: Colors.black),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'GSTIN/UIN : $companyGstin',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        if (companyPhone.isNotEmpty)
                          Text(
                            'Phone: $companyPhone',
                            style: const TextStyle(fontSize: 10, color: Colors.black),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Invoice Meta (Right side beside Seller)
              Expanded(
                flex: 9,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
                  ),
                  child: Column(
                    children: [
                      _buildMetaGridRow('Invoice No.', invoiceNumber, 'Dated', dateStr),
                      _buildMetaGridRow('Delivery Note', sale.dcNo, 'Mode/Terms of Payment', ''),
                      _buildMetaGridRow('Supplier\'s Ref.', '', 'Other Reference(s)', '', isLast: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Buyer & Dispatch Meta Block
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Buyer Detail
              Expanded(
                flex: 11,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 105),
                  padding: const EdgeInsets.all(8),
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
                        'BUYER DETAIL :',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sale.partyName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      if (isTax) ...[
                        if (sale.partyAddress.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            sale.partyAddress,
                            style: const TextStyle(fontSize: 10, height: 1.25, color: Colors.black),
                          ),
                        ],
                        const SizedBox(height: 2),
                        const Text(
                          'STATE: TAMILNADU',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        if (sale.partyGstin.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'GSTIN/UIN ${sale.partyGstin}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                        if (sale.partyPhone.isNotEmpty)
                          Text(
                            'Phone: ${sale.partyPhone}',
                            style: const TextStyle(fontSize: 10, color: Colors.black),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Dispatch Meta (Right side beside Buyer)
              Expanded(
                flex: 9,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
                  ),
                  child: Column(
                    children: [
                      _buildMetaGridRow('Buyer\'s Order No.', '', 'Dated', ''),
                      _buildMetaGridRow('Dispatch No.', sale.dcNo, 'Delivery Note Date', dateStr),
                      _buildMetaGridRow('Terms of Delivery', '', '', '', isLast: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Header
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: Row(
            children: [
              _buildColHeader('Sl\nNo.', width: 34, align: TextAlign.center),
              _buildColHeader('Description of Goods', flex: 7, align: TextAlign.left),
              _buildColHeader('HSN/SAC', width: 75, align: TextAlign.center),
              _buildColHeader('Quantity', width: 62, align: TextAlign.right),
              _buildColHeader('Rate', width: 62, align: TextAlign.right),
              _buildColHeader('per', width: 36, align: TextAlign.center),
              _buildColHeader('Disc %', width: 48, align: TextAlign.center),
              _buildColHeader('Amount', width: 76, align: TextAlign.right, isLast: true),
            ],
          ),
        ),

        // Items Lines
        ...sale.items.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final item = entry.value;
          final qty = item.billedQuantity > 0 ? item.billedQuantity : item.actualQuantity;

          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCell(idx.toString(), width: 34, align: TextAlign.center),
                _buildCell(item.itemName.toUpperCase(), flex: 7, align: TextAlign.left, isBold: true),
                _buildCell(item.hsnCode.isNotEmpty ? item.hsnCode : '-', width: 75, align: TextAlign.center),
                _buildCell(qty.toStringAsFixed(2), width: 62, align: TextAlign.right),
                _buildCell(item.rate.toStringAsFixed(2), width: 62, align: TextAlign.right),
                _buildCell(item.perSymbol.isNotEmpty ? item.perSymbol : 'Kg', width: 36, align: TextAlign.center),
                _buildCell('', width: 48, align: TextAlign.center),
                _buildCell(item.amount.toStringAsFixed(2), width: 76, align: TextAlign.right, isLast: true),
              ],
            ),
          );
        }),

        // Empty space for invoice styling
        if (sale.items.length < 5)
          Container(
            height: (5 - sale.items.length) * 26.0,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.transparent)),
            ),
          ),

        // Subtotals & Tax Lines
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 1.0)),
          ),
          child: Column(
            children: [
              _buildTotalLine('SUBTOTAL-', subTotal.toStringAsFixed(2)),
              if (isTax) ...[
                _buildTotalLine('CGST @${(gstPercentage / 2).toStringAsFixed(1)}% -', (gstAmount / 2).toStringAsFixed(2)),
                _buildTotalLine('SGST @${(gstPercentage / 2).toStringAsFixed(1)}% -', (gstAmount / 2).toStringAsFixed(2)),
              ],
              if (roundOff.abs() > 0.001)
                _buildTotalLine('Rounded off-', roundOff.toStringAsFixed(2)),
            ],
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
              const SizedBox(width: 34),
              const Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text(
                    'Total',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 75), // HSN spacer
              Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  sale.totalBilledQuantity > 0
                      ? sale.totalBilledQuantity.toStringAsFixed(2)
                      : sale.totalQuantity.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(width: 36 + 48), // Per + Disc spacer
              Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text(
                  finalPayable.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),

        // Amount Chargeable in words
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Chargeable (in words)',
                      style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amountInWords,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Text(
                'E.& O.E.',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Declaration & Signatory Footer
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Declaration
              Expanded(
                flex: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.black, width: 1.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Declaration',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.black),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.',
                        style: TextStyle(fontSize: 9.5, height: 1.3, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              // Signatory Box
              Expanded(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTax ? 'For $companyName' : '',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Authorised Signatory',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaGridRow(String label1, String val1, String label2, String val2, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: isLast ? 0 : 0.8)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.black, width: 0.8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label1, style: const TextStyle(fontSize: 8.5, color: Colors.black87)),
                    Text(val1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label2, style: const TextStyle(fontSize: 8.5, color: Colors.black87)),
                    Text(val2, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildCell(String text, {double? width, int? flex, TextAlign align = TextAlign.left, bool isLast = false, bool isBold = false}) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: isLast ? 0 : 0.8)),
      ),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );

    return width != null ? SizedBox(width: width, child: child) : Expanded(flex: flex ?? 1, child: child);
  }

  Widget _buildTotalLine(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(width: 16),
          SizedBox(
            width: 76,
            child: Text(amount, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// Clean HTML document generation matching the exact invoice picture
  static String generateHtmlBill(SaleEntity sale) {
    final localDate = sale.date.toLocal();
    final dateStr = '${localDate.day}/${localDate.month}/${localDate.year}';
    final isTax = sale.isGstBill;
    final gstPercentage = sale.gstPercentage;
    final subTotal = sale.subTotal;
    final gstAmount = sale.gstAmount;
    final totalAmount = sale.totalAmount;
    final roundedTotal = totalAmount.roundToDouble();
    final roundOff = (roundedTotal - totalAmount);
    final finalPayable = roundedTotal > 0 ? roundedTotal : totalAmount;
    final amountWords = NumberToWordsIndian.convert(finalPayable);

    final totalQty = sale.totalBilledQuantity > 0 ? sale.totalBilledQuantity : sale.totalQuantity;

    final rowsHtml = sale.items.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final it = entry.value;
      final qty = it.billedQuantity > 0 ? it.billedQuantity : it.actualQuantity;
      return '''
        <tr>
          <td style="text-align: center; border-right: 1px solid #000; padding: 4px;">$idx</td>
          <td style="text-align: left; border-right: 1px solid #000; padding: 4px; font-weight: bold;">${it.itemName.toUpperCase()}</td>
          <td style="text-align: center; border-right: 1px solid #000; padding: 4px;">${it.hsnCode}</td>
          <td style="text-align: right; border-right: 1px solid #000; padding: 4px;">${qty.toStringAsFixed(2)}</td>
          <td style="text-align: right; border-right: 1px solid #000; padding: 4px;">${it.rate.toStringAsFixed(2)}</td>
          <td style="text-align: center; border-right: 1px solid #000; padding: 4px;">${it.perSymbol.isNotEmpty ? it.perSymbol : 'Kg'}</td>
          <td style="text-align: center; border-right: 1px solid #000; padding: 4px;"></td>
          <td style="text-align: right; padding: 4px;">${it.amount.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join('\n');

    final invoiceNumber = sale.invoiceNo.isNotEmpty ? sale.invoiceNo : sale.salesNumber;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${isTax ? 'Tax Invoice' : 'Estimation'} - $invoiceNumber</title>
  <style>
    @page {
      size: A4 portrait;
      margin: 10mm;
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
      font-size: 11px;
      color: #000;
    }
    @media print {
      body {
        margin: 0;
        padding: 0;
      }
      .invoice-box {
        width: 100% !important;
        max-width: 100% !important;
        min-height: 275mm !important;
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
      .invoice-box {
        width: 100%;
        max-width: 800px;
        min-height: 275mm;
        margin: 0 auto;
        background: #fff;
        border: 1.5px solid #000;
      }
    }
    .invoice-box {
      display: flex;
      flex-direction: column;
    }
    .header-title {
      text-align: center;
      font-size: 14px;
      font-weight: bold;
      border-bottom: 1.5px solid #000;
      padding: 5px 0;
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
    .seller-box, .buyer-box {
      width: 55%;
      min-height: 105px;
      padding: 6px 8px;
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
    }
    .meta-box {
      width: 45%;
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
    }
    .meta-row {
      display: flex;
      flex: 1;
      min-height: 35px;
      border-bottom: 1px solid #000;
    }
    .meta-row:last-child {
      border-bottom: none;
    }
    .meta-cell {
      flex: 1;
      padding: 3px 6px;
      box-sizing: border-box;
    }
    .meta-cell:first-child {
      border-right: 1px solid #000;
    }
    .meta-label {
      font-size: 9px;
      color: #333;
    }
    .meta-val {
      font-size: 11px;
      font-weight: bold;
    }
    .items-container {
      flex: 1;
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
      padding: 5px 4px;
      font-size: 10px;
    }
    table.items-table th:last-child {
      border-right: none;
    }
    table.items-table td {
      font-size: 10.5px;
    }
    .totals-area {
      border-top: 1px solid #000;
      text-align: right;
      padding: 4px 8px;
    }
    .total-line {
      display: flex;
      justify-content: flex-end;
      margin-bottom: 2px;
      font-weight: bold;
    }
    .total-line span:first-child {
      margin-right: 20px;
    }
    .total-row-bar {
      display: flex;
      border-top: 1.5px solid #000;
      border-bottom: 1.5px solid #000;
      font-weight: bold;
      padding: 5px 8px;
    }
    .words-box {
      padding: 6px 8px;
      border-bottom: 1.5px solid #000;
      display: flex;
      justify-content: space-between;
    }
    .footer-box {
      display: flex;
      min-height: 75px;
    }
    .declaration {
      width: 60%;
      padding: 6px;
      border-right: 1.5px solid #000;
      font-size: 9.5px;
    }
    .signatory {
      width: 40%;
      padding: 6px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      text-align: right;
      font-size: 10px;
    }
  </style>
</head>
<body>
  <div class="invoice-box">
    <div class="header-title">${isTax ? 'Tax Invoice' : 'Estimation'}</div>

    <div class="flex-row border-bottom">
      <div class="seller-box border-right">
        <div style="font-weight: bold;">SELLER DETAIL :</div>
        ${isTax ? '''
        <div style="font-size: 13px; font-weight: bold; margin-top: 2px;">$companyName</div>
        <div style="white-space: pre-line; margin-top: 2px;">$companyAddress</div>
        <div style="font-weight: bold; margin-top: 2px;">GSTIN/UIN : $companyGstin</div>
        <div>Phone: $companyPhone</div>
        ''' : ''}
      </div>
      <div class="meta-box">
        <div class="meta-row">
          <div class="meta-cell"><span class="meta-label">Invoice No.</span><br><span class="meta-val">$invoiceNumber</span></div>
          <div class="meta-cell"><span class="meta-label">Dated</span><br><span class="meta-val">$dateStr</span></div>
        </div>
        <div class="meta-row">
          <div class="meta-cell"><span class="meta-label">Delivery Note</span><br><span class="meta-val">${sale.dcNo}</span></div>
          <div class="meta-cell"><span class="meta-label">Mode/Terms of Payment</span><br><span class="meta-val"></span></div>
        </div>
        <div class="meta-row">
          <div class="meta-cell"><span class="meta-label">Supplier's Ref.</span><br><span class="meta-val"></span></div>
          <div class="meta-cell"><span class="meta-label">Other Reference(s)</span><br><span class="meta-val"></span></div>
        </div>
      </div>
    </div>

    <div class="flex-row border-bottom">
      <div class="buyer-box border-right">
        <div style="font-weight: bold;">BUYER DETAIL :</div>
        <div style="font-size: 12px; font-weight: bold; margin-top: 2px;">${sale.partyName}</div>
        ${isTax ? '''
        ${sale.partyAddress.isNotEmpty ? '<div style="margin-top: 2px;">' + sale.partyAddress + '</div>' : ''}
        <div style="font-weight: 600; margin-top: 2px;">STATE: TAMILNADU</div>
        ${sale.partyGstin.isNotEmpty ? '<div style="font-weight: bold; margin-top: 2px;">GSTIN/UIN ' + sale.partyGstin + '</div>' : ''}
        ${sale.partyPhone.isNotEmpty ? '<div>Phone: ' + sale.partyPhone + '</div>' : ''}
        ''' : ''}
      </div>
      <div class="meta-box">
        <div class="meta-row">
          <div class="meta-cell"><span class="meta-label">Buyer's Order No.</span><br><span class="meta-val"></span></div>
          <div class="meta-cell"><span class="meta-label">Dated</span><br><span class="meta-val"></span></div>
        </div>
        <div class="meta-row">
          <div class="meta-cell"><span class="meta-label">Dispatch No.</span><br><span class="meta-val">${sale.dcNo}</span></div>
          <div class="meta-cell"><span class="meta-label">Delivery Note Date</span><br><span class="meta-val">$dateStr</span></div>
        </div>
        <div class="meta-row">
          <div class="meta-cell" style="flex: 2;"><span class="meta-label">Terms of Delivery</span><br><span class="meta-val"></span></div>
        </div>
      </div>
    </div>

    <table class="items-table">
      <thead>
        <tr>
          <th style="width: 35px; text-align: center;">Sl<br>No.</th>
          <th style="text-align: left;">Description of Goods</th>
          <th style="width: 80px; text-align: center;">HSN/SAC</th>
          <th style="width: 65px; text-align: right;">Quantity</th>
          <th style="width: 65px; text-align: right;">Rate</th>
          <th style="width: 40px; text-align: center;">per</th>
          <th style="width: 50px; text-align: center;">Disc %</th>
          <th style="width: 85px; text-align: right;">Amount</th>
        </tr>
      </thead>
      <tbody>
        $rowsHtml
      </tbody>
    </table>

    <div class="totals-area">
      <div class="total-line"><span>SUBTOTAL-</span><span>${subTotal.toStringAsFixed(2)}</span></div>
      ${isTax ? '''
      <div class="total-line"><span>CGST @''' + (gstPercentage / 2).toStringAsFixed(1) + '''% -</span><span>''' + (gstAmount / 2).toStringAsFixed(2) + '''</span></div>
      <div class="total-line"><span>SGST @''' + (gstPercentage / 2).toStringAsFixed(1) + '''% -</span><span>''' + (gstAmount / 2).toStringAsFixed(2) + '''</span></div>
      ''' : ''}
      ${roundOff.abs() > 0.001 ? '<div class="total-line"><span>Rounded off-</span><span>' + roundOff.toStringAsFixed(2) + '</span></div>' : ''}
    </div>

    <div class="total-row-bar">
      <div style="flex: 1;">Total</div>
      <div style="width: 65px; text-align: right; margin-right: 175px;">${totalQty.toStringAsFixed(2)}</div>
      <div style="width: 85px; text-align: right;">${finalPayable.toStringAsFixed(2)}</div>
    </div>

    <div class="words-box">
      <div>
        <div style="font-size: 9px; font-style: italic;">Amount Chargeable (in words)</div>
        <div style="font-weight: bold; margin-top: 2px;">$amountWords</div>
      </div>
      <div style="font-weight: bold;">E.& O.E.</div>
    </div>

    <div class="footer-box">
      <div class="declaration">
        <div style="font-weight: bold; text-decoration: underline;">Declaration</div>
        <div style="margin-top: 4px;">We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.</div>
      </div>
      <div class="signatory">
        <div style="font-weight: bold;">${isTax ? 'For ' + companyName : ''}</div>
        <div>Authorised Signatory</div>
      </div>
    </div>
  </div>
</body>
</html>
''';
  }
}
