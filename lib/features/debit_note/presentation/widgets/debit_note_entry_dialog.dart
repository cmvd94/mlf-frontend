import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/constants/app_constants.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/available_stock_entity.dart';
import '../../domain/entities/debit_note_entity.dart';
import '../controllers/debit_note_controller.dart';

class _DebitNoteItemRowData {
  String? godownStockId;
  String? itemId;
  String? godownId;
  String? uomId;
  String? perId;
  double maxAvailableStock = 0.0;

  final TextEditingController lotNoController;
  final TextEditingController uomQtyController;
  final TextEditingController actualQtyController;
  final TextEditingController billedQtyController;
  final TextEditingController rateController;

  _DebitNoteItemRowData({
    this.godownStockId,
    this.itemId,
    this.godownId,
    this.uomId,
    this.perId,
    this.maxAvailableStock = 0.0,
    String lotNo = '',
    String uomQty = '1',
    String actualQty = '1',
    String billedQty = '1',
    String rate = '',
    VoidCallback? onChanged,
  })  : lotNoController = TextEditingController(text: lotNo),
        uomQtyController = TextEditingController(text: uomQty),
        actualQtyController = TextEditingController(text: actualQty),
        billedQtyController = TextEditingController(text: billedQty),
        rateController = TextEditingController(text: rate) {
    if (onChanged != null) {
      actualQtyController.addListener(onChanged);
      billedQtyController.addListener(onChanged);
      rateController.addListener(onChanged);
    }
  }

  double get uomQuantity => double.tryParse(uomQtyController.text.trim()) ?? 1.0;
  double get actualQuantity => double.tryParse(actualQtyController.text.trim()) ?? 0.0;
  double get billedQuantity => double.tryParse(billedQtyController.text.trim()) ?? actualQuantity;
  double get rate => double.tryParse(rateController.text.trim()) ?? 0.0;

  void dispose() {
    lotNoController.dispose();
    uomQtyController.dispose();
    actualQtyController.dispose();
    billedQtyController.dispose();
    rateController.dispose();
  }
}

class DebitNoteEntryDialog extends StatefulWidget {
  final DebitNoteEntity? debitNoteToEdit;

  const DebitNoteEntryDialog({super.key, this.debitNoteToEdit});

  @override
  State<DebitNoteEntryDialog> createState() => _DebitNoteEntryDialogState();
}

class _DebitNoteEntryDialogState extends State<DebitNoteEntryDialog> {
  late final DebitNoteController _debitNoteController;
  late final InventoryController _inventoryController;

  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.debitNoteToEdit != null;

  late DateTime _selectedDate;
  String? _selectedTypeId;
  String? _selectedPartyId;
  late final TextEditingController _dcNoController;

  bool _isGstBill = false;
  double _selectedGstPercentage = AppConstants.defaultGstPercentage;

  late final TextEditingController _notesController;
  final List<_DebitNoteItemRowData> _rows = [];

  bool _isInit = true;
  bool _isFullScreen = false;
  String? _formErrorMessage;

  static const List<double> _gstOptions = [0, 5, 12, 18, 28];

  @override
  void initState() {
    super.initState();
    _debitNoteController = sl<DebitNoteController>();
    _inventoryController = sl<InventoryController>();

    final d = widget.debitNoteToEdit;
    final initialDate = d?.date.toLocal() ?? DateTime.now();
    _selectedDate = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _selectedTypeId = d?.salesTypeId.isNotEmpty ?? false ? d?.salesTypeId : null;
    _selectedPartyId = d?.partyId.isNotEmpty ?? false ? d?.partyId : null;
    _dcNoController = TextEditingController(text: d?.dcNo ?? '');
    _notesController = TextEditingController(text: d?.notes.isNotEmpty ?? false ? d!.notes : (d?.narration ?? ''));

    _isGstBill = d?.isGstBill ?? false;
    _selectedGstPercentage = (d != null && d.gstPercentage > 0)
        ? d.gstPercentage
        : AppConstants.defaultGstPercentage;

    if (d != null && d.items.isNotEmpty) {
      for (final it in d.items) {
        _rows.add(_DebitNoteItemRowData(
          godownStockId: it.godownStockId,
          itemId: it.itemId,
          godownId: it.godownId,
          uomId: it.uomId,
          perId: it.perId,
          lotNo: it.lotNo,
          uomQty: it.uomQuantity.toString(),
          actualQty: it.actualQuantity.toString(),
          billedQty: it.billedQuantity.toString(),
          rate: it.rate.toString(),
          maxAvailableStock: it.actualQuantity + 999999,
          onChanged: () => setState(() {}),
        ));
      }
    } else {
      _rows.add(_DebitNoteItemRowData(onChanged: () => setState(() {})));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInit = true);
    try {
      await Future.wait([
        _inventoryController.fetchMasters(),
        _debitNoteController.fetchAvailableStocks(),
      ]);

      if (_selectedTypeId == null && _inventoryController.salesTypes.isNotEmpty) {
        final active = _inventoryController.salesTypes.where((st) => st.isActive).firstOrNull;
        if (active != null) {
          _selectedTypeId = active.id;
        }
      }
    } catch (e) {
      AppLogger().e('Error in _loadInitialData: $e', tag: 'DebitNoteEntry');
    } finally {
      if (mounted) {
        setState(() => _isInit = false);
      }
    }
  }

