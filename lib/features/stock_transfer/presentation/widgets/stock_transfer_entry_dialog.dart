import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../../domain/entities/available_stock_entity.dart';
import '../../domain/entities/stock_transfer_entity.dart';
import '../controllers/stock_transfer_controller.dart';

class _SourceItemRow {
  AvailableStockEntity? selectedStock;
  String? uomId;
  final TextEditingController uomQtyController = TextEditingController(text: '1');
  final TextEditingController quantityController = TextEditingController();

  double get uomQuantity => double.tryParse(uomQtyController.text.trim()) ?? 1.0;
  double get quantity => double.tryParse(quantityController.text.trim()) ?? 0.0;

  void dispose() {
    uomQtyController.dispose();
    quantityController.dispose();
  }
}

class _DestinationItemRow {
  String? itemId;
  String? godownId;
  String? uomId;
  final TextEditingController batchNoController = TextEditingController();
  final TextEditingController uomQtyController = TextEditingController(text: '1');
  final TextEditingController quantityController = TextEditingController();

  double get uomQuantity => double.tryParse(uomQtyController.text.trim()) ?? 1.0;
  double get quantity => double.tryParse(quantityController.text.trim()) ?? 0.0;

  void dispose() {
    batchNoController.dispose();
    uomQtyController.dispose();
    quantityController.dispose();
  }
}

class StockTransferEntryDialog extends StatefulWidget {
  const StockTransferEntryDialog({super.key});

  @override
  State<StockTransferEntryDialog> createState() => _StockTransferEntryDialogState();
}

class _StockTransferEntryDialogState extends State<StockTransferEntryDialog> {
  late final StockTransferController _transferController;
  late final InventoryController _inventoryController;
  late final GodownController _godownController;

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _narrationController = TextEditingController();
  String? _filterSourceGodownId;

