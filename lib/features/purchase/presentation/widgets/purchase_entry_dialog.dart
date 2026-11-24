import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/constants/app_constants.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../../domain/entities/purchase_entity.dart';
import '../controllers/purchase_controller.dart';

class _ItemRowData {
  String? godownStockId;
  String? itemId;
  String? godownId;
  String? uomId;
  String? perId;
  final TextEditingController dcNoController;
  final TextEditingController lotNoController;
  TextEditingController get batchNoController => dcNoController;
  final TextEditingController uomQtyController;
  final TextEditingController actualQtyController;
  final TextEditingController billedQtyController;
  final TextEditingController rateController;

  _ItemRowData({
    this.godownStockId,
    this.itemId,
    this.godownId,
    this.uomId,
    this.perId,
    String dcNo = '',
    String lotNo = '',
    String batchNo = '',
    String uomQty = '1',
    String actualQty = '1',
    String billedQty = '1',
    String rate = '',
    VoidCallback? onChanged,
  })  : dcNoController = TextEditingController(text: dcNo.isNotEmpty ? dcNo : batchNo),
        lotNoController = TextEditingController(text: lotNo),
        uomQtyController = TextEditingController(text: uomQty),
        actualQtyController = TextEditingController(text: actualQty),
        billedQtyController = TextEditingController(text: billedQty),
        rateController = TextEditingController(text: rate) {
    if (onChanged != null) {
      billedQtyController.addListener(onChanged);
      rateController.addListener(onChanged);
    }
  }

  void dispose() {
    dcNoController.dispose();
    lotNoController.dispose();
    uomQtyController.dispose();
    actualQtyController.dispose();
    billedQtyController.dispose();
    rateController.dispose();
  }
}

class PurchaseEntryDialog extends StatefulWidget {
  final PurchaseController purchaseController;
  final InventoryController inventoryController;
  final PurchaseEntity? existingPurchase;

  const PurchaseEntryDialog({
    super.key,
    required this.purchaseController,
    required this.inventoryController,
    this.existingPurchase,
  });

  @override
  State<PurchaseEntryDialog> createState() => _PurchaseEntryDialogState();
}

