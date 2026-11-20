import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/purchase_entity.dart';

class PurchaseDetailDialog extends StatelessWidget {
  final PurchaseEntity purchase;

  const PurchaseDetailDialog({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${purchase.date.day.toString().padLeft(2, '0')}/${purchase.date.month.toString().padLeft(2, '0')}/${purchase.date.year}';

    final items = purchase.items.isNotEmpty
        ? purchase.items
        : [
            PurchaseItemEntity(
              itemId: purchase.itemId,
              itemName: purchase.itemName,
              itemCode: purchase.itemCode,
              itemStock: purchase.itemStock,
              godownId: purchase.godownId,
              godownName: purchase.godownName,
              godownCode: purchase.godownCode,
              uomId: purchase.uomId,
              uomSymbol: purchase.uomSymbol,
              uomQuantity: purchase.uomQuantity,
              actualQuantity: purchase.actualQuantity,
              billedQuantity: purchase.billedQuantity,
              rate: purchase.rate,
              perId: purchase.perId,
              perSymbol: purchase.perSymbol,
              amount: purchase.amount,
            ),
          ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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
                          'Purchase Entry: ${purchase.purchaseNumber}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Recorded on $dateStr ${purchase.createdByName.isNotEmpty ? "by ${purchase.createdByName}" : ""}',
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

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMetaItem('Party / Supplier', purchase.partyName),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey.shade300),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildMetaItem('Purchase Type', purchase.purchaseTypeName),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey.shade300),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildMetaItem(
                                'Tax Status',
                                purchase.isGstBill
                                    ? 'GST Applied (${purchase.gstPercentage.toStringAsFixed(0)}%)'
                                    : 'GST Not Applied',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Items Table Header
                      Row(
                        children: [
                          const Text(
                            'Items Purchased & Assigned Godowns',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${items.length} ${items.length == 1 ? "item" : "items"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Items Breakdown Table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 40,
                            dataRowMinHeight: 42,
                            dataRowMaxHeight: 52,
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            columns: const [
                              DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Delivered Godown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('UOM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('UOM Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Actual Qty (Stock)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success))),
                              DataColumn(label: Text('Billed Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Rate (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Per', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Amount (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                            rows: List.generate(items.length, (idx) {
                              final it = items[idx];
                              return DataRow(
                                cells: [
                                  DataCell(Text('${idx + 1}', style: const TextStyle(fontSize: 12))),
                                  DataCell(
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(it.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        if (it.itemCode.isNotEmpty)
                                          Text(it.itemCode, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      it.godownName.isNotEmpty
                                          ? '${it.godownName} (${it.godownCode})'
                                          : (purchase.godownName.isNotEmpty ? purchase.godownName : '-'),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  DataCell(Text(it.uomSymbol, style: const TextStyle(fontSize: 13))),
                                  DataCell(Text(it.uomQuantity.toString(), style: const TextStyle(fontSize: 13))),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '+${it.actualQuantity} ${it.uomSymbol}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${it.billedQuantity} ${it.uomSymbol}', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text('₹${it.rate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13))),
                                  DataCell(Text(it.perSymbol.isNotEmpty ? it.perSymbol : 'Unit', style: const TextStyle(fontSize: 13))),
                                  DataCell(
                                    Text(
                                      '₹${it.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Totals Summary Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Actual Stock Added: ${purchase.totalActualQuantity.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success, fontSize: 13),
                                ),
                                Text(
                                  'Total Billed Qty: ${purchase.totalBilledQuantity.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal: ₹${purchase.subTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                if (purchase.isGstBill)
                                  Text(
                                    'GST (${purchase.gstPercentage.toStringAsFixed(0)}%): +₹${purchase.gstAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 14),
                                  ),
                                Text(
                                  'Total Amount: ₹${purchase.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (purchase.notes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Notes / Remarks:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(purchase.notes, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
