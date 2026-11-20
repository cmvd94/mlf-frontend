import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/item_group_entity.dart';
import '../controllers/inventory_controller.dart';

class ItemGroupFormDialog extends StatefulWidget {
  final InventoryController controller;
  final ItemGroupEntity? itemGroup;

  const ItemGroupFormDialog({
    super.key,
    required this.controller,
    this.itemGroup,
  });

  @override
  State<ItemGroupFormDialog> createState() => _ItemGroupFormDialogState();
}

class _ItemGroupFormDialogState extends State<ItemGroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  bool _isSaving = false;

  bool get isEditing => widget.itemGroup != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemGroup?.name ?? '');
    _codeController = TextEditingController(text: widget.itemGroup?.code ?? '');
    _descriptionController = TextEditingController(text: widget.itemGroup?.description ?? '');
    _isActive = widget.itemGroup?.isActive ?? true;
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
        ? await widget.controller.updateItemGroup(
            widget.itemGroup!.id,
            name: _nameController.text.trim(),
            code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
            description: _descriptionController.text.trim(),
            isActive: _isActive,
          )
        : await widget.controller.createItemGroup(
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
            content: Text(isEditing ? 'Item group updated successfully' : 'Item group created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Failed to save item group'),
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
                      child: const Icon(Icons.folder, color: Colors.teal, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Item Group' : 'Add Item Group',
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
                    labelText: 'Item Group Name *',
                    hintText: 'e.g. Raw Materials, Finished Goods, Tools',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Group Code (Optional)',
                    hintText: 'e.g. RAW, FINISHED, SPARES',
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
                  subtitle: const Text('Inactive groups cannot be assigned to items'),
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
                          : Text(isEditing ? 'Save Changes' : 'Create Group'),
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
