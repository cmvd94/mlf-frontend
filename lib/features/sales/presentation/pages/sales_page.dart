import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';
import '../widgets/sales_entry_dialog.dart';
import '../widgets/sales_detail_dialog.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late final SalesController _salesController;
  late final InventoryController _inventoryController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _salesController = sl<SalesController>();
    _inventoryController = sl<InventoryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _salesController.fetchSales();
      _inventoryController.fetchMasters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SalesEntryDialog(),
    );

    if (result == true && mounted) {
      _salesController.fetchSales(page: 1, reset: true);
    }
  }

  void _openEditDialog(SaleEntity sale) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SalesEntryDialog(saleToEdit: sale),
    );

    if (result == true && mounted) {
      _salesController.fetchSales(page: _salesController.currentPage, reset: true);
    }
  }

  void _openDetailDialog(SaleEntity sale) {
    showDialog(
      context: context,
      builder: (_) => SalesDetailDialog(sale: sale),
    );
  }

  void _confirmDelete(SaleEntity sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Sale Voucher'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Voucher "${sale.salesNumber}"?\n\n'
          'This will cancel the sale and restore the sold stock back to the original godown batches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete & Restore Stock'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await _salesController.deleteSale(sale.id);
        if (mounted) {
          if (success) {
            AppNotification.showSuccess(
              context,
              _salesController.successMessage ?? 'Sale voucher deleted successfully!',
            );
          } else if (_salesController.errorMessage != null) {
            AppNotification.showError(context, _salesController.errorMessage!);
          }
        }
      } catch (e) {
        if (mounted) {
          AppNotification.showError(context, 'Failed to delete sale: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _salesController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildFilterBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: _salesController.isLoading && _salesController.sales.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _salesController.sales.isEmpty
                          ? _buildEmptyState()
                          : _buildSalesTable(),
                ),
                if (_salesController.sales.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildPaginationBar(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.point_of_sale, color: AppColors.primary, size: 26),
                SizedBox(width: 10),
                Text(
                  'Sales Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Sell items directly from Godown stock batches to registered customers',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _openCreateDialog,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('New Sale Entry', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Search Input
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search voucher, party, DC...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _salesController.setSearchQuery(null);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
                onSubmitted: (val) => _salesController.setSearchQuery(val.trim().isEmpty ? null : val.trim()),
              ),
            ),

            // Party Filter
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                value: _salesController.selectedPartyId,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'All Parties',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All Parties')),
                  ..._inventoryController.parties
                      .where((p) => p.isActive)
                      .map((p) => DropdownMenuItem<String?>(
                            value: p.id,
                            child: Text(p.name, overflow: TextOverflow.ellipsis),
                          )),
                ],
                onChanged: (val) => _salesController.setPartyFilter(val),
              ),
            ),

            // Clear Filters Button
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _salesController.clearFilters();
              },
              icon: const Icon(Icons.filter_alt_off, size: 16),
              label: const Text('Reset Filters'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            // Refresh Button
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: 'Refresh',
              onPressed: () => _salesController.fetchSales(page: _salesController.currentPage, reset: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.point_of_sale_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Sales Vouchers Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new sales voucher to sell stock directly from your godowns.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create First Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
              horizontalMargin: 16,
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Sales #', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Sales Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Party (Customer)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('DC #', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Items Summary', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('GST Status', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Net Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _salesController.sales.map((sale) {
                final dateStr =
                    '${sale.date.day.toString().padLeft(2, '0')}/${sale.date.month.toString().padLeft(2, '0')}/${sale.date.year}';

                final itemsDesc = sale.items.map((i) => '${i.itemName} (${i.actualQuantity.toStringAsFixed(1)} ${i.perSymbol})').join(', ');

                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _openDetailDialog(sale),
                        child: Text(
                          sale.salesNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                    DataCell(Text(dateStr)),
                    DataCell(Text(sale.salesTypeName.isNotEmpty ? sale.salesTypeName : '-')),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sale.partyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (sale.partyCode.isNotEmpty)
                            Text(sale.partyCode, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    DataCell(Text(sale.dcNo.isNotEmpty ? sale.dcNo : '-')),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          itemsDesc.isNotEmpty ? itemsDesc : '${sale.items.length} item(s)',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    DataCell(Text(sale.totalQuantity.toStringAsFixed(2))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: sale.isGstBill ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: sale.isGstBill ? Colors.green.shade200 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          sale.isGstBill ? 'GST (${sale.gstPercentage.toStringAsFixed(0)}%)' : 'Non-GST',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: sale.isGstBill ? Colors.green.shade800 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹ ${sale.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                            tooltip: 'View Details',
                            onPressed: () => _openDetailDialog(sale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                            tooltip: 'Edit Voucher',
                            onPressed: () => _openEditDialog(sale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            tooltip: 'Delete & Revert Stock',
                            onPressed: () => _confirmDelete(sale),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total: ${_salesController.totalCount} sales vouchers',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _salesController.currentPage > 1
                  ? () => _salesController.fetchSales(page: _salesController.currentPage - 1)
                  : null,
            ),
            Text(
              'Page ${_salesController.currentPage} of ${_salesController.totalPages}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _salesController.currentPage < _salesController.totalPages
                  ? () => _salesController.fetchSales(page: _salesController.currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
