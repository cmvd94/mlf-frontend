import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import '../../domain/entities/hsn_code_entity.dart';
import '../controllers/inventory_controller.dart';

class HsnCodeFormDialog extends StatefulWidget {
  final InventoryController controller;
  final HsnCodeEntity? hsnCode;

  const HsnCodeFormDialog({
    super.key,
    required this.controller,
    this.hsnCode,
  });

  @override
  State<HsnCodeFormDialog> createState() => _HsnCodeFormDialogState();
}

class _HsnCodeFormDialogState extends State<HsnCodeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _gstRateController;
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

  bool get isEditing => widget.hsnCode != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.hsnCode?.hsnCode ?? '');
    _gstRateController = TextEditingController(
      text: widget.hsnCode != null ? widget.hsnCode!.gstRate.toString() : '5',
    );
    _descriptionController = TextEditingController(text: widget.hsnCode?.description ?? '');
    _isActive = widget.hsnCode?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _gstRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      final gstRate = double.tryParse(_gstRateController.text.trim()) ?? 5.0;

      setState(() => _isSaving = true);
      final success = isEditing
          ? await widget.controller.updateHsnCode(
              widget.hsnCode!.id,
              hsnCode: _codeController.text.trim(),
              gstRate: gstRate,
              description: _descriptionController.text.trim(),
              isActive: _isActive,
            )
          : await widget.controller.createHsnCode(
              hsnCode: _codeController.text.trim(),
              gstRate: gstRate,
              description: _descriptionController.text.trim(),
              isActive: _isActive,
            );

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          AppNotification.showSuccess(
            context,
            isEditing ? 'HSN Code updated successfully' : 'HSN Code created successfully',
          );
        } else {
          _showError(widget.controller.errorMessage ?? 'Failed to save HSN code');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to save HSN code: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          maxWidth: _isFullScreen ? double.infinity : 480,
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
                        child: const Icon(Icons.tag, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit HSN Code' : 'Add HSN / SAC Code',
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
                  if (_formErrorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formErrorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'HSN / SAC Code *',
                            hintText: 'e.g. 60062300, 5208',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'HSN Code is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _gstRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'GST Rate (%)',
                            hintText: 'e.g. 5',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final rate = double.tryParse(v);
                              if (rate == null || rate < 0 || rate > 100) {
                                return '0 - 100';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g. Knitted or crocheted fabrics, Cotton shirtings',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Is Active'),
                    subtitle: const Text('Inactive HSN codes will not appear in item dropdowns'),
                    value: _isActive,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEditing ? 'Save Changes' : 'Create HSN Code'),
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
