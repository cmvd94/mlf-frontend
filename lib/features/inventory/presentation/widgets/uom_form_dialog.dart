import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/uom_entity.dart';
import '../controllers/inventory_controller.dart';

class UomFormDialog extends StatefulWidget {
  final InventoryController controller;
  final UomEntity? uom;

  const UomFormDialog({
    super.key,
    required this.controller,
    this.uom,
  });

  @override
  State<UomFormDialog> createState() => _UomFormDialogState();
}

class _UomFormDialogState extends State<UomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSaving = false;

  bool get isEditing => widget.uom != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.uom?.name ?? '');
    _symbolController = TextEditingController(text: widget.uom?.symbol ?? '');
    _descriptionController = TextEditingController(text: widget.uom?.description ?? '');
    _isActive = widget.uom?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = isEditing
        ? await widget.controller.updateUom(
            widget.uom!.id,
            name: _nameController.text.trim(),
            symbol: _symbolController.text.trim().toUpperCase(),
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          )
        : await widget.controller.createUom(
            name: _nameController.text.trim(),
            symbol: _symbolController.text.trim().toUpperCase(),
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'UOM updated successfully' : 'UOM created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Failed to save UOM'),
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
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.straighten, color: Colors.teal, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Unit of Measurement' : 'Add Unit of Measurement (UOM)',
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
                          labelText: 'Formal Name *',
                          hintText: 'e.g. Kilogram, Pieces, Box',
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
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Symbol *',
                          hintText: 'e.g. KGS, PCS',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Symbol is required' : null,
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
                          : Text(isEditing ? 'Save Changes' : 'Create UOM'),
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
