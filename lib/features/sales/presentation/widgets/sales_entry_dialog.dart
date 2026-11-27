import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/constants/app_constants.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/core/widgets/app_popup_select_field.dart';
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
  String hsnCode = '';
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
    this.hsnCode = '',
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
  late final TextEditingController _invoiceNoController;
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
    _invoiceNoController = TextEditingController(text: s?.invoiceNo ?? '');
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
          hsnCode: it.hsnCode,
          lotNo: it.lotNo,
          uomQty: it.uomQuantity.toString(),
          actualQty: it.actualQuantity.toString(),
          billedQty: it.billedQuantity.toString(),
          rate: it.rate.toString(),
          maxAvailableStock: it.actualQuantity, // Current sold stock during edit
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
        _salesController.fetchAvailableStocks(saleId: widget.saleToEdit?.id),
      ]);

      // If sales types loaded and none selected, auto-select first active sales type
      if (_selectedSalesTypeId == null && _inventoryController.salesTypes.isNotEmpty) {
        final active = _inventoryController.salesTypes.where((st) => st.isActive).firstOrNull;
        if (active != null) {
          _selectedSalesTypeId = active.id;
        }
      }

      // In edit mode, sync each row's maxAvailableStock with fetched available stock headroom
      if (_isEditMode && widget.saleToEdit != null) {
        for (final row in _rows) {
          if (row.godownStockId != null) {
            final st = _salesController.availableStocks
                .where((s) => s.godownStockId == row.godownStockId)
                .firstOrNull;
            if (st != null) {
              row.maxAvailableStock = st.currentStock;
            }
          }
        }
      }
    } catch (e) {
      AppLogger().e('Error in _loadInitialData: $e', tag: 'SalesEntry');
      _showError('Failed to load masters or available stock: $e');
    } finally {
      if (mounted) {
        setState(() => _isInit = false);
      }
    }
  }

  @override
  void dispose() {
    _invoiceNoController.dispose();
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

  List<AvailableStockEntity> _getAvailableStocksForEdit() {
    final available = <AvailableStockEntity>[];
    final seenStockIds = <String>{};

    for (final s in _salesController.availableStocks) {
      if (_isEditMode && widget.saleToEdit != null) {
        final matchedSaleItem = widget.saleToEdit!.items.where((it) => it.godownStockId == s.godownStockId).firstOrNull;
        if (matchedSaleItem != null) {
          available.add(AvailableStockEntity(
            godownStockId: s.godownStockId,
            godownId: s.godownId,
            godownName: s.godownName,
            companyGodownId: s.companyGodownId,
            companyGodownName: s.companyGodownName,
            itemId: s.itemId,
            itemName: s.itemName,
            itemCode: s.itemCode,
            dcNo: s.dcNo,
            lotNo: s.lotNo,
            currentStock: s.currentStock,
            rate: s.rate > 0 ? s.rate : matchedSaleItem.rate,
            uomId: s.uomId,
            uomSymbol: s.uomSymbol,
            uomQuantity: s.uomQuantity,
            perId: s.perId,
            perSymbol: s.perSymbol,
          ));
          seenStockIds.add(s.godownStockId);
          continue;
        }
      }
      available.add(s);
      seenStockIds.add(s.godownStockId);
    }

    if (_isEditMode && widget.saleToEdit != null) {
      for (final saleItem in widget.saleToEdit!.items) {
        if (!seenStockIds.contains(saleItem.godownStockId)) {
          available.add(AvailableStockEntity(
            godownStockId: saleItem.godownStockId,
            godownId: saleItem.godownId,
            godownName: saleItem.godownName,
            companyGodownId: saleItem.companyGodownId ?? '',
            companyGodownName: saleItem.companyGodownName,
            itemId: saleItem.itemId,
            itemName: saleItem.itemName,
            itemCode: saleItem.itemCode,
            dcNo: saleItem.dcNo,
            lotNo: saleItem.lotNo,
            currentStock: saleItem.actualQuantity,
            rate: saleItem.rate,
            uomId: saleItem.uomId,
            uomSymbol: saleItem.uomSymbol,
            uomQuantity: saleItem.uomQuantity,
            perId: saleItem.perId,
            perSymbol: saleItem.perSymbol,
          ));
          seenStockIds.add(saleItem.godownStockId);
        }
      }
    }

    return available;
  }

  void _onItemChanged(_SaleItemRowData row, String? itemId) {
    setState(() {
      row.itemId = itemId;
      if (itemId == null || itemId.isEmpty) {
        row.godownStockId = null;
        row.godownId = null;
        row.hsnCode = '';
        row.maxAvailableStock = 0.0;
        return;
      }

      final itemDoc = _inventoryController.items.where((it) => it.id == itemId).firstOrNull ??
          _inventoryController.masters.items.where((it) => it.id == itemId).firstOrNull;
      row.hsnCode = itemDoc?.hsnCode ?? '';
      final allAvailable = _getAvailableStocksForEdit();
      final stocksForItem = allAvailable
          .where((s) => s.itemId == itemId && (s.currentStock > 0 || s.godownStockId == row.godownStockId))
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
    row.hsnCode = (itemDoc?.hsnCode ?? '').isNotEmpty ? (itemDoc?.hsnCode ?? '') : row.hsnCode;
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
    final allAvailable = _getAvailableStocksForEdit();
    final stock = allAvailable.where((s) => s.godownStockId == godownStockId).firstOrNull;
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

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _formErrorMessage = message;
      });
      AppNotification.showError(context, message);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _formErrorMessage = null);

    try {
      if (!_formKey.currentState!.validate()) {
        _showError('Please check and fill all required fields correctly.');
        return;
      }

      if (_selectedSalesTypeId == null || _selectedSalesTypeId!.isEmpty) {
        _showError('Please select a Sales Type.');
        return;
      }

      if (_selectedPartyId == null || _selectedPartyId!.isEmpty) {
        _showError('Please select a Party / Customer.');
        return;
      }

      if (_dcNoController.text.trim().isEmpty) {
        _showError('Please enter a DC Number.');
        return;
      }

      if (_rows.isEmpty) {
        _showError('At least one item is required for sale.');
        return;
      }

      final List<SaleItemInput> inputs = [];
      for (int i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        if (row.itemId == null || row.itemId!.isEmpty) {
          _showError('Please select Item for Line #${i + 1}.');
          return;
        }
        if (row.godownStockId == null || row.godownStockId!.isEmpty) {
          _showError('No available stock batch selected for Line #${i + 1}.');
          return;
        }
        if (row.actualQuantity <= 0) {
          _showError('Actual quantity must be greater than 0 for Line #${i + 1}.');
          return;
        }
        if (row.billedQuantity <= 0) {
          _showError('Billed quantity must be greater than 0 for Line #${i + 1}.');
          return;
        }
        if (row.rate < 0) {
          _showError('Rate cannot be negative for Line #${i + 1}.');
          return;
        }

        String rowHsn = row.hsnCode;
        if (rowHsn.isEmpty && row.itemId != null) {
          final itm = _inventoryController.items.where((it) => it.id == row.itemId).firstOrNull ??
              _inventoryController.masters.items.where((it) => it.id == row.itemId).firstOrNull;
          rowHsn = itm?.hsnCode ?? '';
        }

        inputs.add(SaleItemInput(
          godownStockId: row.godownStockId!,
          itemId: row.itemId,
          godownId: row.godownId,
          dcNo: _dcNoController.text.trim(),
          lotNo: row.lotNoController.text.trim(),
          hsnCode: rowHsn,
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
            invoiceNo: _invoiceNoController.text.trim(),
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
            invoiceNo: _invoiceNoController.text.trim(),
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
      } else if (mounted) {
        _showError(_salesController.errorMessage ?? 'Failed to save sale record');
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred: $e');
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
          padding: EdgeInsets.all(isMobile ? 12 : 24),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isEditMode ? Icons.edit_note : Icons.shopping_cart,
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
                                ? 'Edit Sales Entry (${widget.saleToEdit!.salesNumber})'
                                : 'New Sales Entry',
                            style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select items to pick from available godown stocks and record sales',
                            style: TextStyle(fontSize: isMobile ? 11 : 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            size: 20,
                          ),
                          tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen View',
                          onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 18),

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
                              // Header Fields: Responsive Row on Desktop, Stacked on Mobile
                              if (isMobile) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Sales Date Picker
                                    Expanded(
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
                                    const SizedBox(width: 10),
                                    // 2. Sales Type Dropdown
                                    Expanded(
                                      child: AppPopupSelectField<String>(
                                        key: ValueKey('mob_salestype_$_selectedSalesTypeId'),
                                        value: salesTypes.any((t) => t.id == _selectedSalesTypeId)
                                            ? _selectedSalesTypeId
                                            : null,
                                        labelText: 'Sales Type *',
                                        hintText: 'Select Type',
                                        title: 'Select Sales Type',
                                        headerIcon: Icons.category_outlined,
                                        items: salesTypes.map((t) {
                                          return AppPopupOption<String>(
                                            value: t.id,
                                            label: t.name,
                                            icon: Icons.category_outlined,
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(() => _selectedSalesTypeId = val),
                                        validator: (v) => v == null ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // 3. Party / Customer Name Dropdown
                                AppPopupSelectField<String>(
                                  key: ValueKey('mob_party_$_selectedPartyId'),
                                  value: parties.any((p) => p.id == _selectedPartyId) ? _selectedPartyId : null,
                                  labelText: 'Party / Customer Name *',
                                  hintText: 'Select Party / Customer',
                                  title: 'Select Customer / Party',
                                  headerIcon: Icons.person_pin,
                                  prefixIcon: const Icon(Icons.person_pin, size: 20),
                                  items: parties.map((p) {
                                    return AppPopupOption<String>(
                                      value: p.id,
                                      label: p.name,
                                      subtitle: p.address.isNotEmpty ? p.address : null,
                                      icon: Icons.person_outline,
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedPartyId = val),
                                  validator: (v) => v == null ? 'Customer required' : null,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // 4. DC No
                                    Expanded(
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
                                    const SizedBox(width: 10),
                                    // 5. Invoice No
                                    Expanded(
                                      child: TextFormField(
                                        controller: _invoiceNoController,
                                        decoration: const InputDecoration(
                                          labelText: 'Invoice No',
                                          hintText: 'e.g. 86',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.tag, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
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
                                      child: AppPopupSelectField<String>(
                                        key: ValueKey('desk_salestype_$_selectedSalesTypeId'),
                                        value: salesTypes.any((t) => t.id == _selectedSalesTypeId)
                                            ? _selectedSalesTypeId
                                            : null,
                                        labelText: 'Sales Type *',
                                        hintText: 'Select Type',
                                        title: 'Select Sales Type',
                                        headerIcon: Icons.category_outlined,
                                        items: salesTypes.map((t) {
                                          return AppPopupOption<String>(
                                            value: t.id,
                                            label: t.name,
                                            icon: Icons.category_outlined,
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
                                      child: AppPopupSelectField<String>(
                                        key: ValueKey('desk_party_$_selectedPartyId'),
                                        value: parties.any((p) => p.id == _selectedPartyId) ? _selectedPartyId : null,
                                        labelText: 'Party / Customer Name *',
                                        hintText: 'Select Party / Customer',
                                        title: 'Select Customer / Party',
                                        headerIcon: Icons.person_pin,
                                        prefixIcon: const Icon(Icons.person_pin, size: 20),
                                        items: parties.map((p) {
                                          return AppPopupOption<String>(
                                            value: p.id,
                                            label: p.name,
                                            subtitle: p.address.isNotEmpty ? p.address : null,
                                            icon: Icons.person_outline,
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
                                    const SizedBox(width: 12),
                                    // 5. Invoice No
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _invoiceNoController,
                                        decoration: const InputDecoration(
                                          labelText: 'Invoice No',
                                          hintText: 'e.g. 86',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.tag, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                                    if (isMobile)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        color: Colors.blue.shade50,
                                        child: Row(
                                          children: [
                                            Icon(Icons.swipe_outlined, size: 14, color: Colors.blue.shade700),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Swipe horizontally to view all item columns',
                                              style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const Divider(height: 1),

                                    // Horizontally Scrollable Items Table
                                    Scrollbar(
                                      thumbVisibility: isMobile,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width: 1200,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
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
                                      final allAvailable = _getAvailableStocksForEdit();
                                      final stocksForItem = row.itemId != null
                                          ? allAvailable
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
                                                  child: AppPopupSelectField<String>(
                                                    key: ValueKey('item_${index}_${row.itemId}'),
                                                    value: items.any((i) => i.id == row.itemId) ? row.itemId : null,
                                                    isDense: true,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    hintText: 'Select Item',
                                                    title: 'Select Item',
                                                    headerIcon: Icons.inventory_2_outlined,
                                                    items: items.map((it) {
                                                      final tags = <String>[
                                                        'Stock: ${it.currentStock.toStringAsFixed(it.currentStock.truncateToDouble() == it.currentStock ? 0 : 2)} ${it.defaultUom?.symbol ?? ""}',
                                                        if (it.itemGroup?.name != null && it.itemGroup!.name.isNotEmpty) 'Group: ${it.itemGroup!.name}',
                                                        if (it.hsnCode.isNotEmpty) 'HSN: ${it.hsnCode}',
                                                      ];
                                                      return AppPopupOption<String>(
                                                        value: it.id,
                                                        label: it.name,
                                                        tags: tags,
                                                        icon: Icons.inventory_2_outlined,
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
                                                  child: AppPopupSelectField<String>(
                                                    key: ValueKey('godown_${index}_${row.godownStockId}'),
                                                    value: stocksForItem.any((s) => s.godownStockId == row.godownStockId)
                                                        ? row.godownStockId
                                                        : null,
                                                    isDense: true,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    hintText: row.itemId == null
                                                        ? 'Select Item First'
                                                        : (stocksForItem.isEmpty ? 'No Stock Available' : 'Select Godown Batch'),
                                                    title: 'Select Godown Batch',
                                                    headerIcon: Icons.warehouse_outlined,
                                                    enabled: stocksForItem.isNotEmpty,
                                                    items: stocksForItem.map((stock) {
                                                      final tags = <String>[
                                                        'Stock: ${stock.currentStock} ${stock.uomSymbol}',
                                                        if (stock.lotNo.isNotEmpty) 'Lot: ${stock.lotNo}',
                                                        if (stock.dcNo.isNotEmpty) 'DC: ${stock.dcNo}',
                                                      ];
                                                      return AppPopupOption<String>(
                                                        value: stock.godownStockId,
                                                        label: stock.godownName,
                                                        tags: tags,
                                                        icon: Icons.warehouse_outlined,
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
                                                  child: AppPopupSelectField<String>(
                                                    key: ValueKey('uom_${index}_${row.uomId}'),
                                                    value: uoms.any((u) => u.id == row.uomId) ? row.uomId : null,
                                                    isDense: true,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    hintText: 'UOM',
                                                    title: 'Select Unit of Measure',
                                                    headerIcon: Icons.straighten_rounded,
                                                    items: uoms.map((u) {
                                                      return AppPopupOption<String>(
                                                        value: u.id,
                                                        label: u.symbol.isNotEmpty ? u.symbol : u.name,
                                                        subtitle: u.name != u.symbol ? u.name : null,
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
                                                  child: AppPopupSelectField<String>(
                                                    key: ValueKey('per_${index}_${row.perId}'),
                                                    value: perUnits.any((p) => p.id == row.perId) ? row.perId : null,
                                                    isDense: true,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    hintText: 'Per',
                                                    title: 'Select Pricing Unit (Per)',
                                                    headerIcon: Icons.sell_outlined,
                                                    items: perUnits.map((p) {
                                                      return AppPopupOption<String>(
                                                        value: p.id,
                                                        label: p.symbol.isNotEmpty ? p.symbol : p.name,
                                                        subtitle: p.name != p.symbol ? p.name : null,
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
                            ),
                          ),
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
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
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
                                          ],
                                        ),
                                        if (_isGstBill) ...[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
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
                                              style: TextStyle(fontSize: isMobile ? 15 : 18, fontWeight: FontWeight.bold),
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
                                              style: TextStyle(
                                                fontSize: isMobile ? 17 : 22,
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
                            ],
                          ),
                        ),
                ),
                if (_formErrorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
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
                const Divider(height: 20),

                // Dialog Footer: Responsive for Mobile
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          '${_rows.length} ${_rows.length == 1 ? "Item" : "Items"} in Sale',
                          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _salesController.isLoading ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _salesController.isLoading ? null : _handleSubmit,
                              icon: _salesController.isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, size: 16),
                              label: Text(_isEditMode ? 'Update' : 'Save Sale'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
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
