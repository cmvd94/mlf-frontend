import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
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
  bool _isFullScreen = false;
  String? _formErrorMessage;

  void _showError(String message) {
    if (mounted) {
      setState(() => _formErrorMessage = message);
      AppNotification.showError(context, message);
    }
  }

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
        AppNotification.showSuccess(
          context,
          isEditing ? 'Item group updated successfully' : 'Item group created successfully',
        );
      } else {
        _showError(widget.controller.errorMessage ?? 'Failed to save item group');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: _isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isFullScreen ? double.infinity : 460,
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
                          : Text(isEditing ? 'Save Changes' : 'Create Group'),
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
