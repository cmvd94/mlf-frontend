import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import '../../domain/entities/stock_transfer_entity.dart';
import '../controllers/stock_transfer_controller.dart';
import '../widgets/stock_transfer_entry_dialog.dart';
import '../widgets/stock_transfer_detail_dialog.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.successMessage ?? 'Stock transfer voucher created successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.successMessage ?? 'Stock transfer voucher updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.successMessage ?? 'Stock transfer deleted successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (_controller.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_controller.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _godownController]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildFilterBar(),
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
                          : _buildTransfersTable(),
                ),
                if (_controller.pagination.totalPages > 1) _buildPagination(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
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

  Widget _buildFilterBar() {
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

  Widget _buildTransfersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
              DataColumn(label: Text('Narration', style: TextStyle(fontWeight: FontWeight.bold))),
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
                    Text(
                      st.transferNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        st.narration.isNotEmpty ? st.narration : '-',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'View Voucher Details',
                          icon: const Icon(Icons.visibility, color: AppColors.primary, size: 20),
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
