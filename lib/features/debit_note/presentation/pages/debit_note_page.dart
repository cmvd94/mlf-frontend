import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../../domain/entities/debit_note_entity.dart';
import '../controllers/debit_note_controller.dart';
import '../widgets/debit_note_entry_dialog.dart';
import '../widgets/debit_note_detail_dialog.dart';

class DebitNotePage extends StatefulWidget {
  const DebitNotePage({super.key});

  @override
  State<DebitNotePage> createState() => _DebitNotePageState();
}

class _DebitNotePageState extends State<DebitNotePage> {
  late final DebitNoteController _debitNoteController;
  late final InventoryController _inventoryController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _debitNoteController = sl<DebitNoteController>();
    _inventoryController = sl<InventoryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debitNoteController.fetchDebitNotes();
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
      builder: (_) => const DebitNoteEntryDialog(),
    );

    if (result == true && mounted) {
      _debitNoteController.fetchDebitNotes(page: 1, reset: true);
    }
  }

  void _openEditDialog(DebitNoteEntity debitNote) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DebitNoteEntryDialog(debitNoteToEdit: debitNote),
    );

    if (result == true && mounted) {
      _debitNoteController.fetchDebitNotes(page: _debitNoteController.currentPage, reset: true);
    }
  }

  void _openDetailDialog(DebitNoteEntity debitNote) {
    showDialog(
      context: context,
      builder: (_) => DebitNoteDetailDialog(debitNote: debitNote),
    );
  }

  void _confirmDelete(DebitNoteEntity debitNote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Debit Note'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Debit Note "${debitNote.debitNoteNumber}"?\n\n'
          'This will cancel the debit note and restore the deducted stock back to the original godown batches.',
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
      final success = await _debitNoteController.deleteDebitNote(debitNote.id);
      if (mounted) {
        if (success) {
          AppNotification.showSuccess(context, 'Debit Note ${debitNote.debitNoteNumber} deleted and stock restored.');
        } else {
          AppNotification.showError(context, _debitNoteController.errorMessage ?? 'Failed to delete debit note.');
        }
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _debitNoteController.fromDate != null && _debitNoteController.toDate != null
          ? DateTimeRange(start: _debitNoteController.fromDate!, end: _debitNoteController.toDate!)
          : null,
    );

    if (picked != null) {
      _debitNoteController.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & New Debit Note Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debit Notes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage debit notes, voucher alterations, and stock deductions',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Debit Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: _openCreateDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Bar
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_debitNoteController, _inventoryController]),
                  builder: (context, _) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Search field
                        SizedBox(
                          width: 260,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search voucher, DC, lot, notes...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        _debitNoteController.setSearchQuery(null);
                                      },
                                    )
                                  : null,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (val) => _debitNoteController.setSearchQuery(val.trim()),
                          ),
                        ),

                        // Party Filter
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _debitNoteController.selectedPartyId,
                            decoration: InputDecoration(
                              labelText: 'Filter Party',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Parties')),
                              ..._inventoryController.parties.map((p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                                  )),
                            ],
                            onChanged: (val) => _debitNoteController.setPartyFilter(val),
                          ),
                        ),

                        // Godown Filter
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _debitNoteController.selectedGodownId,
                            decoration: InputDecoration(
                              labelText: 'Filter Godown',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Godowns')),
                              ..._inventoryController.godowns.map((g) => DropdownMenuItem(
                                    value: g.id,
                                    child: Text(g.name, overflow: TextOverflow.ellipsis),
                                  )),
                            ],
                            onChanged: (val) => _debitNoteController.setGodownFilter(val),
                          ),
                        ),

                        // Date Range Filter
                        OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            _debitNoteController.fromDate != null && _debitNoteController.toDate != null
                                ? '${_debitNoteController.fromDate!.day}/${_debitNoteController.fromDate!.month} - ${_debitNoteController.toDate!.day}/${_debitNoteController.toDate!.month}'
                                : 'Select Date Range',
                          ),
                          onPressed: _selectDateRange,
                        ),

                        // Clear filters
                        if (_searchController.text.isNotEmpty ||
                            _debitNoteController.selectedPartyId != null ||
                            _debitNoteController.selectedGodownId != null ||
                            _debitNoteController.fromDate != null)
                          TextButton.icon(
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear Filters'),
                            onPressed: () {
                              _searchController.clear();
                              _debitNoteController.clearFilters();
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Debit Notes Data Table Area
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: AnimatedBuilder(
                  animation: _debitNoteController,
                  builder: (context, _) {
                    if (_debitNoteController.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_debitNoteController.debitNotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No debit notes found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a new debit note entry using the button above.',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(label: Text('Voucher No', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Party (Customer)', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('DC No', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Items Count', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Total Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _debitNoteController.debitNotes.map((dn) {
                                  final dateStr =
                                      '${dn.date.day.toString().padLeft(2, '0')}/${dn.date.month.toString().padLeft(2, '0')}/${dn.date.year}';
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        InkWell(
                                          onTap: () => _openDetailDialog(dn),
                                          child: Text(
                                            dn.debitNoteNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(dateStr)),
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(dn.partyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            if (dn.partyCode.isNotEmpty)
                                              Text(dn.partyCode, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(dn.salesTypeName.isNotEmpty ? dn.salesTypeName : '-')),
                                      DataCell(Text(dn.dcNo.isNotEmpty ? dn.dcNo : '-')),
                                      DataCell(Text('${dn.items.length} item(s)')),
                                      DataCell(Text(
                                        dn.totalActualQuantity.toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                      )),
                                      DataCell(Text(
                                        '₹ ${dn.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: 'View Details',
                                              icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                              onPressed: () => _openDetailDialog(dn),
                                            ),
                                            IconButton(
                                              tooltip: 'Alter / Edit',
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                                              onPressed: () => _openEditDialog(dn),
                                            ),
                                            IconButton(
                                              tooltip: 'Delete',
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                              onPressed: () => _confirmDelete(dn),
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

                        // Pagination bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing ${_debitNoteController.debitNotes.length} of ${_debitNoteController.totalCount} entries',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _debitNoteController.currentPage > 1
                                        ? () => _debitNoteController.fetchDebitNotes(
                                            page: _debitNoteController.currentPage - 1)
                                        : null,
                                  ),
                                  Text(
                                    'Page ${_debitNoteController.currentPage} of ${_debitNoteController.totalPages}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _debitNoteController.currentPage < _debitNoteController.totalPages
                                        ? () => _debitNoteController.fetchDebitNotes(
                                            page: _debitNoteController.currentPage + 1)
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