class _PurchaseEntryDialogState extends State<PurchaseEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  String? _selectedPartyId;
  String? _selectedPurchaseTypeId;
  String? _selectedCompanyGodownId;

  // GST controls
  late bool _isGstBill;
  late double _selectedGstPercentage;

  late final TextEditingController _notesController;
  final List<_ItemRowData> _rows = [];

  bool get isEditing => widget.existingPurchase != null;
  bool _isFullScreen = false;
  String? _formErrorMessage;

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _formErrorMessage = message;
      });
      AppNotification.showError(context, message);
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.existingPurchase;
    final initialDate = p?.date.toLocal() ?? DateTime.now();
    _selectedDate = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _selectedPartyId = p?.partyId;
    _selectedPurchaseTypeId = p?.purchaseTypeId;
    _selectedCompanyGodownId = (p?.companyGodownId.isNotEmpty ?? false) ? p?.companyGodownId : null;
    _notesController = TextEditingController(text: p?.notes ?? '');

    _isGstBill = p?.isGstBill ?? false;
    _selectedGstPercentage = (p != null && p.gstPercentage > 0)
        ? p.gstPercentage
        : AppConstants.defaultGstPercentage;

    if (p != null && p.items.isNotEmpty) {
      for (final it in p.items) {
        _rows.add(_ItemRowData(
          godownStockId: it.godownStockId,
          itemId: it.itemId,
          godownId: it.godownId,
          dcNo: it.dcNo,
          lotNo: it.lotNo,
          batchNo: it.batchNo,
          uomId: it.uomId,
          perId: it.perId,
          uomQty: it.uomQuantity.toString(),
          actualQty: it.actualQuantity.toString(),
          billedQty: it.billedQuantity.toString(),
          rate: it.rate.toString(),
          onChanged: () => setState(() {}),
        ));
      }
    } else {
      // Start with 1 default item row
      _rows.add(_ItemRowData(onChanged: () => setState(() {})));
    }

    // Ensure masters are loaded
    widget.inventoryController.fetchMasters();
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_ItemRowData(onChanged: () => setState(() {})));
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      final removed = _rows.removeAt(index);
      removed.dispose();
    });
  }

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

  void _onItemChanged(int index, String? itemId) {
    setState(() {
      final row = _rows[index];
      row.itemId = itemId;
      if (itemId != null) {
        final item = widget.inventoryController.items
            .where((it) => it.id == itemId)
            .firstOrNull;
        if (item != null) {
          // Auto-select default UOM and Per unit based on selected item
          row.uomId = item.defaultUomId;
          row.perId = item.defaultPerId;
          if (item.standardRate > 0 && row.rateController.text.isEmpty) {
            row.rateController.text = item.standardRate.toString();
          }
        }
      }
    });
  }

  double _calculateSubtotal(List<dynamic> perUnits) {
    double sum = 0.0;
    for (final row in _rows) {
      final billed = double.tryParse(row.billedQtyController.text.trim()) ?? 0.0;
      final rate = double.tryParse(row.rateController.text.trim()) ?? 0.0;
      double multiplier = 1.0;
      if (row.perId != null) {
        final p = perUnits.where((pu) => pu.id == row.perId).firstOrNull;
        if (p != null && p.multiplier > 0) {
          multiplier = p.multiplier.toDouble();
        }
      }
      sum += (billed * rate) / multiplier;
    }
    return sum;
  }

  double _calculateTotalAmount(List<dynamic> perUnits) {
    final sub = _calculateSubtotal(perUnits);
    if (!_isGstBill) return sub;
    final gst = sub * (_selectedGstPercentage / 100);
    return sub + gst;
  }

  Future<void> _submit() async {
    setState(() => _formErrorMessage = null);

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_selectedPartyId == null || _selectedPartyId!.isEmpty) {
        _showError('Please select a Party Name from master');
        return;
      }
      if (_selectedPurchaseTypeId == null || _selectedPurchaseTypeId!.isEmpty) {
        _showError('Please select a Purchase Type from master');
        return;
      }
      if (_selectedCompanyGodownId == null || _selectedCompanyGodownId!.isEmpty) {
        _showError('Please select a Company Godown for this purchase');
        return;
      }

      // Verify all item rows have required masters and assigned godowns
      for (int i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        if (row.itemId == null || row.itemId!.isEmpty) {
          _showError('Please select an Item for row #${i + 1}');
          return;
        }
        if (row.godownId == null || row.godownId!.isEmpty) {
          _showError('Please assign a Delivered Godown for row #${i + 1}');
          return;
        }
        if (row.dcNoController.text.trim().isEmpty) {
          _showError('Please enter DC # for row #${i + 1}');
          return;
        }
        if (row.uomId == null || row.uomId!.isEmpty) {
          _showError('Please select a UOM for row #${i + 1}');
          return;
        }
        if (row.perId == null || row.perId!.isEmpty) {
          _showError('Please select a Per Unit for row #${i + 1}');
          return;
        }
      }

      // Build raw item inputs with individual assigned godown
      final itemsInput = _rows.map((row) {
        return PurchaseItemInput(
          godownStockId: row.godownStockId,
          itemId: row.itemId!,
          godownId: row.godownId!,
          companyGodownId: _selectedCompanyGodownId,
          dcNo: row.dcNoController.text.trim(),
          lotNo: row.lotNoController.text.trim(),
          batchNo: row.dcNoController.text.trim(),
          uomId: row.uomId!,
          uomQuantity: double.tryParse(row.uomQtyController.text.trim()) ?? 1.0,
          actualQuantity: double.tryParse(row.actualQtyController.text.trim()) ?? 0.0,
          billedQuantity: double.tryParse(row.billedQtyController.text.trim()) ?? 0.0,
          rate: double.tryParse(row.rateController.text.trim()) ?? 0.0,
          perId: row.perId!,
        );
      }).toList();

      final bool success;
      if (isEditing) {
        success = await widget.purchaseController.updatePurchase(
          id: widget.existingPurchase!.id,
          date: _selectedDate,
          partyId: _selectedPartyId,
          purchaseTypeId: _selectedPurchaseTypeId,
          companyGodownId: _selectedCompanyGodownId,
          items: itemsInput,
          isGstBill: _isGstBill,
          gstPercentage: _isGstBill ? _selectedGstPercentage : 0.0,
          notes: _notesController.text.trim(),
        );
      } else {
        success = await widget.purchaseController.createPurchase(
          date: _selectedDate,
          partyId: _selectedPartyId!,
          purchaseTypeId: _selectedPurchaseTypeId!,
          companyGodownId: _selectedCompanyGodownId!,
          items: itemsInput,
          isGstBill: _isGstBill,
          gstPercentage: _isGstBill ? _selectedGstPercentage : 0.0,
          notes: _notesController.text.trim(),
        );
      }

      if (mounted) {
        if (success) {
          widget.inventoryController.fetchCurrentTabData();
          Navigator.pop(context, true);
          AppNotification.showSuccess(
            context,
            isEditing
                ? 'Purchase entry updated successfully and stock adjusted!'
                : 'Purchase entry saved successfully and stock updated in respective godowns!',
          );
        } else {
          _showError(widget.purchaseController.errorMessage ?? 'Failed to save purchase');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.inventoryController;
    final parties = inv.parties.where((p) => p.isActive).toList();
    final purchaseTypes = inv.purchaseTypes.where((t) => t.isActive).toList();
    final items = inv.items.where((i) => i.isActive).toList();
    final uoms = inv.uoms.where((u) => u.isActive).toList();
    final perUnits = inv.perUnits.where((p) => p.isActive).toList();
    final godowns = inv.godowns.where((g) => g.isActive).toList();
    final companyGodowns = godowns.where((g) => g.type == GodownType.companyGodown).toList();

    // Auto-select company godown if only 1 is available and none selected yet
    if (companyGodowns.length == 1) {
      _selectedCompanyGodownId ??= companyGodowns.first.id;
    }

    // Auto-select if only 1 accessible godown is available
    if (godowns.length == 1) {
      for (final row in _rows) {
        row.godownId ??= godowns.first.id;
      }
    }

    final double liveSubtotal = _calculateSubtotal(perUnits);
    final double liveGstAmount = liveSubtotal * (_selectedGstPercentage / 100);
    final double liveTotal = _calculateTotalAmount(perUnits);

    return Dialog(
      insetPadding: _isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        isEditing ? Icons.edit_note : Icons.shopping_cart,
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
                            isEditing
                                ? 'Edit Purchase Record (${widget.existingPurchase!.purchaseNumber})'
                                : 'New Purchase Entry',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Assign godown for individual items & record multi-item purchase with actual stock reflection',
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Date, Purchase Type, Company Godown, Party Name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Date Picker Field
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _selectDate,
                                borderRadius: BorderRadius.circular(8),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Date *',
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
                            // 2. Purchase Type Dropdown
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: purchaseTypes.any((t) => t.id == _selectedPurchaseTypeId)
                                    ? _selectedPurchaseTypeId
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Purchase Type *',
                                  border: OutlineInputBorder(),
                                ),
                                hint: const Text('Select Type', overflow: TextOverflow.ellipsis),
                                items: purchaseTypes.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t.id,
                                    child: Text(t.name, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedPurchaseTypeId = val),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 3. Company Godown Dropdown (Mandatory)
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: companyGodowns.any((g) => g.id == _selectedCompanyGodownId)
                                    ? _selectedCompanyGodownId
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Company Godown *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.business_outlined, size: 20),
                                ),
                                hint: const Text('Select Company Godown', overflow: TextOverflow.ellipsis),
                                items: companyGodowns.map((g) {
                                  return DropdownMenuItem<String>(
                                    value: g.id,
                                    child: Text(
                                      '${g.name} (${g.godownId})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() {
                                  _selectedCompanyGodownId = val;
                                  // Default item row delivered godowns to this company godown if not yet chosen
                                  for (final row in _rows) {
                                    row.godownId ??= val;
                                  }
                                }),
                                validator: (v) => v == null ? 'Company Godown required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 4. Party / Supplier Name Dropdown
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: parties.any((p) => p.id == _selectedPartyId) ? _selectedPartyId : null,
                                decoration: const InputDecoration(
                                  labelText: 'Party / Supplier Name *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_pin, size: 20),
                                ),
                                hint: const Text('Select Party / Supplier', overflow: TextOverflow.ellipsis),
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
                                validator: (v) => v == null ? 'Party required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Multi-Item Rows Container
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Table Header with Add Row Action
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
                                      'Purchase Items & Assigned Godowns',
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
                                      child: Text('Delivered Godown *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: Text('DC # *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

                              // Item Row Editor List
                              ...List.generate(_rows.length, (index) {
                                final row = _rows[index];
                                final isSelected = row.itemId != null;
                                final itemInfo = isSelected
                                    ? items.where((it) => it.id == row.itemId).firstOrNull
                                    : null;

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
                                          // Row Number
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
                                              onChanged: (val) => _onItemChanged(index, val),
                                              validator: (v) => v == null ? 'Required' : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 2. Assigned Delivered Godown Dropdown for this item
                                          Expanded(
                                            flex: 3,
                                            child: DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              value: godowns.any((g) => g.id == row.godownId) ? row.godownId : null,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                border: OutlineInputBorder(),
                                                hintText: 'Delivered Godown',
                                              ),
                                              items: godowns.map((g) {
                                                return DropdownMenuItem<String>(
                                                  value: g.id,
                                                  child: Text(
                                                    '${g.name} (${g.godownId})',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) => setState(() => row.godownId = val),
                                              validator: (v) => v == null ? 'Godown required' : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 3. DC No.
                                          Expanded(
                                            flex: 2,
                                            child: TextFormField(
                                              controller: row.dcNoController,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                border: OutlineInputBorder(),
                                                hintText: 'DC #',
                                              ),
                                              style: const TextStyle(fontSize: 13),
                                              validator: (v) {
                                                if (v == null || v.trim().isEmpty) return 'Required';
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 4. Lot No.
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
                                          // 4. UOM Quantity
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
                                          // 5. Actual Quantity (Stock Reflection)
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
                                              validator: (v) {
                                                if (v == null || v.trim().isEmpty) return 'Required';
                                                final n = double.tryParse(v.trim());
                                                if (n == null || n <= 0) return '> 0';
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 6. Billed Quantity
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
                                          // 7. Rate (₹)
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
                                          // 8. Per Unit Dropdown
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
                                                    p.symbol,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) => setState(() => row.perId = val),
                                              validator: (v) => v == null ? 'Required' : null,
                                            ),
                                          ),
                                          // 9. Delete Action
                                          SizedBox(
                                            width: 36,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: _rows.length > 1 ? Colors.red.shade400 : Colors.grey.shade300,
                                              ),
                                              tooltip: _rows.length > 1 ? 'Remove Row' : 'At least 1 item required',
                                              onPressed: _rows.length > 1 ? () => _removeRow(index) : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (itemInfo != null)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 34, top: 4),
                                          child: Text(
                                            'Master Stock: ${itemInfo.currentStock.toStringAsFixed(2)} ${itemInfo.defaultUom?.symbol ?? ""} | Code: ${itemInfo.itemCode}',
                                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // GST Checkbox & Selection Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isGstBill,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        _isGstBill = val ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Apply GST / Tax Invoice',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 24),
                                  if (_isGstBill) ...[
                                    const Text(
                                      'GST Slab:',
                                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 130,
                                      child: DropdownButtonFormField<double>(
                                        value: AppConstants.availableGstPercentages.contains(_selectedGstPercentage)
                                            ? _selectedGstPercentage
                                            : AppConstants.defaultGstPercentage,
                                        isDense: true,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          border: OutlineInputBorder(),
                                        ),
                                        items: AppConstants.availableGstPercentages.map((pct) {
                                          return DropdownMenuItem<double>(
                                            value: pct,
                                            child: Text('${pct.toStringAsFixed(0)}% GST'),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => _selectedGstPercentage = val);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Live Total Amount Card
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Items Subtotal',
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          '₹${liveSubtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    if (_isGstBill)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'GST (${_selectedGstPercentage.toStringAsFixed(0)}%)',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          Text(
                                            '+ ₹${liveGstAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Total Amount',
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          '₹${liveTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes Field
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes / Remarks (Optional)',
                            hintText: 'Additional purchase remarks, invoice reference, etc.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                if (_formErrorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
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

                // Dialog Action Buttons
                Row(
                  children: [
                    Text(
                      '${_rows.length} ${_rows.length == 1 ? "Item" : "Items"} in Purchase',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: widget.purchaseController.isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: widget.purchaseController.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(isEditing ? 'Update Purchase Record' : 'Save Purchase Record'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: widget.purchaseController.isSaving ? null : _submit,
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
