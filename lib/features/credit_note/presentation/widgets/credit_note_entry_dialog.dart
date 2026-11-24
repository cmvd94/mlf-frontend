import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/constants/app_constants.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import '../../domain/entities/credit_note_entity.dart';
import '../controllers/credit_note_controller.dart';

class _CreditNoteItemRowData {
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

  _CreditNoteItemRowData({
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
      actualQtyController.addListener(onChanged);
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

class CreditNoteEntryDialog extends StatefulWidget {
  final CreditNoteController creditNoteController;
  final InventoryController inventoryController;
  final CreditNoteEntity? existingCreditNote;

  const CreditNoteEntryDialog({
    super.key,
    required this.creditNoteController,
    required this.inventoryController,
    this.existingCreditNote,
  });

  @override
  State<CreditNoteEntryDialog> createState() => _CreditNoteEntryDialogState();
}

class _CreditNoteEntryDialogState extends State<CreditNoteEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  String? _selectedPartyId;
  String? _selectedPurchaseTypeId;
  String? _selectedCompanyGodownId;

  late bool _isGstBill;
  late double _selectedGstPercentage;

  late final TextEditingController _notesController;
  final List<_CreditNoteItemRowData> _rows = [];

  bool get isEditing => widget.existingCreditNote != null;
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
    final p = widget.existingCreditNote;
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
        _rows.add(_CreditNoteItemRowData(
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
      _rows.add(_CreditNoteItemRowData(onChanged: () => setState(() {})));
    }

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
      _rows.add(_CreditNoteItemRowData(onChanged: () => setState(() {})));
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
          row.uomId = item.defaultUomId;
          row.perId = item.defaultPerId;
          if (item.standardRate > 0 && row.rateController.text.isEmpty) {
            row.rateController.text = item.standardRate.toString();
          }
        }
      }
    });
  }

  double _calculateRowAmount(_CreditNoteItemRowData row) {
    final billedQty = double.tryParse(row.billedQtyController.text) ?? 0.0;
    final rate = double.tryParse(row.rateController.text) ?? 0.0;
    double multiplier = 1.0;
    if (row.perId != null) {
      final per = widget.inventoryController.perUnits
          .where((p) => p.id == row.perId)
          .firstOrNull;
      if (per != null && per.multiplier > 0) multiplier = per.multiplier;
    }
    return (billedQty * rate) / multiplier;
  }

  double get _subTotal {
    double total = 0.0;
    for (final row in _rows) {
      total += _calculateRowAmount(row);
    }
    return total;
  }

  double get _gstAmount => _isGstBill ? (_subTotal * _selectedGstPercentage) / 100 : 0.0;
  double get _totalAmount => _subTotal + _gstAmount;

  Future<void> _submit() async {
    setState(() => _formErrorMessage = null);

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_selectedPartyId == null || _selectedPartyId!.isEmpty) {
        _showError('Please select a Party.');
        return;
      }

      if (_selectedCompanyGodownId == null || _selectedCompanyGodownId!.isEmpty) {
        _showError('Company Godown is mandatory.');
        return;
      }

      for (int i = 0; i < _rows.length; i++) {
        final row = _rows[i];
        if (row.itemId == null || row.itemId!.isEmpty) {
          _showError('Row ${i + 1}: Please select an Item.');
          return;
        }
        if (row.godownId == null || row.godownId!.isEmpty) {
          _showError('Row ${i + 1}: Please select a delivered Godown.');
          return;
        }
        final actualQty = double.tryParse(row.actualQtyController.text);
        if (actualQty == null || actualQty <= 0) {
          _showError('Row ${i + 1}: Actual Quantity must be greater than 0.');
          return;
        }
        final billedQty = double.tryParse(row.billedQtyController.text);
        if (billedQty == null || billedQty <= 0) {
          _showError('Row ${i + 1}: Billed Quantity must be greater than 0.');
          return;
        }
        if (row.uomId == null || row.uomId!.isEmpty) {
          _showError('Row ${i + 1}: Please select a Unit (UOM).');
          return;
        }
        if (row.perId == null || row.perId!.isEmpty) {
          _showError('Row ${i + 1}: Please select Per Unit.');
          return;
        }
      }

      final itemsInput = _rows.map((row) {
        final actualQty = double.tryParse(row.actualQtyController.text.trim()) ?? 0.0;
        final billedQty = double.tryParse(row.billedQtyController.text.trim()) ?? actualQty;
        final uomQty = double.tryParse(row.uomQtyController.text.trim()) ?? actualQty;
        final rate = double.tryParse(row.rateController.text.trim()) ?? 0.0;

        return CreditNoteItemInput(
          godownStockId: row.godownStockId,
          itemId: row.itemId!,
          godownId: row.godownId!,
          companyGodownId: _selectedCompanyGodownId,
          dcNo: row.dcNoController.text.trim(),
          lotNo: row.lotNoController.text.trim(),
          batchNo: row.dcNoController.text.trim(),
          uomId: row.uomId!,
          uomQuantity: uomQty,
          actualQuantity: actualQty,
          billedQuantity: billedQty,
          rate: rate,
          perId: row.perId!,
        );
      }).toList();

      bool success;
      if (isEditing) {
        final input = CreditNoteUpdateInput(
          date: _selectedDate,
          partyId: _selectedPartyId,
          purchaseTypeId: _selectedPurchaseTypeId,
          creditNoteTypeId: _selectedPurchaseTypeId,
          companyGodownId: _selectedCompanyGodownId,
          items: itemsInput,
          isGstBill: _isGstBill,
          gstPercentage: _isGstBill ? _selectedGstPercentage : 0.0,
          notes: _notesController.text.trim(),
        );
        success = await widget.creditNoteController.updateCreditNote(
          widget.existingCreditNote!.id,
          input,
        );
      } else {
        final input = CreditNoteCreateInput(
          date: _selectedDate,
          partyId: _selectedPartyId!,
          purchaseTypeId: _selectedPurchaseTypeId,
          creditNoteTypeId: _selectedPurchaseTypeId,
          companyGodownId: _selectedCompanyGodownId!,
          items: itemsInput,
          isGstBill: _isGstBill,
          gstPercentage: _isGstBill ? _selectedGstPercentage : 0.0,
          notes: _notesController.text.trim(),
        );
        success = await widget.creditNoteController.createCreditNote(input);
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          final err = widget.creditNoteController.errorMessage ?? 'Operation failed. Please try again.';
          _showError(err);
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
    final parties = widget.inventoryController.parties;
    final purchaseTypes = widget.inventoryController.purchaseTypes;
    final godowns = widget.inventoryController.godowns;
    final companyGodowns = godowns.where((g) => g.type == GodownType.companyGodown).toList();

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
      value: parties.any((p) => p.id == _selectedPartyId) ? _selectedPartyId : null,
      decoration: const InputDecoration(
        labelText: 'Party (Supplier / Customer) *',
        prefixIcon: Icon(Icons.business, size: 18),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: parties
          .where((p) => p.isActive || p.id == _selectedPartyId)
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text(p.partyCode.isNotEmpty ? '${p.name} (${p.partyCode})' : p.name, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedPartyId = val),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );

    final typeField = DropdownButtonFormField<String>(
      isExpanded: true,
      value: purchaseTypes.any((t) => t.id == _selectedPurchaseTypeId) ? _selectedPurchaseTypeId : null,
      decoration: const InputDecoration(
        labelText: 'Credit Note Type',
        prefixIcon: Icon(Icons.category, size: 18),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: purchaseTypes
          .where((t) => t.isActive || t.id == _selectedPurchaseTypeId)
          .map((t) => DropdownMenuItem(
                value: t.id,
                child: Text(t.name, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedPurchaseTypeId = val),
    );

    final companyGodownField = DropdownButtonFormField<String>(
      isExpanded: true,
      value: companyGodowns.any((g) => g.id == _selectedCompanyGodownId) ? _selectedCompanyGodownId : null,
      decoration: const InputDecoration(
        labelText: 'Company Godown *',
        prefixIcon: Icon(Icons.warehouse, size: 18),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: companyGodowns
          .map((g) => DropdownMenuItem(
                value: g.id,
                child: Text(g.name, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedCompanyGodownId = val),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note : Icons.note_alt,
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
                          isEditing
                              ? 'Edit Credit Note: ${widget.existingCreditNote!.creditNoteNumber}'
                              : 'New Credit Note Entry',
                          style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Creates inward stock batches into godown and records a credit note voucher',
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

              // Top row inputs: Responsive on Mobile vs Desktop
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
                companyGodownField,
                const SizedBox(height: 12),
                partyField,
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
                    Expanded(flex: 3, child: companyGodownField),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items to Receive (Inward Stock Created)',
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

              // Items Table Area
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
                            DataColumn(label: Text('Delivered Godown *', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('DC No', style: TextStyle(fontWeight: FontWeight.bold))),
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
                          rows: List.generate(_rows.length, (idx) => _buildCreditNoteRow(idx, godowns)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Bottom Section: Responsive for Mobile vs Desktop
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
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('0% GST')),
                          DropdownMenuItem(value: 5, child: Text('5% GST')),
                          DropdownMenuItem(value: 12, child: Text('12% GST')),
                          DropdownMenuItem(value: 18, child: Text('18% GST')),
                          DropdownMenuItem(value: 28, child: Text('28% GST')),
                        ],
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
                    labelText: 'Notes / Remarks',
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
                            '₹ ${_subTotal.toStringAsFixed(2)}',
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
                              '₹ ${_gstAmount.toStringAsFixed(2)}',
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
                            '₹ ${_totalAmount.toStringAsFixed(2)}',
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
                                  items: const [
                                    DropdownMenuItem(value: 0, child: Text('0% GST')),
                                    DropdownMenuItem(value: 5, child: Text('5% GST')),
                                    DropdownMenuItem(value: 12, child: Text('12% GST')),
                                    DropdownMenuItem(value: 18, child: Text('18% GST')),
                                    DropdownMenuItem(value: 28, child: Text('28% GST')),
                                  ],
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
                              labelText: 'Notes / Remarks',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

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
                                '₹ ${_subTotal.toStringAsFixed(2)}',
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
                                  '₹ ${_gstAmount.toStringAsFixed(2)}',
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
                                '₹ ${_totalAmount.toStringAsFixed(2)}',
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

              // Action buttons: Responsive for Mobile
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
                        icon: widget.creditNoteController.isSaving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check, size: 16),
                        label: Text(isEditing ? 'Update' : 'Record Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: widget.creditNoteController.isSaving ? null : _submit,
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
                      icon: widget.creditNoteController.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(isEditing ? 'Update Credit Note' : 'Record Credit Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: widget.creditNoteController.isSaving ? null : _submit,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildCreditNoteRow(int idx, List<GodownEntity> godowns) {
    final row = _rows[idx];
    final items = widget.inventoryController.items;
    final uoms = widget.inventoryController.uoms;
    final perUnits = widget.inventoryController.perUnits;

    final itemAmount = _calculateRowAmount(row);

    return DataRow(
      cells: [
        DataCell(Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        // 1. Item Name
        DataCell(
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: items.any((it) => it.id == row.itemId) ? row.itemId : null,
              decoration: const InputDecoration(
                hintText: 'Select Item',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: items
                  .where((it) => it.isActive || it.id == row.itemId)
                  .map((it) => DropdownMenuItem(
                        value: it.id,
                        child: Text(it.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => _onItemChanged(idx, val),
            ),
          ),
        ),
        // 2. Delivered Godown
        DataCell(
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: godowns.any((g) => g.id == row.godownId) ? row.godownId : null,
              decoration: const InputDecoration(
                hintText: 'Select Godown',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: godowns
                  .where((g) => g.isActive || g.id == row.godownId)
                  .map((g) => DropdownMenuItem(
                        value: g.id,
                        child: Text(g.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => row.godownId = val),
            ),
          ),
        ),
        // 3. DC No
        DataCell(
          SizedBox(
            width: 90,
            child: TextFormField(
              controller: row.dcNoController,
              decoration: const InputDecoration(
                hintText: 'DC No',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        // 4. Lot No
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
        // 5. UOM (Unit of Measurement) Dropdown
        DataCell(
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: uoms.any((u) => u.id == row.uomId) ? row.uomId : null,
              decoration: const InputDecoration(
                hintText: 'Select UOM',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: uoms
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
        // 6. UOM Qty
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
        // 7. Actual Qty
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
        // 7. Billed Qty
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
        // 8. Rate
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
        // 9. Per Unit
        DataCell(
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: perUnits.any((p) => p.id == row.perId) ? row.perId : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: perUnits
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
        // 10. Amount
        DataCell(
          Text(
            '₹ ${itemAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        // 11. Delete
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
