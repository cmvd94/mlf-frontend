import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/purchase_entity.dart';

class PurchaseDetailDialog extends StatelessWidget {
  final PurchaseEntity purchase;

  const PurchaseDetailDialog({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final localDate = purchase.date.toLocal();
    final dateStr =
        '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';

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
              dcNo: purchase.dcNo,
              lotNo: purchase.lotNo,
              batchNo: purchase.batchNo,
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 20,
        vertical: isMobile ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
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
                          style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
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
                      // Overview Card: 2x2 grid on Mobile, 4 columns in a Row on Desktop
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: isMobile
                            ? Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildMetaItem('Party / Supplier', purchase.partyName)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildMetaItem('Purchase Type', purchase.purchaseTypeName)),
                                    ],
                                  ),
                                  const Divider(height: 18),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildMetaItem(
                                          'Company Godown',
                                          purchase.companyGodownName.isNotEmpty
                                              ? '${purchase.companyGodownName} (${purchase.companyGodownCode})'
                                              : (purchase.godownName.isNotEmpty ? purchase.godownName : 'N/A'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
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
                                ],
                              )
                            : Row(
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
                                      'Company Godown',
                                      purchase.companyGodownName.isNotEmpty
                                          ? '${purchase.companyGodownName} (${purchase.companyGodownCode})'
                                          : (purchase.godownName.isNotEmpty ? purchase.godownName : 'N/A'),
                                    ),
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
                      if (isMobile)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(Icons.swipe_outlined, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Swipe horizontally to view all item details',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
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
                              DataColumn(label: Text('DC #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              DataColumn(label: Text('Lot #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                                    Text(it.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text(
                                      it.godownName.isNotEmpty
                                          ? it.godownName
                                          : (purchase.godownName.isNotEmpty ? purchase.godownName : '-'),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        it.dcNo.isNotEmpty ? it.dcNo : (it.batchNo.isNotEmpty ? it.batchNo : '-'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        it.lotNo.isNotEmpty ? it.lotNo : '-',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
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

                      // Totals Summary Box: Stacked rows on mobile to prevent overlapping
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: isMobile
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Actual Stock Added:',
                                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success, fontSize: 13),
                                      ),
                                      Text(
                                        '+${purchase.totalActualQuantity.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Billed Qty:',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      Text(
                                        purchase.totalBilledQuantity.toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Subtotal:',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      Text(
                                        '₹${purchase.subTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  if (purchase.isGstBill) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'GST (${purchase.gstPercentage.toStringAsFixed(0)}%):',
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 13),
                                        ),
                                        Text(
                                          '+₹${purchase.gstAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Amount:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                                      ),
                                      Text(
                                        '₹${purchase.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
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

              // Close Button: Full-width on mobile
              SizedBox(
                width: isMobile ? double.infinity : null,
                child: Align(
                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
