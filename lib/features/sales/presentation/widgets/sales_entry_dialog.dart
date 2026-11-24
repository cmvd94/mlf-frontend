import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/constants/app_constants.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/stock_transfer/domain/entities/available_stock_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../controllers/sales_controller.dart';

class _SaleItemRowData {
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

  _SaleItemRowData({
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

class SalesEntryDialog extends StatefulWidget {
  final SaleEntity? saleToEdit;

  const SalesEntryDialog({super.key, this.saleToEdit});

  @override
  State<SalesEntryDialog> createState() => _SalesEntryDialogState();
}

class _SalesEntryDialogState extends State<SalesEntryDialog> {
  late final SalesController _salesController;
  late final InventoryController _inventoryController;

  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.saleToEdit != null;

  late DateTime _selectedDate;
  String? _selectedSalesTypeId;
  String? _selectedPartyId;
  late final TextEditingController _dcNoController;

  bool _isGstBill = false;
  double _selectedGstPercentage = AppConstants.defaultGstPercentage;

  late final TextEditingController _notesController;
  final List<_SaleItemRowData> _rows = [];

  bool _isInit = true;
  bool _isFullScreen = false;
  String? _formErrorMessage;

  static const List<double> _gstOptions = [0, 5, 12, 18, 28];

  @override
  void initState() {
    super.initState();
    _salesController = sl<SalesController>();
    _inventoryController = sl<InventoryController>();

    final s = widget.saleToEdit;
    final initialDate = s?.date.toLocal() ?? DateTime.now();
    _selectedDate = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _selectedSalesTypeId = s?.salesTypeId.isNotEmpty ?? false ? s?.salesTypeId : null;
    _selectedPartyId = s?.partyId.isNotEmpty ?? false ? s?.partyId : null;
    _dcNoController = TextEditingController(text: s?.dcNo ?? '');
    _notesController = TextEditingController(text: s?.notes.isNotEmpty ?? false ? s!.notes : (s?.narration ?? ''));

    _isGstBill = s?.isGstBill ?? false;
    _selectedGstPercentage = (s != null && s.gstPercentage > 0)
        ? s.gstPercentage
        : AppConstants.defaultGstPercentage;

    if (s != null && s.items.isNotEmpty) {
      for (final it in s.items) {
        _rows.add(_SaleItemRowData(
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
          maxAvailableStock: it.actualQuantity + 999999, // Allow current sold stock during edit
          onChanged: () => setState(() {}),
        ));
      }
    } else {
      _rows.add(_SaleItemRowData(onChanged: () => setState(() {})));
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
        _salesController.fetchAvailableStocks(),
      ]);

      // If sales types loaded and none selected, auto-select first active sales type
      if (_selectedSalesTypeId == null && _inventoryController.salesTypes.isNotEmpty) {
        final active = _inventoryController.salesTypes.where((st) => st.isActive).firstOrNull;
        if (active != null) {
          _selectedSalesTypeId = active.id;
        }
      }
    } catch (e) {
      AppLogger().e('Error in _loadInitialData: $e', tag: 'SalesEntry');
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
      _rows.add(_SaleItemRowData(onChanged: () => setState(() {})));
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) {
      AppNotification.showError(context, 'At least one item is required in a sale');
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

  void _onItemChanged(_SaleItemRowData row, String? itemId) {
    setState(() {
      row.itemId = itemId;
      if (itemId == null || itemId.isEmpty) {
        row.godownStockId = null;
        row.godownId = null;
        row.maxAvailableStock = 0.0;
        return;
      }

      final itemDoc = _inventoryController.items.where((it) => it.id == itemId).firstOrNull;
      final stocksForItem = _salesController.availableStocks
          .where((s) => s.itemId == itemId && s.currentStock > 0)
          .toList();

      if (stocksForItem.isNotEmpty) {
        // Auto-select the first batch or matching batch
        final stock = stocksForItem.first;
        _applyStockToRow(row, stock, itemDoc);
      } else {
        // No current stock found in godowns
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

  void _applyStockToRow(_SaleItemRowData row, AvailableStockEntity stock, dynamic itemDoc) {
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

  void _onStockBatchSelected(_SaleItemRowData row, String? godownStockId) {
    if (godownStockId == null) return;
    final stock = _salesController.availableStocks.where((s) => s.godownStockId == godownStockId).firstOrNull;
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

      if (_selectedSalesTypeId == null || _selectedSalesTypeId!.isEmpty) {
        setState(() => _formErrorMessage = 'Please select a Sales Type.');
        return;
      }

      if (_selectedPartyId == null || _selectedPartyId!.isEmpty) {
        setState(() => _formErrorMessage = 'Please select a Party / Customer.');
        return;
      }

      if (_dcNoController.text.trim().isEmpty) {
        setState(() => _formErrorMessage = 'Please enter a DC Number.');
        return;
      }

      if (_rows.isEmpty) {
        setState(() => _formErrorMessage = 'At least one item is required for sale.');
        return;
      }

      final List<SaleItemInput> inputs = [];
      for (int i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        if (row.itemId == null || row.itemId!.isEmpty) {
          setState(() => _formErrorMessage = 'Please select Item for Line #${i + 1}.');
          return;
        }
        if (row.godownStockId == null || row.godownStockId!.isEmpty) {
          setState(() => _formErrorMessage = 'No available stock batch selected for Line #${i + 1}.');
          return;
        }
        if (row.actualQuantity <= 0) {
          setState(() => _formErrorMessage = 'Actual quantity must be greater than 0 for Line #${i + 1}.');
          return;
        }
        if (row.billedQuantity <= 0) {
          setState(() => _formErrorMessage = 'Billed quantity must be greater than 0 for Line #${i + 1}.');
          return;
        }
        if (!_isEditMode && row.maxAvailableStock > 0 && row.actualQuantity > row.maxAvailableStock) {
          setState(() => _formErrorMessage =
              'Actual quantity for Line #${i + 1} (${row.actualQuantity}) exceeds available stock (${row.maxAvailableStock}).');
          return;
        }
        if (row.rate < 0) {
          setState(() => _formErrorMessage = 'Rate cannot be negative for Line #${i + 1}.');
          return;
        }

        inputs.add(SaleItemInput(
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

      bool success = false;
      if (_isEditMode) {
        success = await _salesController.updateSale(
          widget.saleToEdit!.id,
          SaleUpdateInput(
            date: _selectedDate,
            salesTypeId: _selectedSalesTypeId,
            partyId: _selectedPartyId,
            dcNo: _dcNoController.text.trim(),
            items: inputs,
            isGstBill: _isGstBill,
            gstPercentage: _isGstBill ? _selectedGstPercentage : 0,
            notes: _notesController.text.trim(),
            narration: _notesController.text.trim(),
          ),
        );
      } else {
        success = await _salesController.createSale(
          SaleCreateInput(
            date: _selectedDate,
            salesTypeId: _selectedSalesTypeId!,
            partyId: _selectedPartyId!,
            dcNo: _dcNoController.text.trim(),
            items: inputs,
            isGstBill: _isGstBill,
            gstPercentage: _isGstBill ? _selectedGstPercentage : 0,
            notes: _notesController.text.trim(),
            narration: _notesController.text.trim(),
          ),
        );
      }

      if (success && mounted) {
        AppNotification.showSuccess(
          context,
          _isEditMode ? 'Sale record updated successfully!' : 'Sale record created successfully!',
        );
        Navigator.of(context).pop(true);
      } else if (mounted && _salesController.errorMessage != null) {
        setState(() => _formErrorMessage = _salesController.errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formErrorMessage = 'An unexpected error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    final salesTypes = _inventoryController.salesTypes.where((st) => st.isActive).toList();
    final parties = _inventoryController.parties.where((p) => p.isActive).toList();
    final items = _inventoryController.items.where((it) => it.isActive).toList();
    final uoms = _inventoryController.uoms.where((u) => u.isActive).toList();
    final perUnits = _inventoryController.perUnits.where((p) => p.isActive).toList();

    return Dialog(
      insetPadding: _isFullScreen
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 32,
              vertical: isMobile ? 16 : 24,
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isFullScreen ? double.infinity : 1220,
          maxHeight: _isFullScreen ? double.infinity : 880,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isEditMode ? Icons.edit_note : Icons.shopping_cart,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode
                                ? 'Edit Sales Entry (${widget.saleToEdit!.salesNumber})'
                                : 'New Sales Entry',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Select items to pick from available godown stocks and record sales',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isFullScreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen View',
                          onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Scrollable Body
                Expanded(
                  child: _isInit
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 16),
                              Text('Loading available stocks and masters...'),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row: Date, Sales Type, Party Name, DC No
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Sales Date Picker
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: _selectDate,
                                      borderRadius: BorderRadius.circular(8),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Sales Date *',
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(Icons.calendar_today, size: 20),
                                        ),
                                        child: Text(
                                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 2. Sales Type Dropdown
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: salesTypes.any((t) => t.id == _selectedSalesTypeId)
                                          ? _selectedSalesTypeId
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Sales Type *',
                                        border: OutlineInputBorder(),
                                      ),
                                      hint: const Text('Select Type', overflow: TextOverflow.ellipsis),
                                      items: salesTypes.map((t) {
                                        return DropdownMenuItem<String>(
                                          value: t.id,
                                          child: Text(t.name, overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedSalesTypeId = val),
                                      validator: (v) => v == null ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 3. Party / Customer Name Dropdown
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: parties.any((p) => p.id == _selectedPartyId) ? _selectedPartyId : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Party / Customer Name *',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person_pin, size: 20),
                                      ),
                                      hint: const Text('Select Party / Customer', overflow: TextOverflow.ellipsis),
                                      items: parties.map((p) {
                                        return DropdownMenuItem<String>(
                                          value: p.id,
                                          child: Text(
                                            '${p.name} ${p.partyCode.isNotEmpty ? "(${p.partyCode})" : ""}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedPartyId = val),
                                      validator: (v) => v == null ? 'Customer required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 4. DC No (Common on top)
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _dcNoController,
                                      decoration: const InputDecoration(
                                        labelText: 'DC No *',
                                        hintText: 'Enter DC No',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.receipt_long, size: 20),
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? 'DC No is required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Items & Godown Stock Section Container
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Bar with Add Row Action
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(9),
                                          topRight: Radius.circular(9),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Sales Items & Stock Selection',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const Spacer(),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.add, size: 16),
                                            label: const Text('Add Item Line'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              visualDensity: VisualDensity.compact,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            ),
                                            onPressed: _addRow,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),

                                    // Items Table Column Labels
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: const [
                                          SizedBox(
                                            width: 26,
                                            child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text('Item Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 3,
                                            child: Text('Godown Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Lot #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('UOM *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('UOM Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Actual Qty *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Billed Qty *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Rate (₹) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Per *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          SizedBox(width: 36),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),

                                    // Item Rows
                                    ...List.generate(_rows.length, (index) {
                                      final row = _rows[index];
                                      final stocksForItem = row.itemId != null
                                          ? _salesController.availableStocks
                                              .where((s) => s.itemId == row.itemId && (s.currentStock > 0 || s.godownStockId == row.godownStockId))
                                              .toList()
                                          : <AvailableStockEntity>[];

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: index.isOdd ? Colors.grey.shade50 : Colors.white,
                                          border: index < _rows.length - 1
                                              ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                                              : null,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Row Index
                                                SizedBox(
                                                  width: 26,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                                // 1. Item Dropdown
                                                Expanded(
                                                  flex: 3,
                                                  child: DropdownButtonFormField<String>(
                                                    isExpanded: true,
                                                    value: items.any((i) => i.id == row.itemId) ? row.itemId : null,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Select Item',
                                                    ),
                                                    items: items.map((it) {
                                                      return DropdownMenuItem<String>(
                                                        value: it.id,
                                                        child: Text(
                                                          '${it.name} ${it.itemCode.isNotEmpty ? "(${it.itemCode})" : ""}',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) => _onItemChanged(row, val),
                                                    validator: (v) => v == null ? 'Required' : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 2. Godown Name Dropdown (shows respective available stock, quantity & lot number)
                                                Expanded(
                                                  flex: 3,
                                                  child: DropdownButtonFormField<String>(
                                                    isExpanded: true,
                                                    value: stocksForItem.any((s) => s.godownStockId == row.godownStockId)
                                                        ? row.godownStockId
                                                        : null,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: const OutlineInputBorder(),
                                                      hintText: row.itemId == null
                                                          ? 'Select Item First'
                                                          : (stocksForItem.isEmpty ? 'No Stock Available' : 'Select Godown Batch'),
                                                    ),
                                                    items: stocksForItem.map((stock) {
                                                      final lotText = stock.lotNo.isNotEmpty ? ' | Lot: ${stock.lotNo}' : '';
                                                      return DropdownMenuItem<String>(
                                                        value: stock.godownStockId,
                                                        child: Text(
                                                          '${stock.godownName} (${stock.currentStock} ${stock.uomSymbol}$lotText)',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: stocksForItem.isEmpty
                                                        ? null
                                                        : (val) => _onStockBatchSelected(row, val),
                                                    validator: (v) {
                                                      if (row.itemId != null && (v == null || v.isEmpty)) {
                                                        return 'Godown stock required';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 3. Lot #
                                                Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                    controller: row.lotNoController,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Lot #',
                                                    ),
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 4. UOM Dropdown
                                                Expanded(
                                                  flex: 2,
                                                  child: DropdownButtonFormField<String>(
                                                    isExpanded: true,
                                                    value: uoms.any((u) => u.id == row.uomId) ? row.uomId : null,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'UOM',
                                                    ),
                                                    items: uoms.map((u) {
                                                      return DropdownMenuItem<String>(
                                                        value: u.id,
                                                        child: Text(
                                                          u.symbol,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) => setState(() => row.uomId = val),
                                                    validator: (v) => v == null ? 'Required' : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 5. UOM Quantity
                                                Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                    controller: row.uomQtyController,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'UOM Qty',
                                                    ),
                                                    style: const TextStyle(fontSize: 13),
                                                    validator: (v) {
                                                      if (v == null || v.trim().isEmpty) return 'Required';
                                                      final n = double.tryParse(v.trim());
                                                      if (n == null || n <= 0) return '> 0';
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 6. Actual Quantity (Stock deduction)
                                                Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                    controller: row.actualQtyController,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Actual Qty',
                                                    ),
                                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
                                                    onChanged: (val) {
                                                      // If billed quantity is empty or equal to previous actual, sync them
                                                      if (row.billedQtyController.text.isEmpty ||
                                                          row.billedQtyController.text == '0' ||
                                                          row.billedQtyController.text == '1') {
                                                        row.billedQtyController.text = val;
                                                      }
                                                    },
                                                    validator: (v) {
                                                      if (v == null || v.trim().isEmpty) return 'Required';
                                                      final n = double.tryParse(v.trim());
                                                      if (n == null || n <= 0) return '> 0';
                                                      if (!_isEditMode && row.maxAvailableStock > 0 && n > row.maxAvailableStock) {
                                                        return 'Max ${row.maxAvailableStock}';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 7. Billed Quantity (Billing multiplier)
                                                Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                    controller: row.billedQtyController,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Billed Qty',
                                                    ),
                                                    style: const TextStyle(fontSize: 13),
                                                    validator: (v) {
                                                      if (v == null || v.trim().isEmpty) return 'Required';
                                                      final n = double.tryParse(v.trim());
                                                      if (n == null || n <= 0) return '> 0';
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 8. Rate (₹)
                                                Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                    controller: row.rateController,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Rate ₹',
                                                    ),
                                                    style: const TextStyle(fontSize: 13),
                                                    validator: (v) {
                                                      if (v == null || v.trim().isEmpty) return 'Required';
                                                      final n = double.tryParse(v.trim());
                                                      if (n == null || n < 0) return '>= 0';
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // 9. Per Unit Dropdown
                                                Expanded(
                                                  flex: 2,
                                                  child: DropdownButtonFormField<String>(
                                                    isExpanded: true,
                                                    value: perUnits.any((p) => p.id == row.perId) ? row.perId : null,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Per',
                                                    ),
                                                    items: perUnits.map((p) {
                                                      return DropdownMenuItem<String>(
                                                        value: p.id,
                                                        child: Text(
                                                          p.symbol.isNotEmpty ? p.symbol : p.name,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) => setState(() => row.perId = val),
                                                    validator: (v) => v == null ? 'Required' : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // Delete Row Action
                                                SizedBox(
                                                  width: 36,
                                                  height: 40,
                                                  child: IconButton(
                                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                                    tooltip: 'Remove Line',
                                                    onPressed: () => _removeRow(index),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (row.godownStockId != null && row.maxAvailableStock > 0) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(left: 34, top: 4),
                                                child: Text(
                                                  'Available in stock: ${row.maxAvailableStock}  ${row.lotNoController.text.isNotEmpty ? "• Lot: ${row.lotNoController.text}" : ""}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.blueGrey.shade600,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Apply GST / Tax Invoice Section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
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
                                        const Text(
                                          'Apply GST / Tax Invoice',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        if (_isGstBill) ...[
                                          const SizedBox(width: 20),
                                          const Text('GST Rate: ', style: TextStyle(fontSize: 13)),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 100,
                                            height: 38,
                                            child: DropdownButtonFormField<double>(
                                              isDense: true,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                              value: _selectedGstPercentage,
                                              items: _gstOptions.map((g) {
                                                return DropdownMenuItem<double>(
                                                  value: g,
                                                  child: Text('${g.toStringAsFixed(0)}%'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) setState(() => _selectedGstPercentage = val);
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Items Subtotal', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '₹${_estimatedSubTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('Total Amount', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '₹${_estimatedTotalAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Notes / Remarks Field
                              TextFormField(
                                controller: _notesController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Notes / Remarks (Optional)',
                                  hintText: 'Enter any remarks or delivery terms...',
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              // Error Message Alert
                              if (_formErrorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _formErrorMessage!,
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => setState(() => _formErrorMessage = null),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
                const Divider(height: 24),

                // Dialog Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_rows.length} ${_rows.length == 1 ? "Item" : "Items"} in Sale',
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _salesController.isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _salesController.isLoading ? null : _handleSubmit,
                          icon: _salesController.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: Text(_isEditMode ? 'Update Sale Record' : 'Save Sale Record'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
