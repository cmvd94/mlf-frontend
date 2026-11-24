import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/debit_note_entity.dart';

class DebitNoteDetailDialog extends StatelessWidget {
  final DebitNoteEntity debitNote;

  const DebitNoteDetailDialog({super.key, required this.debitNote});

  @override
  Widget build(BuildContext context) {
    final localDate = debitNote.date.toLocal();
    final dateStr =
        '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Dialog(
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 960,
          maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.95 : 780,
        ),
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
                    child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debit Note: ${debitNote.debitNoteNumber}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Date: $dateStr ${debitNote.createdByName.isNotEmpty ? "• Recorded by: ${debitNote.createdByName}" : ""}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Summary Info Header Cards
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _infoCard('Party (Customer)', debitNote.partyName, subtitle: debitNote.partyCode),
                  if (debitNote.salesTypeName.isNotEmpty)
                    _infoCard('Type', debitNote.salesTypeName, subtitle: debitNote.salesTypeCode),
                  if (debitNote.dcNo.isNotEmpty)
                    _infoCard('DC Number', debitNote.dcNo),
                  if (debitNote.companyGodownName.isNotEmpty)
                    _infoCard('Company Godown', debitNote.companyGodownName),
                  _infoCard('Total Quantity', debitNote.totalActualQuantity.toStringAsFixed(2)),
                  _infoCard('Grand Total', '₹ ${debitNote.totalAmount.toStringAsFixed(2)}', isHighlight: true),
                ],
              ),

              const SizedBox(height: 16),
              const Text('Item Particulars', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (isMobile) ...[
                Row(
                  children: [
                    Icon(Icons.swipe, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe horizontally to view all item details',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // Items Table
              Flexible(
                child: Scrollbar(
                  thumbVisibility: isMobile,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Godown', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('DC No', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Lot No', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('UOM', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('UOM Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actual Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Billed Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Per', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: debitNote.items.map((item) {
                        return DataRow(cells: [
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (item.itemCode.isNotEmpty)
                                  Text(item.itemCode, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          DataCell(Text(item.godownName.isNotEmpty ? item.godownName : '-')),
                          DataCell(Text(item.dcNo.isNotEmpty ? item.dcNo : '-')),
                          DataCell(Text(item.lotNo.isNotEmpty ? item.lotNo : '-')),
                          DataCell(Text(item.uomSymbol.isNotEmpty ? item.uomSymbol : '-')),
                          DataCell(Text(item.uomQuantity.toStringAsFixed(2))),
                          DataCell(Text(item.actualQuantity.toStringAsFixed(2), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                          DataCell(Text(item.billedQuantity.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text('₹ ${item.rate.toStringAsFixed(2)}')),
                          DataCell(Text(item.perSymbol.isNotEmpty ? item.perSymbol : 'Unit')),
                          DataCell(Text('₹ ${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

              const Divider(height: 24),

              // Bottom Section: Notes & Totals Breakdown
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (debitNote.notes.isNotEmpty) ...[
                      const Text('Notes / Remarks:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(debitNote.notes, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                    ],
                    if (debitNote.narration.isNotEmpty && debitNote.narration != debitNote.notes) ...[
                      const Text('Narration:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(debitNote.narration, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _totalRow('Sub Total', '₹ ${debitNote.subTotal.toStringAsFixed(2)}'),
                          if (debitNote.isGstBill) ...[
                            const SizedBox(height: 4),
                            _totalRow('GST (${debitNote.gstPercentage.toStringAsFixed(0)}%)', '₹ ${debitNote.gstAmount.toStringAsFixed(2)}'),
                          ],
                          const Divider(height: 12),
                          _totalRow('Grand Total', '₹ ${debitNote.totalAmount.toStringAsFixed(2)}', isBold: true, isHighlight: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (debitNote.notes.isNotEmpty) ...[
                            const Text('Notes / Remarks:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(debitNote.notes, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                          ],
                          if (debitNote.narration.isNotEmpty && debitNote.narration != debitNote.notes) ...[
                            const Text('Narration:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(debitNote.narration, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _totalRow('Sub Total', '₹ ${debitNote.subTotal.toStringAsFixed(2)}'),
                          if (debitNote.isGstBill) ...[
                            const SizedBox(height: 4),
                            _totalRow('GST (${debitNote.gstPercentage.toStringAsFixed(0)}%)', '₹ ${debitNote.gstAmount.toStringAsFixed(2)}'),
                          ],
                          const Divider(height: 12),
                          _totalRow('Grand Total', '₹ ${debitNote.totalAmount.toStringAsFixed(2)}', isBold: true, isHighlight: true),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, {String? subtitle, bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHighlight ? AppColors.primary.withOpacity(0.4) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: isHighlight ? AppColors.primary : AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty)
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