  @override
  void dispose() {
    _dcNoController.dispose();
    _notesController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_DebitNoteItemRowData(onChanged: () => setState(() {})));
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) {
      AppNotification.showError(context, 'At least one item is required in a debit note');
      return;
    }
    setState(() {
      final removed = _rows.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onItemChanged(_DebitNoteItemRowData row, String? itemId) {
    setState(() {
      row.itemId = itemId;
      if (itemId == null || itemId.isEmpty) {
        row.godownStockId = null;
        row.godownId = null;
        row.maxAvailableStock = 0.0;
        return;
      }

      final itemDoc = _inventoryController.items.where((it) => it.id == itemId).firstOrNull;
      final stocksForItem = _debitNoteController.availableStocks
          .where((s) => s.itemId == itemId && s.currentStock > 0)
          .toList();

      if (stocksForItem.isNotEmpty) {
        final stock = stocksForItem.first;
        _applyStockToRow(row, stock, itemDoc);
      } else {
        row.godownStockId = null;
        row.godownId = null;
        row.maxAvailableStock = 0.0;
        if (itemDoc != null) {
          if (itemDoc.defaultUomId.isNotEmpty) row.uomId = itemDoc.defaultUomId;
          if (itemDoc.defaultPerId.isNotEmpty) row.perId = itemDoc.defaultPerId;
          if (row.rateController.text.isEmpty && itemDoc.standardRate > 0) {
            row.rateController.text = itemDoc.standardRate.toString();
          }
        }
      }
    });
  }

  void _applyStockToRow(_DebitNoteItemRowData row, AvailableStockEntity stock, dynamic itemDoc) {
    row.godownStockId = stock.godownStockId;
    row.godownId = stock.godownId;
    row.maxAvailableStock = stock.currentStock;
    row.lotNoController.text = stock.lotNo;
    row.uomId = stock.uomId.isNotEmpty ? stock.uomId : itemDoc?.defaultUomId;
    row.perId = stock.perId.isNotEmpty ? stock.perId : itemDoc?.defaultPerId;
    row.uomQtyController.text = stock.uomQuantity > 0 ? stock.uomQuantity.toString() : '1';
    if (row.actualQtyController.text.isEmpty || row.actualQtyController.text == '0') {
      row.actualQtyController.text = '1';
    }
    if (row.billedQtyController.text.isEmpty || row.billedQtyController.text == '0') {
      row.billedQtyController.text = row.actualQtyController.text;
    }
    if (stock.rate > 0) {
      row.rateController.text = stock.rate.toString();
    } else if (itemDoc != null && itemDoc.standardRate > 0) {
      row.rateController.text = itemDoc.standardRate.toString();
    }
  }

  void _onStockBatchSelected(_DebitNoteItemRowData row, String? godownStockId) {
    if (godownStockId == null) return;
    final stock = _debitNoteController.availableStocks.where((s) => s.godownStockId == godownStockId).firstOrNull;
    if (stock != null) {
      final itemDoc = _inventoryController.items.where((it) => it.id == row.itemId).firstOrNull;
      setState(() {
        _applyStockToRow(row, stock, itemDoc);
      });
    }
  }

  double get _estimatedSubTotal {
    double total = 0.0;
    for (final row in _rows) {
      double multiplier = 1.0;
      if (row.perId != null) {
        final perDoc = _inventoryController.perUnits
            .where((p) => p.id == row.perId)
            .firstOrNull;
        if (perDoc != null && perDoc.multiplier > 0) multiplier = perDoc.multiplier;
      }
      total += (row.billedQuantity * row.rate) / multiplier;
    }
    return total;
  }

  double get _estimatedTotalAmount {
    if (!_isGstBill) return _estimatedSubTotal;
    final gst = (_estimatedSubTotal * _selectedGstPercentage) / 100;
    return _estimatedSubTotal + gst;
  }

  Future<void> _handleSubmit() async {
    setState(() => _formErrorMessage = null);

    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_selectedPartyId == null || _selectedPartyId!.isEmpty) {
        setState(() => _formErrorMessage = 'Please select a Party.');
        return;
      }

      final itemsPayload = <DebitNoteItemInput>[];
      for (int i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        if (row.itemId == null || row.itemId!.isEmpty) {
          setState(() => _formErrorMessage = 'Row ${i + 1}: Please select an Item.');
          return;
        }
        if (row.godownStockId == null || row.godownStockId!.isEmpty) {
          setState(() => _formErrorMessage = 'Row ${i + 1}: Please select an available Stock Batch.');
          return;
        }
        if (row.actualQuantity <= 0) {
          setState(() => _formErrorMessage = 'Row ${i + 1}: Actual Quantity must be greater than 0.');
          return;
        }
        if (!_isEditMode && row.actualQuantity > row.maxAvailableStock) {
          setState(() => _formErrorMessage =
              'Row ${i + 1}: Quantity (${row.actualQuantity}) exceeds available stock (${row.maxAvailableStock}).');
          return;
        }
        if (row.uomId == null || row.uomId!.isEmpty) {
          setState(() => _formErrorMessage = 'Row ${i + 1}: Please select a Unit (UOM).');
          return;
        }
        if (row.perId == null || row.perId!.isEmpty) {
          setState(() => _formErrorMessage = 'Row ${i + 1}: Please select Per Unit.');
          return;
        }

        itemsPayload.add(DebitNoteItemInput(
          godownStockId: row.godownStockId!,
          itemId: row.itemId,
          godownId: row.godownId,
          dcNo: _dcNoController.text.trim(),
          lotNo: row.lotNoController.text.trim(),
          uomId: row.uomId,
          uomQuantity: row.uomQuantity,
          actualQuantity: row.actualQuantity,
          billedQuantity: row.billedQuantity,
          rate: row.rate,
          perId: row.perId,
        ));
      }

      bool success;
      if (_isEditMode) {
        final input = DebitNoteUpdateInput(
          date: _selectedDate,
          salesTypeId: _selectedTypeId,
          partyId: _selectedPartyId,
          dcNo: _dcNoController.text.trim(),
          items: itemsPayload,
          isGstBill: _isGstBill,
          gstPercentage: _isGstBill ? _selectedGstPercentage : 0.0,
          notes: _notesController.text.trim(),
          narration: _notesController.text.trim(),
        );
        success = await _debitNoteController.updateDebitNote(widget.debitNoteToEdit!.id, input);
      } else {
        final input = DebitNoteCreateInput(
          date: _selectedDate,
          salesTypeId: _selectedTypeId,
          partyId: _selectedPartyId!,
          dcNo: _dcNoController.text.trim(),
          items: itemsPayload,
          isGstBill: _isGstBill,
          gstPercentage: _isGstBill ? _selectedGstPercentage : 0.0,
          notes: _notesController.text.trim(),
          narration: _notesController.text.trim(),
        );
        success = await _debitNoteController.createDebitNote(input);
      }

      if (mounted) {
        if (success) {
          AppNotification.showSuccess(
            context,
            _isEditMode ? 'Debit note updated successfully!' : 'Debit note created successfully!',
          );
          Navigator.pop(context, true);
        } else {
          final err = _debitNoteController.errorMessage ?? 'Failed to save debit note.';
          setState(() => _formErrorMessage = err);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formErrorMessage = 'An unexpected error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final dateField = InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date *',
          prefixIcon: Icon(Icons.calendar_today, size: 18),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Text(dateStr, style: const TextStyle(fontSize: 14)),
      ),
    );

    final partyField = DropdownButtonFormField<String>(
      isExpanded: true,
      value: _inventoryController.parties.any((p) => p.id == _selectedPartyId)
          ? _selectedPartyId
          : null,
      decoration: const InputDecoration(
        labelText: 'Party (Customer) *',
        prefixIcon: Icon(Icons.business, size: 18),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: _inventoryController.parties
          .where((p) => p.isActive || p.id == _selectedPartyId)
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text(
                  p.partyCode.isNotEmpty ? '${p.name} (${p.partyCode})' : p.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedPartyId = val),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );

    final typeField = DropdownButtonFormField<String>(
      isExpanded: true,
      value: _inventoryController.salesTypes.any((st) => st.id == _selectedTypeId)
          ? _selectedTypeId
          : null,
      decoration: const InputDecoration(
        labelText: 'Debit Note Type',
        prefixIcon: Icon(Icons.category, size: 18),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: _inventoryController.salesTypes
          .where((st) => st.isActive || st.id == _selectedTypeId)
          .map((st) => DropdownMenuItem(
                value: st.id,
                child: Text(st.name, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedTypeId = val),
    );

    final dcNoField = TextFormField(
      controller: _dcNoController,
      decoration: const InputDecoration(
        labelText: 'DC Number (Optional)',
        prefixIcon: Icon(Icons.tag, size: 18),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );

    return Dialog(
      insetPadding: _isFullScreen
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24, vertical: isMobile ? 12 : 24),
      shape: _isFullScreen
          ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: _isFullScreen ? MediaQuery.of(context).size.width : 1200,
        height: _isFullScreen ? MediaQuery.of(context).size.height : 850,
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: _isInit
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isEditMode ? Icons.edit_note : Icons.receipt_long,
                            color: AppColors.primary,
                            size: isMobile ? 20 : 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditMode
                                    ? 'Edit Debit Note: ${widget.debitNoteToEdit!.debitNoteNumber}'
                                    : 'New Debit Note Entry',
                                style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Deducts stock from godown and generates a debit voucher',
                                style: TextStyle(fontSize: isMobile ? 11 : 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
                          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, size: 20),
                          onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 18),

                    // Error Banner if present
                    if (_formErrorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formErrorMessage!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                              onPressed: () => setState(() => _formErrorMessage = null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Top Bar Fields: Responsive on Mobile vs Desktop
                    if (isMobile) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: dateField),
                          const SizedBox(width: 10),
                          Expanded(child: typeField),
                        ],
                      ),
                      const SizedBox(height: 12),
                      partyField,
                      const SizedBox(height: 12),
                      dcNoField,
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: dateField),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: partyField),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: typeField),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: dcNoField),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items to Debit (Stock deducted from batch)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Item Row'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: _addRow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Rows Table Area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 1200),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                horizontalMargin: 12,
                                columnSpacing: 10,
                                columns: const [
                                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Item Name *', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Stock Batch (Available) *', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Lot No', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('UOM *', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('UOM Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actual Qty *', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Billed Qty *', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Rate *', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Per Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: List.generate(_rows.length, (idx) => _buildItemDataRow(idx)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Bottom: GST & Remarks & Grand Total - Responsive for Mobile vs Desktop
                    if (isMobile) ...[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _isGstBill,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _isGstBill = val ?? false),
                              ),
                              const Text('Enable GST Calculation', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (_isGstBill) ...[
                            DropdownButton<double>(
                              value: _selectedGstPercentage,
                              underline: const SizedBox(),
                              items: _gstOptions.map((pct) => DropdownMenuItem(
                                    value: pct,
                                    child: Text('$pct% GST'),
                                  )).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedGstPercentage = val);
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Notes / Remarks / Narration',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sub Total:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                Text(
                                  '₹ ${_estimatedSubTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (_isGstBill) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('GST (${_selectedGstPercentage.toStringAsFixed(0)}%):',
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  Text(
                                    '₹ ${((_estimatedSubTotal * _selectedGstPercentage) / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grand Total:',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                Text(
                                  '₹ ${_estimatedTotalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: GST controls & Notes
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _isGstBill,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) => setState(() => _isGstBill = val ?? false),
                                    ),
                                    const Text('Enable GST Calculation', style: TextStyle(fontWeight: FontWeight.w600)),
                                    if (_isGstBill) ...[
                                      const SizedBox(width: 16),
                                      DropdownButton<double>(
                                        value: _selectedGstPercentage,
                                        underline: const SizedBox(),
                                        items: _gstOptions.map((pct) => DropdownMenuItem(
                                              value: pct,
                                              child: Text('$pct% GST'),
                                            )).toList(),
                                        onChanged: (val) {
                                          if (val != null) setState(() => _selectedGstPercentage = val);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _notesController,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: 'Notes / Remarks / Narration',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Right: Calculation Summary Box
                          Container(
                            width: 280,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text('Sub Total:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                    ),
                                    Text(
                                      '₹ ${_estimatedSubTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                if (_isGstBill) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('GST (${_selectedGstPercentage.toStringAsFixed(0)}%):',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                      ),
                                      Text(
                                        '₹ ${((_estimatedSubTotal * _selectedGstPercentage) / 100).toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text('Grand Total:',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ),
                                    Text(
                                      '₹ ${_estimatedTotalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Actions Bottom: Responsive for Mobile
                    if (isMobile)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: _debitNoteController.isSaving
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, size: 16),
                              label: Text(_isEditMode ? 'Update' : 'Record Note'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _debitNoteController.isSaving ? null : _handleSubmit,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: _debitNoteController.isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check, size: 18),
                            label: Text(_isEditMode ? 'Update Debit Note' : 'Record Debit Note'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            onPressed: _debitNoteController.isSaving ? null : _handleSubmit,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  DataRow _buildItemDataRow(int idx) {
    final row = _rows[idx];

    final availableStocksForItem = _debitNoteController.availableStocks
        .where((s) => s.itemId == row.itemId && (s.currentStock > 0 || s.godownStockId == row.godownStockId))
        .toList();

    double multiplier = 1.0;
    if (row.perId != null) {
      final p = _inventoryController.perUnits
          .where((pu) => pu.id == row.perId)
          .firstOrNull;
      if (p != null && p.multiplier > 0) multiplier = p.multiplier;
    }
    final itemTotal = (row.billedQuantity * row.rate) / multiplier;

    return DataRow(
      cells: [
        DataCell(Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        // 1. Item selector
        DataCell(
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _inventoryController.items.any((it) => it.id == row.itemId) ? row.itemId : null,
              decoration: const InputDecoration(
                hintText: 'Select Item',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: _inventoryController.items
                  .where((it) => it.isActive || it.id == row.itemId)
                  .map((it) => DropdownMenuItem(
                        value: it.id,
                        child: Text(it.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => _onItemChanged(row, val),
            ),
          ),
        ),
        // 2. Stock Batch Selector
        DataCell(
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: availableStocksForItem.any((s) => s.godownStockId == row.godownStockId)
                  ? row.godownStockId
                  : null,
              decoration: const InputDecoration(
                hintText: 'Select Batch',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: availableStocksForItem.map((s) {
                final batchLabel = s.lotNo.isNotEmpty ? 'Lot: ${s.lotNo}' : (s.dcNo.isNotEmpty ? 'DC: ${s.dcNo}' : 'Batch');
                final text = '$batchLabel | ${s.godownName} (${s.currentStock} ${s.uomSymbol})';
                return DropdownMenuItem(
                  value: s.godownStockId,
                  child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) => _onStockBatchSelected(row, val),
            ),
          ),
        ),
        // 3. Lot No
        DataCell(
          SizedBox(
            width: 90,
            child: TextFormField(
              controller: row.lotNoController,
              decoration: const InputDecoration(
                hintText: 'Lot No',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        // 4. UOM (Unit of Measurement) Dropdown
        DataCell(
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _inventoryController.uoms.any((u) => u.id == row.uomId) ? row.uomId : null,
              decoration: const InputDecoration(
                hintText: 'Select UOM',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: _inventoryController.uoms
                  .where((u) => u.isActive || u.id == row.uomId)
                  .map((u) => DropdownMenuItem(
                        value: u.id,
                        child: Text(u.symbol, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => row.uomId = val),
            ),
          ),
        ),
        // 5. UOM Qty
        DataCell(
          SizedBox(
            width: 75,
            child: TextFormField(
              controller: row.uomQtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '1',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        // 6. Actual Qty
        DataCell(
          SizedBox(
            width: 85,
            child: TextFormField(
              controller: row.actualQtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Actual',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (val) {
                if (row.billedQtyController.text.isEmpty ||
                    row.billedQtyController.text == '0' ||
                    row.billedQtyController.text == '1') {
                  row.billedQtyController.text = val;
                }
              },
            ),
          ),
        ),
        // 6. Billed Qty
        DataCell(
          SizedBox(
            width: 85,
            child: TextFormField(
              controller: row.billedQtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Billed',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        // 7. Rate
        DataCell(
          SizedBox(
            width: 85,
            child: TextFormField(
              controller: row.rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Rate',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        // 8. Per Unit
        DataCell(
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _inventoryController.perUnits.any((p) => p.id == row.perId) ? row.perId : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: _inventoryController.perUnits
                  .where((p) => p.isActive || p.id == row.perId)
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.symbol.isNotEmpty ? p.symbol : p.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => row.perId = val),
            ),
          ),
        ),
        // 9. Total Item Amount
        DataCell(
          Text(
            '₹ ${itemTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        // 10. Remove row
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => _removeRow(idx),
          ),
        ),
      ],
    );
  }
}
