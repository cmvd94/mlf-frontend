import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/confirm_delete_dialog.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../controllers/purchase_controller.dart';
import '../widgets/purchase_entry_dialog.dart';
import '../widgets/purchase_detail_dialog.dart';

class PurchaseManagementPage extends StatefulWidget {
  final PurchaseController purchaseController;
  final InventoryController inventoryController;

  const PurchaseManagementPage({
    super.key,
    required this.purchaseController,
    required this.inventoryController,
  });

  @override
  State<PurchaseManagementPage> createState() => _PurchaseManagementPageState();
}

class _PurchaseManagementPageState extends State<PurchaseManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.purchaseController.fetchPurchases();
    widget.inventoryController.fetchMasters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPurchaseEntryDialog() {
    showDialog(
      context: context,
      builder: (_) => PurchaseEntryDialog(
        purchaseController: widget.purchaseController,
        inventoryController: widget.inventoryController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.purchaseController,
      builder: (context, _) {
        final ctrl = widget.purchaseController;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Entries',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Record purchases with dynamic masters & actual stock reflection',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Purchase Entry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _openPurchaseEntryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar & Stats
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by purchase #, remarks...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  ctrl.setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => ctrl.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Total Records: ${ctrl.purchases.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Error Banner
              if (ctrl.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ctrl.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),

              // Table or Empty State
              if (ctrl.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (ctrl.purchases.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No purchase entries found. Click "+ New Purchase Entry" to add one.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildPurchasesTable(ctrl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchasesTable(PurchaseController ctrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Purchase #', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Party Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Purchase Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total Actual (Stock)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total Billed Qty', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.purchases.map((purchase) {
            final dateStr =
                '${purchase.date.day.toString().padLeft(2, '0')}/${purchase.date.month.toString().padLeft(2, '0')}/${purchase.date.year}';

            final itemsCount = purchase.items.isNotEmpty ? purchase.items.length : 1;
            final firstItemName = purchase.items.isNotEmpty ? purchase.items.first.itemName : purchase.itemName;

            return DataRow(
              cells: [
                DataCell(Text(dateStr)),
                DataCell(
                  Text(
                    purchase.purchaseNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
                DataCell(Text(purchase.partyName, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(purchase.purchaseTypeName)),
                DataCell(
                  itemsCount > 1
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItemName.isNotEmpty ? firstItemName : 'Item',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${itemsCount - 1} more ($itemsCount items)',
                                style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          firstItemName.isNotEmpty ? firstItemName : '-',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${purchase.totalActualQuantity.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(purchase.totalBilledQuantity.toStringAsFixed(2))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                        tooltip: 'View Details',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PurchaseDetailDialog(purchase: purchase),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                        tooltip: 'Edit Purchase',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PurchaseEntryDialog(
                              purchaseController: ctrl,
                              inventoryController: widget.inventoryController,
                              existingPurchase: purchase,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete Purchase',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete Purchase Entry',
                              content:
                                  'Are you sure you want to delete purchase entry "${purchase.purchaseNumber}"? Stock added by this purchase will be reverted.',
                            ),
                          );
                          if (confirmed == true) {
                            final success = await ctrl.deletePurchase(purchase.id);
                            if (context.mounted && success) {
                              widget.inventoryController.fetchCurrentTabData();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
