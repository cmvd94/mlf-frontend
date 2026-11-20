import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/per_unit_entity.dart';
import '../controllers/inventory_controller.dart';

class PerUnitFormDialog extends StatefulWidget {
  final InventoryController controller;
  final PerUnitEntity? perUnit;

  const PerUnitFormDialog({
    super.key,
    required this.controller,
    this.perUnit,
  });

  @override
  State<PerUnitFormDialog> createState() => _PerUnitFormDialogState();
}

class _PerUnitFormDialogState extends State<PerUnitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  late final TextEditingController _multiplierController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSaving = false;

  bool get isEditing => widget.perUnit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.perUnit?.name ?? '');
    _symbolController = TextEditingController(text: widget.perUnit?.symbol ?? '');
    _multiplierController = TextEditingController(
      text: widget.perUnit != null ? widget.perUnit!.multiplier.toString() : '1',
    );
    _descriptionController = TextEditingController(text: widget.perUnit?.description ?? '');
    _isActive = widget.perUnit?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _multiplierController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final multiplier = double.tryParse(_multiplierController.text.trim()) ?? 1.0;

    setState(() => _isSaving = true);
    final success = isEditing
        ? await widget.controller.updatePerUnit(
            widget.perUnit!.id,
            name: _nameController.text.trim(),
            symbol: _symbolController.text.trim(),
            multiplier: multiplier,
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          )
        : await widget.controller.createPerUnit(
            name: _nameController.text.trim(),
            symbol: _symbolController.text.trim(),
            multiplier: multiplier,
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Per unit updated successfully' : 'Per unit created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Failed to save per unit'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calculate, color: Colors.orange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Per Unit' : 'Add Per Unit Master',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
                          labelText: 'Per Unit Name *',
                          hintText: 'e.g. per Kg, per Box, per 100 Pcs',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _symbolController,
                        decoration: const InputDecoration(
                          labelText: 'Symbol *',
                          hintText: 'e.g. kg, box, 100pcs',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Symbol is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _multiplierController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unit Multiplier *',
                    hintText: '1 for standard, 100 for per hundred',
                    helperText: 'Standard is 1 (e.g. Rate is per 1 unit)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Multiplier is required';
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Must be a positive number';
                    return null;
                  },
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
                          : Text(isEditing ? 'Save Changes' : 'Create Per Unit'),
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
