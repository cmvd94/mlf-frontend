import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/admin/domain/entities/access_scope_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_role.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_user_entity.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';

class AdminFormDialog extends StatefulWidget {
  final AdminController controller;
  final AdminUserEntity? userToEdit;

  const AdminFormDialog({
    super.key,
    required this.controller,
    this.userToEdit,
  });

  bool get isEditing => userToEdit != null;

  @override
  State<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends State<AdminFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isFullScreen = false;

  late final TextEditingController _nameController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late AdminRole _selectedRole;
  bool _obscurePassword = true;

  // Access Scope State
  String? _selectedCountry;
  String? _selectedZone;
  String? _selectedState;
  String? _selectedDistrict;

  List<AdminRole> get _availableRoles {
    final assignable = widget.controller.adminList.assignableRoles;
    if (assignable.isNotEmpty) {
      if (widget.isEditing && !assignable.contains(widget.userToEdit!.role)) {
        return [widget.userToEdit!.role, ...assignable];
      }
      return assignable;
    }
    return AdminRole.selectableRoles;
  }

  bool get _isRoleEditable {
    if (!widget.isEditing) return true;
    final assignable = widget.controller.adminList.assignableRoles;
    if (assignable.isEmpty) return true;
    return assignable.contains(widget.userToEdit!.role);
  }

  // Hierarchy requirements based on backend policy
  bool get _requiresCountry => true;
  bool get _requiresZone =>
      _selectedRole != AdminRole.generalManager &&
      _selectedRole != AdminRole.superAdmin;
  bool get _requiresState =>
      _requiresZone && _selectedRole != AdminRole.zoneHead;
  bool get _requiresDistrict =>
      _requiresState && _selectedRole != AdminRole.regionalManager;

