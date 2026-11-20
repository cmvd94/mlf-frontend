import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import '../../domain/entities/party_entity.dart';
import '../controllers/inventory_controller.dart';

class PartyFormDialog extends StatefulWidget {
  final InventoryController controller;
  final PartyEntity? party;

  const PartyFormDialog({
    super.key,
    required this.controller,
    this.party,
  });

  @override
  State<PartyFormDialog> createState() => _PartyFormDialogState();
}

class _PartyFormDialogState extends State<PartyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _partyCodeController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstinController;
  late bool _isActive;
  bool _isSaving = false;

  bool get isEditing => widget.party != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.party?.name ?? '');
    _partyCodeController = TextEditingController(text: widget.party?.partyCode ?? '');
    _contactPersonController = TextEditingController(text: widget.party?.contactPerson ?? '');
    _phoneNumberController = TextEditingController(text: widget.party?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.party?.email ?? '');
    _addressController = TextEditingController(text: widget.party?.address ?? '');
    _gstinController = TextEditingController(text: widget.party?.gstin ?? '');
    _isActive = widget.party?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _partyCodeController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = isEditing
        ? await widget.controller.updateParty(
            widget.party!.id,
            name: _nameController.text.trim(),
            partyCode: _partyCodeController.text.trim().isEmpty ? null : _partyCodeController.text.trim(),
            contactPerson: _contactPersonController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            gstin: _gstinController.text.trim(),
            isActive: _isActive,
          )
        : await widget.controller.createParty(
            name: _nameController.text.trim(),
            partyCode: _partyCodeController.text.trim().isEmpty ? null : _partyCodeController.text.trim(),
            contactPerson: _contactPersonController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            gstin: _gstinController.text.trim(),
            isActive: _isActive,
          );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Party updated successfully' : 'Party created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Failed to save party'),
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
        constraints: const BoxConstraints(maxWidth: 520),
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
                        child: const Icon(Icons.business, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Party' : 'Add New Party',
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
                      labelText: 'Party / Supplier Name *',
                      hintText: 'e.g. Acme Corporation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Party name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _partyCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Party Code (Optional)',
                            hintText: 'Auto-generated if empty',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _contactPersonController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Person',
                            hintText: 'e.g. John Doe',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'e.g. 9876543210',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'e.g. supplier@domain.com',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gstinController,
                    decoration: const InputDecoration(
                      labelText: 'GSTIN / Tax ID (Optional)',
                      hintText: 'e.g. 29ABCDE1234F1Z5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Full physical address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active Status'),
                    subtitle: const Text('Inactive parties are hidden from purchase dropdowns'),
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
                            : Text(isEditing ? 'Save Changes' : 'Create Party'),
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