  final List<_SourceItemRow> _sourceRows = [];
  final List<_DestinationItemRow> _destRows = [];

  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _transferController = sl<StockTransferController>();
    _inventoryController = sl<InventoryController>();
    _godownController = sl<GodownController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      _transferController.fetchAvailableStocks(),
      _inventoryController.fetchMasters(),
      _godownController.fetchGodowns(),
    ]);

    if (mounted && _sourceRows.isEmpty) {
      _addSourceRow();
    }
    if (mounted && _destRows.isEmpty) {
      _addDestinationRow();
    }
    if (mounted) {
      setState(() => _isInit = false);
    }
  }

  void _addSourceRow() {
    setState(() {
      final row = _SourceItemRow();
      row.uomQtyController.addListener(() => setState(() {}));
      row.quantityController.addListener(() => setState(() {}));
      _sourceRows.add(row);
    });
  }

  void _removeSourceRow(int index) {
    if (_sourceRows.length <= 1) return;
    setState(() {
      _sourceRows[index].dispose();
      _sourceRows.removeAt(index);
    });
  }

  void _addDestinationRow() {
    setState(() {
      final row = _DestinationItemRow();
      // Pre-select first item or source item if available
      if (_inventoryController.items.isNotEmpty) {
        final it = _inventoryController.items.first;
        row.itemId = it.id;
        if (it.defaultUomId != null && it.defaultUomId!.isNotEmpty) {
          row.uomId = it.defaultUomId;
        }
      }
      if (_godownController.godowns.isNotEmpty) {
        row.godownId = _godownController.godowns.first.id;
      }
      row.uomQtyController.addListener(() => setState(() {}));
      row.quantityController.addListener(() => setState(() {}));
      _destRows.add(row);
    });
  }

  void _removeDestinationRow(int index) {
    if (_destRows.length <= 1) return;
    setState(() {
      _destRows[index].dispose();
      _destRows.removeAt(index);
    });
  }

  @override
  void dispose() {
    _narrationController.dispose();
    for (final r in _sourceRows) {
      r.dispose();
    }
    for (final r in _destRows) {
      r.dispose();
    }
    super.dispose();
  }

  double get _totalSourceQuantity => _sourceRows.fold(0.0, (sum, r) => sum + r.quantity);
  double get _totalDestQuantity => _destRows.fold(0.0, (sum, r) => sum + r.quantity);

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    // Basic UI input validations before submitting to backend
    for (int i = 0; i < _sourceRows.length; i++) {
      final r = _sourceRows[i];
      if (r.selectedStock == null) {
        _showError('Please select a source stock batch for line ${i + 1}');
        return;
      }
      if (r.quantity <= 0) {
        _showError('Source quantity for line ${i + 1} must be greater than 0');
        return;
      }
      if (r.quantity > r.selectedStock!.currentStock) {
        _showError(
          'Quantity for batch "${r.selectedStock!.batchNo}" exceeds available stock (${r.selectedStock!.currentStock})',
        );
        return;
      }
    }

    for (int i = 0; i < _destRows.length; i++) {
      final r = _destRows[i];
      if (r.itemId == null || r.itemId!.isEmpty) {
        _showError('Please select a destination item for line ${i + 1}');
        return;
      }
      if (r.godownId == null || r.godownId!.isEmpty) {
        _showError('Please select a destination godown for line ${i + 1}');
        return;
      }
      if (r.batchNoController.text.trim().isEmpty) {
        _showError('Please enter a new Batch / Lot number for destination line ${i + 1}');
        return;
      }
      if (r.quantity <= 0) {
        _showError('Destination quantity for line ${i + 1} must be greater than 0');
        return;
      }
    }

    final sourceInputs = _sourceRows
        .map((r) => CreateStockTransferSourceInput(
              godownStockId: r.selectedStock!.godownStockId,
              uomId: r.uomId,
              uomQuantity: r.uomQuantity,
              quantity: r.quantity,
            ))
        .toList();

    final destInputs = _destRows
        .map((r) => CreateStockTransferDestinationInput(
              itemId: r.itemId!,
              godownId: r.godownId!,
              batchNo: r.batchNoController.text.trim(),
              uomId: r.uomId,
              uomQuantity: r.uomQuantity,
              quantity: r.quantity,
            ))
        .toList();

    final success = await _transferController.createStockTransfer(
      date: _selectedDate,
      sourceItems: sourceInputs,
      destinationItems: destInputs,
      narration: _narrationController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted && _transferController.errorMessage != null) {
      _showError(_transferController.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    final formattedDate =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isDesktop ? 1150 : double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        padding: const EdgeInsets.all(20),
        child: _isInit
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.compare_arrows, color: AppColors.primaryDark, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inventory Voucher Creation - Stock Journal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Transfer of Materials (Source Consumption ➔ Destination Production)',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  const SizedBox(height: 12),

                  // Date Picker & Godown Filter Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Voucher Date: $formattedDate',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _selectDate,
                              child: const Text('Change Date'),
                            ),
                          ],
                        ),
                        if (_godownController.godowns.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Filter Stock by Godown: ', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              DropdownButton<String?>(
                                value: _filterSourceGodownId,
                                hint: const Text('All Godowns', style: TextStyle(fontSize: 12)),
                                isDense: true,
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('All Godowns', style: TextStyle(fontSize: 12))),
                                  ..._godownController.godowns.map(
                                    (g) => DropdownMenuItem(
                                      value: g.id,
                                      child: Text(g.name, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() => _filterSourceGodownId = val);
                                  _transferController.fetchAvailableStocks(godownId: val);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Main Content: Side by Side on Desktop / Stacked on Mobile
                  Expanded(
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildSourcePanel()),
                              const SizedBox(width: 14),
                              Expanded(child: _buildDestinationPanel()),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildSourcePanel(),
                                const SizedBox(height: 16),
                                _buildDestinationPanel(),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom Bar: Narration & Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _narrationController,
                          decoration: const InputDecoration(
                            labelText: 'Narration / Notes',
                            hintText: 'Enter reason or job reference for transfer...',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Source Qty: $_totalSourceQuantity',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            'Destination Qty: $_totalDestQuantity',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: _transferController,
                        builder: (context, _) => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          onPressed: _transferController.isSaving ? null : _submit,
                          child: _transferController.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Save Stock Transfer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  // LEFT SIDE: Source (Consumption)
  Widget _buildSourcePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.outbox, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Source (Consumption)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addSourceRow,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Row', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable item list
          Expanded(
            child: ListView.separated(
              itemCount: _sourceRows.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final row = _sourceRows[index];
                return _buildSourceRowWidget(row, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceRowWidget(_SourceItemRow row, int index) {
    final availableList = _transferController.availableStocks;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Item #${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
              ),
              const Spacer(),
              if (_sourceRows.length > 1)
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  onPressed: () => _removeSourceRow(index),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Stock batch selector
          DropdownButtonFormField<AvailableStockEntity>(
            value: row.selectedStock,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Stock Batch (Godown • Item • Batch)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: availableList.map((s) {
              return DropdownMenuItem<AvailableStockEntity>(
                value: s,
                child: Text(
                  s.displayName,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (selected) {
              setState(() {
                row.selectedStock = selected;
                if (selected != null) {
                  if (selected.uomId.isNotEmpty) {
                    row.uomId = selected.uomId;
                  }
                  row.uomQtyController.text = (selected.uomQuantity > 0 ? selected.uomQuantity : 1.0).toString();
                  if (row.quantityController.text.isEmpty) {
                    row.quantityController.text = selected.currentStock.toString();
                  }
                }
              });
            },
          ),
          const SizedBox(height: 8),

          // UOM & UOM Quantity & Quantity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<String>(
                  value: row.uomId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'UOM',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: _inventoryController.uoms.map((u) {
                    return DropdownMenuItem<String>(
                      value: u.id,
                      child: Text(
                        '${u.name} (${u.symbol})',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => row.uomId = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: row.uomQtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'UOM Qty',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: row.quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    isDense: true,
                    border: const OutlineInputBorder(),
                    helperText: row.selectedStock != null ? 'Avail: ${row.selectedStock!.currentStock}' : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // RIGHT SIDE: Destination (Production / Movement)
  Widget _buildDestinationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.move_to_inbox, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Destination (Production)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addDestinationRow,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Row', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable item list
          Expanded(
            child: ListView.separated(
              itemCount: _destRows.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final row = _destRows[index];
                return _buildDestinationRowWidget(row, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationRowWidget(_DestinationItemRow row, int index) {
    final allItems = _inventoryController.items;
    final allGodowns = _godownController.godowns;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Item #${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
              ),
              const Spacer(),
              if (_destRows.length > 1)
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  onPressed: () => _removeDestinationRow(index),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Item selection (can be same item or newly formed item)
          DropdownButtonFormField<String>(
            value: row.itemId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Name of Item (Same or New Formed Item)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: allItems.map((it) {
              return DropdownMenuItem<String>(
                value: it.id,
                child: Text(
                  '${it.name} (${it.itemCode})',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                row.itemId = val;
                final it = allItems.firstWhere((item) => item.id == val);
                if (it.defaultUomId != null && it.defaultUomId!.isNotEmpty) {
                  row.uomId = it.defaultUomId;
                }
              });
            },
          ),
          const SizedBox(height: 8),

          // Destination Godown & New Batch / Lot No.
          Row(
            children: [
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<String>(
                  value: row.godownId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Destination Godown',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: allGodowns.map((g) {
                    return DropdownMenuItem<String>(
                      value: g.id,
                      child: Text(
                        g.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => row.godownId = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: row.batchNoController,
                  decoration: const InputDecoration(
                    labelText: 'New Batch / Lot No.',
                    hintText: 'e.g. Dc174/7-10-26',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // UOM & UOM Quantity & Quantity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<String>(
                  value: row.uomId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'UOM',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: _inventoryController.uoms.map((u) {
                    return DropdownMenuItem<String>(
                      value: u.id,
                      child: Text(
                        '${u.name} (${u.symbol})',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => row.uomId = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: row.uomQtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'UOM Qty',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: row.quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