  @override
  void initState() {
    super.initState();
    final user = widget.userToEdit;

    _nameController = TextEditingController(text: user?.name ?? '');
    _employeeIdController = TextEditingController(text: user?.employeeId ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();

    if (user != null) {
      _selectedRole = user.role;
      _selectedCountry = user.accessScope?.country;
      _selectedZone = user.accessScope?.zone;
      _selectedState = user.accessScope?.state;
      _selectedDistrict = user.accessScope?.district;
    } else {
      final available = _availableRoles;
      _selectedRole =
          available.isNotEmpty ? available.first : AdminRole.assistant;

      // Initialize default scope selections from tree
      final countries = widget.controller.getCountries();
      _selectedCountry = countries.isNotEmpty ? countries.first : 'India';

      final zones = widget.controller.getZones(_selectedCountry);
      _selectedZone = zones.isNotEmpty ? zones.first : null;

      final states = widget.controller.getStates(_selectedCountry, _selectedZone);
      _selectedState = states.isNotEmpty ? states.first : null;

      final districts = widget.controller.getDistricts(
        _selectedCountry,
        _selectedZone,
        _selectedState,
      );
      _selectedDistrict = districts.isNotEmpty ? districts.first : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AccessScopeEntity _buildAccessScopeForRole() {
    switch (_selectedRole) {
      case AdminRole.generalManager:
        return AccessScopeEntity(country: _selectedCountry);
      case AdminRole.zoneHead:
        return AccessScopeEntity(
          country: _selectedCountry,
          zone: _selectedZone,
        );
      case AdminRole.regionalManager:
        return AccessScopeEntity(
          country: _selectedCountry,
          zone: _selectedZone,
          state: _selectedState,
        );
      case AdminRole.districtManager:
      case AdminRole.godownManager:
      case AdminRole.supervisor:
      case AdminRole.assistant:
      case AdminRole.billingUser:
      default:
        return AccessScopeEntity(
          country: _selectedCountry,
          zone: _selectedZone,
          state: _selectedState,
          district: _selectedDistrict,
        );
    }
  }

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      final name = _nameController.text.trim();
      final employeeId = _employeeIdController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final accessScope = _buildAccessScopeForRole();

      bool success;
      if (widget.isEditing) {
        success = await widget.controller.updateUser(
          id: widget.userToEdit!.id,
          name: name,
          employeeId: employeeId.isNotEmpty ? employeeId : null,
          email: email,
          role: _selectedRole.value,
          accessScope: accessScope,
        );
      } else {
        success = await widget.controller.createUser(
          name: name,
          employeeId: employeeId.isNotEmpty ? employeeId : null,
          phoneNumber: phone,
          email: email,
          password: password.isNotEmpty ? password : null,
          role: _selectedRole.value,
          accessScope: accessScope,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted && widget.controller.errorMessage != null) {
        AppNotification.showError(context, widget.controller.errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(context, 'Failed to save admin user: $e');
      }
    }
  }

  String _getScopePolicyDescription() {
    switch (_selectedRole) {
      case AdminRole.generalManager:
        return 'General Manager jurisdiction covers entire country.';
      case AdminRole.zoneHead:
        return 'Zone Head jurisdiction covers national zone (Country + Zone).';
      case AdminRole.regionalManager:
        return 'Regional Manager jurisdiction covers entire state (Country + Zone + State).';
      default:
        return 'Jurisdiction requires district assignment (Country + Zone + State + District).';
    }
  }

  Widget _buildScopeCard() {
    final countries = widget.controller.getCountries();
    final zones = widget.controller.getZones(_selectedCountry);
    final states = widget.controller.getStates(_selectedCountry, _selectedZone);
    final districts = widget.controller.getDistricts(
      _selectedCountry,
      _selectedZone,
      _selectedState,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.travel_explore, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Access Scope (Jurisdiction)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getScopePolicyDescription(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),

          // Country Selector
          DropdownButtonFormField<String>(
            value: countries.contains(_selectedCountry) ? _selectedCountry : null,
            decoration: const InputDecoration(
              labelText: 'Country *',
              prefixIcon: Icon(Icons.public),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: countries.map((c) {
              return DropdownMenuItem<String>(value: c, child: Text(c));
            }).toList(),
            onChanged: (newCountry) {
              setState(() {
                _selectedCountry = newCountry;
                final newZones = widget.controller.getZones(newCountry);
                _selectedZone = newZones.isNotEmpty ? newZones.first : null;

                final newStates = widget.controller.getStates(newCountry, _selectedZone);
                _selectedState = newStates.isNotEmpty ? newStates.first : null;

                final newDistricts = widget.controller.getDistricts(
                  newCountry,
                  _selectedZone,
                  _selectedState,
                );
                _selectedDistrict =
                    newDistricts.isNotEmpty ? newDistricts.first : null;
              });
            },
            validator: (val) {
              if (_requiresCountry && (val == null || val.isEmpty)) {
                return 'Country is required';
              }
              return null;
            },
          ),

          // Zone Selector (if applicable)
          if (_requiresZone) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: zones.contains(_selectedZone) ? _selectedZone : null,
              decoration: const InputDecoration(
                labelText: 'Zone *',
                prefixIcon: Icon(Icons.explore_outlined),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: zones.map((z) {
                return DropdownMenuItem<String>(value: z, child: Text(z));
              }).toList(),
              onChanged: (newZone) {
                setState(() {
                  _selectedZone = newZone;
                  final newStates =
                      widget.controller.getStates(_selectedCountry, newZone);
                  _selectedState = newStates.isNotEmpty ? newStates.first : null;

                  final newDistricts = widget.controller.getDistricts(
                    _selectedCountry,
                    newZone,
                    _selectedState,
                  );
                  _selectedDistrict =
                      newDistricts.isNotEmpty ? newDistricts.first : null;
                });
              },
              validator: (val) {
                if (_requiresZone && (val == null || val.isEmpty)) {
                  return 'Zone is required';
                }
                return null;
              },
            ),
          ],

          // State Selector (if applicable)
          if (_requiresState) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: states.contains(_selectedState) ? _selectedState : null,
              decoration: const InputDecoration(
                labelText: 'State *',
                prefixIcon: Icon(Icons.map_outlined),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: states.map((s) {
                return DropdownMenuItem<String>(value: s, child: Text(s));
              }).toList(),
              onChanged: (newState) {
                setState(() {
                  _selectedState = newState;
                  final newDistricts = widget.controller.getDistricts(
                    _selectedCountry,
                    _selectedZone,
                    newState,
                  );
                  _selectedDistrict =
                      newDistricts.isNotEmpty ? newDistricts.first : null;
                });
              },
              validator: (val) {
                if (_requiresState && (val == null || val.isEmpty)) {
                  return 'State is required';
                }
                return null;
              },
            ),
          ],

          // District Selector (if applicable)
          if (_requiresDistrict) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: districts.contains(_selectedDistrict)
                  ? _selectedDistrict
                  : null,
              decoration: const InputDecoration(
                labelText: 'District *',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: districts.map((d) {
                return DropdownMenuItem<String>(value: d, child: Text(d));
              }).toList(),
              onChanged: (newDistrict) {
                setState(() => _selectedDistrict = newDistrict);
              },
              validator: (val) {
                if (_requiresDistrict && (val == null || val.isEmpty)) {
                  return 'District is required';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
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
          maxWidth: _isFullScreen ? double.infinity : 540,
          maxHeight: _isFullScreen ? double.infinity : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isEditing ? Icons.edit : Icons.person_add,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isEditing
                              ? 'Edit Admin User'
                              : 'Create New Admin User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          color: Colors.grey,
                        ),
                        tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen View',
                        onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Employee ID
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: InputDecoration(
                      labelText: widget.isEditing
                          ? 'Employee ID *'
                          : 'Employee ID (Optional - Auto-generated)',
                      hintText: widget.isEditing
                          ? 'e.g. mlf_01'
                          : 'Leave blank to auto-generate',
                      helperText: widget.isEditing
                          ? 'Format: mlf_01, mlf_02, etc.'
                          : 'Leave blank to auto-generate sequence (e.g. mlf_02)',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (widget.isEditing &&
                          (val == null || val.trim().isEmpty)) {
                        return 'Employee ID is required';
                      }
                      if (val != null && val.trim().isNotEmpty) {
                        final regex = RegExp(r'^mlf_\d+$', caseSensitive: false);
                        if (!regex.hasMatch(val.trim())) {
                          return 'Must follow format mlf_01, mlf_02, etc.';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    enabled: !widget.isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: widget.isEditing
                          ? 'Phone Number (Locked)'
                          : 'Phone Number (10 digits) *',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: const OutlineInputBorder(),
                      helperText: widget.isEditing
                          ? 'Phone number cannot be changed'
                          : '10-digit number used for authentication',
                    ),
                    validator: (val) {
                      if (widget.isEditing) return null;
                      if (val == null || val.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (val.trim().length != 10 ||
                          !RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                        return 'Phone number must be exactly 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  DropdownButtonFormField<AdminRole>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: _isRoleEditable ? 'Role *' : 'Role (locked)',
                      prefixIcon: const Icon(Icons.security),
                      border: const OutlineInputBorder(),
                      helperText: _isRoleEditable
                          ? null
                          : 'Your role does not allow changing this role',
                    ),
                    items: _availableRoles.map((role) {
                      return DropdownMenuItem<AdminRole>(
                        value: role,
                        child: Text(role.label),
                      );
                    }).toList(),
                    onChanged: _isRoleEditable
                        ? (newRole) {
                            if (newRole != null) {
                              setState(() => _selectedRole = newRole);
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Access Scope Section (Cascading Country, Zone, State, District)
                  _buildScopeCard(),
                  const SizedBox(height: 16),

                  // Password (Required for create, optional/hidden for edit)
                  if (!widget.isEditing) ...[
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Initial Password *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        helperText: 'Minimum 6 characters',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Error notification if present
                  AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) {
                      if (widget.controller.errorMessage != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.controller.errorMessage!,
                                  style: const TextStyle(
                                      color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      AnimatedBuilder(
                        animation: widget.controller,
                        builder: (context, _) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: widget.controller.isActionLoading
                                ? null
                                : _submit,
                            child: widget.controller.isActionLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(widget.isEditing
                                    ? 'Save Changes'
                                    : 'Create User'),
                          );
                        },
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
