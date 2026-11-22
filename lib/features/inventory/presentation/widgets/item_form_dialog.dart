import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import '../../domain/entities/item_entity.dart';
import '../controllers/inventory_controller.dart';

class ItemFormDialog extends StatefulWidget {
  final InventoryController controller;
  final ItemEntity? item;

  const ItemFormDialog({
    super.key,
    required this.controller,
    this.item,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _standardRateController;
  late final TextEditingController _openingStockController;

  String? _selectedItemGroupId;
  String? _selectedUomId;
  String? _selectedPerId;
  late bool _isActive;
  bool _isSaving = false;
  bool _isFullScreen = false;
  String? _formErrorMessage;

  void _showError(String message) {
    if (mounted) {
      setState(() => _formErrorMessage = message);
      AppNotification.showError(context, message);
    }
  }

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _codeController = TextEditingController(text: widget.item?.itemCode ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _standardRateController = TextEditingController(
      text: widget.item != null ? widget.item!.standardRate.toString() : '0',
    );
    _openingStockController = TextEditingController(
      text: widget.item != null ? widget.item!.currentStock.toString() : '0',
    );
    _selectedItemGroupId = widget.item?.itemGroupId;
    _selectedUomId = widget.item?.defaultUomId;
    _selectedPerId = widget.item?.defaultPerId;
    _isActive = widget.item?.isActive ?? true;

    // Default to first UOM and PerUnit if creating and masters are available
    if (!isEditing) {
      if (widget.controller.uoms.isNotEmpty) {
        _selectedUomId = widget.controller.uoms.first.id;
      }
      if (widget.controller.perUnits.isNotEmpty) {
        _selectedPerId = widget.controller.perUnits.first.id;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _standardRateController.dispose();
    _openingStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _formErrorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUomId == null || _selectedUomId!.isEmpty) {
      _showError('Please select a default UOM');
      return;
    }
    if (_selectedPerId == null || _selectedPerId!.isEmpty) {
      _showError('Please select a default Per Unit');
      return;
    }

    final rate = double.tryParse(_standardRateController.text.trim()) ?? 0.0;
    final openingStock = double.tryParse(_openingStockController.text.trim()) ?? 0.0;

    setState(() => _isSaving = true);
    final success = isEditing
        ? await widget.controller.updateItem(
            widget.item!.id,
            name: _nameController.text.trim(),
            itemCode: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
            itemGroupId: _selectedItemGroupId,
            description: _descriptionController.text.trim(),
            defaultUomId: _selectedUomId,
            defaultPerId: _selectedPerId,
            standardRate: rate,
            isActive: _isActive,
          )
        : await widget.controller.createItem(
            name: _nameController.text.trim(),
            itemCode: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
            itemGroupId: _selectedItemGroupId,
            description: _descriptionController.text.trim(),
            defaultUomId: _selectedUomId!,
            defaultPerId: _selectedPerId!,
            standardRate: rate,
            openingStock: openingStock,
            isActive: _isActive,
          );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        AppNotification.showSuccess(
          context,
          isEditing ? 'Item updated successfully' : 'Item created successfully',
        );
      } else {
        _showError(widget.controller.errorMessage ?? 'Failed to save item');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemGroups = widget.controller.itemGroups.isNotEmpty
        ? widget.controller.itemGroups
        : widget.controller.masters.itemGroups;
    final uoms = widget.controller.uoms.isNotEmpty
        ? widget.controller.uoms
        : widget.controller.masters.uoms;
    final perUnits = widget.controller.perUnits.isNotEmpty
        ? widget.controller.perUnits
        : widget.controller.masters.perUnits;

    return Dialog(
      insetPadding: _isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isFullScreen ? double.infinity : 520,
          maxHeight: _isFullScreen ? double.infinity : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Item' : 'Add New Item',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
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
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name *',
                            hintText: 'e.g. Mild Steel Rod 12mm',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Item name is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Item Code',
                            hintText: 'Auto if empty',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: itemGroups.any((g) => g.id == _selectedItemGroupId) ? _selectedItemGroupId : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Item Group (Category)',
                      hintText: 'Select Item Group (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('-- None (General) --'),
                      ),
                      ...itemGroups.map((g) {
                        return DropdownMenuItem<String>(
                          value: g.id,
                          child: Text(
                            g.code.isNotEmpty ? '${g.name} (${g.code})' : g.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (val) => setState(() => _selectedItemGroupId = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: uoms.any((u) => u.id == _selectedUomId) ? _selectedUomId : null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Default UOM *',
                            border: OutlineInputBorder(),
                          ),
                          items: uoms.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(
                                '${u.name} (${u.symbol})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedUomId = val),
                          validator: (v) => v == null ? 'UOM is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: perUnits.any((p) => p.id == _selectedPerId) ? _selectedPerId : null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Default Per Unit *',
                            border: OutlineInputBorder(),
                          ),
                          items: perUnits.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                '${p.name} (${p.symbol})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedPerId = val),
                          validator: (v) => v == null ? 'Per unit is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _standardRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Standard Rate (₹)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _openingStockController,
                          enabled: !isEditing,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: isEditing ? 'Current Stock' : 'Opening Stock',
                            helperText: isEditing ? 'Reflected by purchases' : 'Initial stock value',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active Status'),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_formErrorMessage != null) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
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

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEditing ? 'Save Changes' : 'Create Item'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
