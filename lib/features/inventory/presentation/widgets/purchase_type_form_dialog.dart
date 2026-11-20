import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/purchase_type_entity.dart';
import '../controllers/inventory_controller.dart';

class PurchaseTypeFormDialog extends StatefulWidget {
  final InventoryController controller;
  final PurchaseTypeEntity? purchaseType;

  const PurchaseTypeFormDialog({
    super.key,
    required this.controller,
    this.purchaseType,
  });

  @override
  State<PurchaseTypeFormDialog> createState() => _PurchaseTypeFormDialogState();
}

class _PurchaseTypeFormDialogState extends State<PurchaseTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSaving = false;

  bool get isEditing => widget.purchaseType != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.purchaseType?.name ?? '');
    _codeController = TextEditingController(text: widget.purchaseType?.code ?? '');
    _descriptionController = TextEditingController(text: widget.purchaseType?.description ?? '');
    _isActive = widget.purchaseType?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = isEditing
        ? await widget.controller.updatePurchaseType(
            widget.purchaseType!.id,
            name: _nameController.text.trim(),
            code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          )
        : await widget.controller.createPurchaseType(
            name: _nameController.text.trim(),
            code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Purchase type updated successfully' : 'Purchase type created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Failed to save purchase type'),
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
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.category, color: Colors.indigo, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Purchase Type' : 'Add Purchase Type',
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Type Name *',
                    hintText: 'e.g. Local Purchase, Interstate, Import',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Type Code (Optional)',
                    hintText: 'e.g. LOCAL, INTERSTATE',
                    border: OutlineInputBorder(),
                  ),
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
                  subtitle: const Text('Inactive types cannot be selected in purchases'),
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
                          : Text(isEditing ? 'Save Changes' : 'Create Type'),
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
