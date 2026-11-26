import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import '../../domain/entities/stock_transfer_entity.dart';
import '../controllers/stock_transfer_controller.dart';
import '../widgets/stock_transfer_entry_dialog.dart';
import '../widgets/stock_transfer_detail_dialog.dart';
import '../widgets/stock_transfer_challan_dialog.dart';

class StockTransferPage extends StatefulWidget {
  const StockTransferPage({super.key});

  @override
  State<StockTransferPage> createState() => _StockTransferPageState();
}

class _StockTransferPageState extends State<StockTransferPage> {
  late final StockTransferController _controller;
  late final GodownController _godownController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = sl<StockTransferController>();
    _godownController = sl<GodownController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _godownController.setTypeFilter(null);
      _godownController.setSearch(null);
      _controller.fetchStockTransfers();
      _godownController.fetchGodowns();
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
      builder: (_) => const StockTransferEntryDialog(),
    );

    if (result == true && mounted) {
      AppNotification.showSuccess(
        context,
        _controller.successMessage ?? 'Stock transfer voucher created successfully!',
      );
    }
  }

  void _openEditDialog(StockTransferEntity st) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StockTransferEntryDialog(transferToEdit: st),
    );

    if (result == true && mounted) {
      AppNotification.showSuccess(
        context,
        _controller.successMessage ?? 'Stock transfer voucher updated successfully!',
      );
    }
  }

  void _openDetailDialog(StockTransferEntity st) {
    showDialog(
      context: context,
      builder: (_) => StockTransferDetailDialog(
        transfer: st,
        onEdit: () => _openEditDialog(st),
        onDelete: () => _confirmDelete(st),
      ),
    );
  }

  void _openChallanDialog(StockTransferEntity st) {
    showDialog(
      context: context,
      builder: (_) => StockTransferChallanDialog(transfer: st),
    );
  }

  void _confirmDelete(StockTransferEntity st) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Stock Transfer'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Voucher "${st.transferNumber}"?\n\n'
          'This will revert the transfer: produced destination batches will be removed '
          'and consumed items will be restored back to source godowns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete & Restore Stock'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _controller.deleteStockTransfer(st.id);
      if (mounted) {
        if (success) {
          AppNotification.showSuccess(
            context,
            _controller.successMessage ?? 'Stock transfer deleted successfully!',
          );
        } else if (_controller.errorMessage != null) {
          AppNotification.showError(
            context,
            _controller.errorMessage!,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _godownController]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 12),
                _buildFilterBar(isMobile),
                const SizedBox(height: 12),
                if (_controller.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _controller.errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _controller.clearMessages(),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _controller.transfers.isEmpty
                          ? _buildEmptyState()
                          : _buildTransfersTable(isMobile),
                ),
                if (_controller.pagination.totalPages > 1) _buildPagination(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Stock Transfer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Stock Journal • Transfer of Materials (Source ➔ Destination)',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('New Stock Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock Transfer / Inventory Transfer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Stock Journal • Transfer of Materials (Source Consumption ➔ Destination Production)',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: _openCreateDialog,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('New Stock Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFilterBar(bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Voucher, DC, Lot...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery(null);
                        },
                      )
                    : null,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (val) => _controller.setSearchQuery(val.trim().isEmpty ? null : val.trim()),
            ),
            if (_godownController.godowns.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _controller.selectedGodownId,
                      isDense: true,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Godown',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Godowns', style: TextStyle(fontSize: 13))),
                        ..._godownController.godowns.map(
                          (g) => DropdownMenuItem(value: g.id, child: Text(g.name, style: const TextStyle(fontSize: 13))),
                        ),
                      ],
                      onChanged: (val) => _controller.setGodownFilter(val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: () => _controller.fetchStockTransfers(page: 1, reset: true),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Voucher #, DC #, Lot # or Narration...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery(null);
                        },
                      )
                    : null,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (val) => _controller.setSearchQuery(val.trim().isEmpty ? null : val.trim()),
            ),
          ),
          const SizedBox(width: 12),
          if (_godownController.godowns.isNotEmpty)
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String?>(
                value: _controller.selectedGodownId,
                isDense: true,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Filter by Godown',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Godowns', style: TextStyle(fontSize: 13))),
                  ..._godownController.godowns.map(
                    (g) => DropdownMenuItem(value: g.id, child: Text(g.name, style: const TextStyle(fontSize: 13))),
                  ),
                ],
                onChanged: (val) => _controller.setGodownFilter(val),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => _controller.fetchStockTransfers(page: 1, reset: true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_alt, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No Stock Transfer vouchers found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Transfer materials between godowns or transform items by clicking "New Stock Transfer".',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create First Transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersTable(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isMobile) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.swipe, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Swipe horizontally to view all transfer details',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Scrollbar(
              thumbVisibility: isMobile,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('Voucher #', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Source (Consumption)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
              DataColumn(label: Text('Destination (Production)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
              DataColumn(label: Text('Source Qty', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Dest Qty', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _controller.transfers.map((st) {
              final localDate = st.date.toLocal();
              final formattedDate =
                  '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';

              final sourceSummary = st.sourceItems.map((it) {
                final batchText = it.batchNo.isNotEmpty ? ' [${it.batchNo}]' : '';
                return '${it.itemName}$batchText (${it.godownName})';
              }).join(', ');

              final destSummary = st.destinationItems.map((it) {
                final batchText = it.batchNo.isNotEmpty ? ' [${it.batchNo}]' : '';
                return '${it.itemName}$batchText (${it.godownName})';
              }).join(', ');

              return DataRow(
                cells: [
                  DataCell(
                    InkWell(
                      onTap: () => _openChallanDialog(st),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            st.transferNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          if (st.isGst) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.shade400, width: 0.8),
                              ),
                              child: Text(
                                'GST',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(formattedDate)),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        sourceSummary,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        destSummary,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${st.totalSourceQuantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${st.totalDestinationQuantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Print Delivery Challan',
                          icon: const Icon(Icons.print_outlined, color: AppColors.primary, size: 20),
                          onPressed: () => _openChallanDialog(st),
                        ),
                        IconButton(
                          tooltip: 'View Voucher Details',
                          icon: const Icon(Icons.visibility, color: AppColors.primaryLight, size: 20),
                          onPressed: () => _openDetailDialog(st),
                        ),
                        IconButton(
                          tooltip: 'Edit Voucher',
                          icon: const Icon(Icons.edit, color: AppColors.primaryLight, size: 20),
                          onPressed: () => _openEditDialog(st),
                        ),
                        IconButton(
                          tooltip: 'Delete Voucher',
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(st),
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
  ),
),
],
);
  }

  Widget _buildPagination() {
    final p = _controller.pagination;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${p.currentPage} of ${p.totalPages} (Total ${p.totalCount} vouchers)',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: p.currentPage > 1
                    ? () => _controller.fetchStockTransfers(page: p.currentPage - 1)
                    : null,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: p.currentPage < p.totalPages
                    ? () => _controller.fetchStockTransfers(page: p.currentPage + 1)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
