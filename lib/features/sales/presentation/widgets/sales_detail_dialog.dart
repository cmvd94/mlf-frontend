import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/sale_entity.dart';
import 'sales_bill_dialog.dart';

class SalesDetailDialog extends StatelessWidget {
  final SaleEntity sale;

  const SalesDetailDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final localDate = sale.date.toLocal();
    final dateStr =
        '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 20,
        vertical: isMobile ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 780),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.point_of_sale, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sale Invoice: ${sale.salesNumber}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Date: $dateStr ${sale.createdByName.isNotEmpty ? "• Billed by: ${sale.createdByName}" : ""}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_outlined, color: AppColors.primary),
                    tooltip: 'Print / View Bill',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => SalesBillDialog(sale: sale),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header details card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 12,
                          children: [
                            _buildInfoItem('Customer / Party', sale.partyName, code: sale.partyCode),
                            if (sale.salesTypeName.isNotEmpty)
                              _buildInfoItem('Sales Type', sale.salesTypeName, code: sale.salesTypeCode),
                            if (sale.dcNo.isNotEmpty)
                              _buildInfoItem('DC Number', sale.dcNo),
                            if (sale.invoiceNo.isNotEmpty)
                              _buildInfoItem('Invoice Number', sale.invoiceNo),
                            if (sale.companyGodownName.isNotEmpty)
                              _buildInfoItem('Company Godown', sale.companyGodownName, code: sale.companyGodownCode),
                            _buildInfoItem('Invoice Date', dateStr),
                            _buildInfoItem('GST Status', sale.isGstBill ? 'Yes (${sale.gstPercentage}%)' : 'Non-GST Bill'),
                            if (sale.notes.isNotEmpty)
                              _buildInfoItem('Notes / Remarks', sale.notes),
                            if (sale.narration.isNotEmpty && sale.narration != sale.notes)
                              _buildInfoItem('Narration', sale.narration),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Items Table Header
                      const Text(
                        'Sold Items Breakdown',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 10),

                      // Items Table
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1.8),
                              1: FlexColumnWidth(1.4),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(1.0),
                              4: FlexColumnWidth(1.0),
                              5: FlexColumnWidth(1.2),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: const [
                                  _TableCell('Item / Code', isHeader: true),
                                  _TableCell('Godown (DC / Lot)', isHeader: true),
                                  _TableCell('Actual / Billed Qty', isHeader: true),
                                  _TableCell('Rate', isHeader: true),
                                  _TableCell('Per Unit', isHeader: true),
                                  _TableCell('Line Amount', isHeader: true, alignRight: true),
                                ],
                              ),
                              ...sale.items.map((item) {
                                final ref = [
                                  if (item.dcNo.isNotEmpty) 'DC: ${item.dcNo}',
                                  if (item.lotNo.isNotEmpty) 'Lot: ${item.lotNo}',
                                ].join(', ');

                                return TableRow(
                                  children: [
                                    _TableCell(
                                      '${item.itemName}\n${item.itemCode.isNotEmpty ? "(${item.itemCode})" : ""}',
                                    ),
                                    _TableCell(
                                      '${item.godownName}\n${ref.isNotEmpty ? "[$ref]" : ""}',
                                    ),
                                    _TableCell(
                                      'Act: ${item.actualQuantity.toStringAsFixed(2)} ${item.perSymbol}\nBill: ${item.billedQuantity.toStringAsFixed(2)} (${item.uomQuantity.toStringAsFixed(0)} ${item.uomSymbol})',
                                    ),
                                    _TableCell('₹ ${item.rate.toStringAsFixed(2)}'),
                                    _TableCell(item.perSymbol.isNotEmpty ? item.perSymbol : 'Unit'),
                                    _TableCell('₹ ${item.amount.toStringAsFixed(2)}', alignRight: true),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Financial Summary
                      Align(
                        alignment: isMobile ? Alignment.center : Alignment.centerRight,
                        child: Container(
                          width: isMobile ? double.infinity : 320,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSummaryRow('Subtotal:', '₹ ${sale.subTotal.toStringAsFixed(2)}'),
                              if (sale.isGstBill) ...[
                                const SizedBox(height: 6),
                                _buildSummaryRow(
                                  'GST (${sale.gstPercentage.toStringAsFixed(0)}%):',
                                  '₹ ${sale.gstAmount.toStringAsFixed(2)}',
                                ),
                              ],
                              const Divider(height: 16),
                              _buildSummaryRow(
                                'Net Total:',
                                '₹ ${sale.totalAmount.toStringAsFixed(2)}',
                                isBold: true,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                              const SizedBox(height: 4),
                              _buildSummaryRow(
                                'Total Sold Qty:',
                                sale.totalQuantity.toStringAsFixed(2),
                                isMuted: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              // Footer
              SizedBox(
                width: isMobile ? double.infinity : null,
                child: Align(
                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: isMobile ? const Size(double.infinity, 44) : null,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {String? code}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            if (code != null && code.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text('($code)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color, double fontSize = 13, bool isMuted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isMuted ? AppColors.textSecondary : color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool alignRight;

  const _TableCell(this.text, {this.isHeader = false, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppColors.primary : Colors.black87,
        ),
      ),
    );
  }
}
