import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../../domain/entities/credit_note_entity.dart';
import '../controllers/credit_note_controller.dart';
import '../widgets/credit_note_entry_dialog.dart';
import '../widgets/credit_note_detail_dialog.dart';

class CreditNotePage extends StatefulWidget {
  const CreditNotePage({super.key});

  @override
  State<CreditNotePage> createState() => _CreditNotePageState();
}

class _CreditNotePageState extends State<CreditNotePage> {
  late final CreditNoteController _creditNoteController;
  late final InventoryController _inventoryController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _creditNoteController = sl<CreditNoteController>();
    _inventoryController = sl<InventoryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _creditNoteController.fetchCreditNotes();
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
      builder: (_) => CreditNoteEntryDialog(
        creditNoteController: _creditNoteController,
        inventoryController: _inventoryController,
      ),
    );

    if (result == true && mounted) {
      _creditNoteController.fetchCreditNotes(page: 1, reset: true);
    }
  }

  void _openEditDialog(CreditNoteEntity creditNote) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreditNoteEntryDialog(
        creditNoteController: _creditNoteController,
        inventoryController: _inventoryController,
        existingCreditNote: creditNote,
      ),
    );

    if (result == true && mounted) {
      _creditNoteController.fetchCreditNotes(page: _creditNoteController.currentPage, reset: true);
    }
  }

  void _openDetailDialog(CreditNoteEntity creditNote) {
    showDialog(
      context: context,
      builder: (_) => CreditNoteDetailDialog(creditNote: creditNote),
    );
  }

  void _confirmDelete(CreditNoteEntity creditNote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Credit Note'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Credit Note "${creditNote.creditNoteNumber}"?\n\n'
          'This will cancel the credit note and reverse the stock batches created in the godowns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete & Revert Stock'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _creditNoteController.deleteCreditNote(creditNote.id);
      if (mounted) {
        if (success) {
          AppNotification.showSuccess(context, 'Credit Note ${creditNote.creditNoteNumber} deleted and stock reverted.');
        } else {
          AppNotification.showError(context, _creditNoteController.errorMessage ?? 'Failed to delete credit note.');
        }
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _creditNoteController.fromDate != null && _creditNoteController.toDate != null
          ? DateTimeRange(start: _creditNoteController.fromDate!, end: _creditNoteController.toDate!)
          : null,
    );

    if (picked != null) {
      _creditNoteController.setDateRange(picked.start, picked.end);
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit Notes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage credit notes, inward stock returns, and voucher alterations',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Credit Note'),
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
                  animation: Listenable.merge([_creditNoteController, _inventoryController]),
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
                              hintText: 'Search voucher, DC, notes...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        _creditNoteController.setSearchQuery(null);
                                      },
                                    )
                                  : null,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (val) => _creditNoteController.setSearchQuery(val.trim()),
                          ),
                        ),

                        // Party Filter
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _creditNoteController.selectedPartyId,
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
                            onChanged: (val) => _creditNoteController.setPartyFilter(val),
                          ),
                        ),

                        // Godown Filter
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _creditNoteController.selectedGodownId,
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
                            onChanged: (val) => _creditNoteController.setGodownFilter(val),
                          ),
                        ),

                        // Date Range Filter
                        OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            _creditNoteController.fromDate != null && _creditNoteController.toDate != null
                                ? '${_creditNoteController.fromDate!.day}/${_creditNoteController.fromDate!.month} - ${_creditNoteController.toDate!.day}/${_creditNoteController.toDate!.month}'
                                : 'Select Date Range',
                          ),
                          onPressed: _selectDateRange,
                        ),

                        // Clear filters
                        if (_searchController.text.isNotEmpty ||
                            _creditNoteController.selectedPartyId != null ||
                            _creditNoteController.selectedGodownId != null ||
                            _creditNoteController.fromDate != null)
                          TextButton.icon(
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear Filters'),
                            onPressed: () {
                              _searchController.clear();
                              _creditNoteController.clearFilters();
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Credit Notes Data Table Area
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: AnimatedBuilder(
                  animation: _creditNoteController,
                  builder: (context, _) {
                    if (_creditNoteController.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_creditNoteController.creditNotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No credit notes found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a new credit note entry using the button above.',
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
                                  DataColumn(label: Text('Party (Supplier/Customer)', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Company Godown', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Items Count', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Total Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _creditNoteController.creditNotes.map((cn) {
                                  final dateStr =
                                      '${cn.date.day.toString().padLeft(2, '0')}/${cn.date.month.toString().padLeft(2, '0')}/${cn.date.year}';
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        InkWell(
                                          onTap: () => _openDetailDialog(cn),
                                          child: Text(
                                            cn.creditNoteNumber,
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
                                            Text(cn.partyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            if (cn.partyCode.isNotEmpty)
                                              Text(cn.partyCode, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(cn.purchaseTypeName.isNotEmpty ? cn.purchaseTypeName : '-')),
                                      DataCell(Text(cn.companyGodownName.isNotEmpty ? cn.companyGodownName : '-')),
                                      DataCell(Text('${cn.items.length} item(s)')),
                                      DataCell(Text(
                                        cn.totalActualQuantity.toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      )),
                                      DataCell(Text(
                                        '₹ ${cn.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: 'View Details',
                                              icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                              onPressed: () => _openDetailDialog(cn),
                                            ),
                                            IconButton(
                                              tooltip: 'Alter / Edit',
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                                              onPressed: () => _openEditDialog(cn),
                                            ),
                                            IconButton(
                                              tooltip: 'Delete',
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                              onPressed: () => _confirmDelete(cn),
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
                                'Showing ${_creditNoteController.creditNotes.length} of ${_creditNoteController.totalCount} entries',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _creditNoteController.currentPage > 1
                                        ? () => _creditNoteController.fetchCreditNotes(
                                            page: _creditNoteController.currentPage - 1)
                                        : null,
                                  ),
                                  Text(
                                    'Page ${_creditNoteController.currentPage} of ${_creditNoteController.totalPages}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _creditNoteController.currentPage < _creditNoteController.totalPages
                                        ? () => _creditNoteController.fetchCreditNotes(
                                            page: _creditNoteController.currentPage + 1)
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
