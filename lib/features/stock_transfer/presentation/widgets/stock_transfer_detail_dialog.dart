import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/stock_transfer_entity.dart';

class StockTransferDetailDialog extends StatelessWidget {
  final StockTransferEntity transfer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StockTransferDetailDialog({
    super.key,
    required this.transfer,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final localDate = transfer.date.toLocal();
    final formattedDate =
        '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isDesktop ? 960 : double.infinity,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.sync_alt, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock Journal: ${transfer.transferNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Transfer of Materials • Date: $formattedDate',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Two columns: Source vs Destination
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSourceSection()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDestinationSection()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildSourceSection(),
                    const SizedBox(height: 16),
                    _buildDestinationSection(),
                  ],
                ),

              const SizedBox(height: 20),
              // Narration & Meta
              if (transfer.narration.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Narration: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          transfer.narration,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transfer.createdByName.isNotEmpty ? 'Created by: ${transfer.createdByName}' : '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      if (onEdit != null) ...[
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit!();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (onDelete != null) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete'),
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete!();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.outbox, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Source (Consumption)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
              ),
              const Spacer(),
              Text(
                'Total: ${transfer.totalSourceQuantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
              ),
            ],
          ),
          const Divider(height: 16),
          ...transfer.sourceItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            'Godown: ${item.godownName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          if (item.companyGodownName.isNotEmpty && item.companyGodownName != item.godownName)
                            Text(
                              'Company Godown: ${item.companyGodownName}',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                            ),
                          if (item.dcNo.isNotEmpty || item.lotNo.isNotEmpty || item.batchNo.isNotEmpty)
                            Text(
                              [
                                if (item.dcNo.isNotEmpty) 'DC: ${item.dcNo}',
                                if (item.lotNo.isNotEmpty) 'Lot: ${item.lotNo}',
                                if (item.dcNo.isEmpty && item.lotNo.isEmpty && item.batchNo.isNotEmpty) 'DC: ${item.batchNo}',
                              ].join(' • '),
                              style: const TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.perSymbol.isNotEmpty ? item.perSymbol : 'kg'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (item.uomQuantity > 0)
                            Text(
                              '${item.uomQuantity.toStringAsFixed(item.uomQuantity.truncateToDouble() == item.uomQuantity ? 0 : 2)} ${item.uomSymbol.isNotEmpty ? item.uomSymbol : 'UOM'}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDestinationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.move_to_inbox, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Destination (Production)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
              ),
              const Spacer(),
              Text(
                'Total: ${transfer.totalDestinationQuantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
              ),
            ],
          ),
          const Divider(height: 16),
          ...transfer.destinationItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            'Godown: ${item.godownName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          if (item.companyGodownName.isNotEmpty && item.companyGodownName != item.godownName)
                            Text(
                              'Company Godown: ${item.companyGodownName}',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                            ),
                          if (item.dcNo.isNotEmpty || item.lotNo.isNotEmpty || item.batchNo.isNotEmpty)
                            Text(
                              [
                                if (item.dcNo.isNotEmpty) 'New DC: ${item.dcNo}',
                                if (item.lotNo.isNotEmpty) 'Lot: ${item.lotNo}',
                                if (item.dcNo.isEmpty && item.lotNo.isEmpty && item.batchNo.isNotEmpty) 'New DC: ${item.batchNo}',
                              ].join(' • '),
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.perSymbol.isNotEmpty ? item.perSymbol : 'kg'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (item.uomQuantity > 0)
                            Text(
                              '${item.uomQuantity.toStringAsFixed(item.uomQuantity.truncateToDouble() == item.uomQuantity ? 0 : 2)} ${item.uomSymbol.isNotEmpty ? item.uomSymbol : 'UOM'}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
