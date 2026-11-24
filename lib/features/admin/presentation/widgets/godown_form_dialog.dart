import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';
import '../../domain/entities/godown_entity.dart';
import '../controllers/godown_controller.dart';

class GodownFormDialog extends StatefulWidget {
  final GodownController controller;
  final GodownEntity? godownToEdit;
  final GodownType? defaultType;

  const GodownFormDialog({
    super.key,
    required this.controller,
    this.godownToEdit,
    this.defaultType,
  });

  bool get isEditing => godownToEdit != null;

  @override
  State<GodownFormDialog> createState() => _GodownFormDialogState();
}

class _GodownFormDialogState extends State<GodownFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _godownIdController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pincodeController;

  late GodownType _selectedType;
  late bool _isActive;
  bool _isFullScreen = false;
  String? _formErrorMessage;

  void _showError(String message) {
    if (mounted) {
      setState(() => _formErrorMessage = message);
      AppNotification.showError(context, message);
    }
  }

  // Regional Scope State
  String? _selectedCountry;
  String? _selectedZone;
  String? _selectedState;
  String? _selectedDistrict;

  // Assigned Staff State
  String? _selectedManagerId;
  String? _selectedBillingUserId;
  final List<String> _selectedSupervisorIds = [];
  final List<String> _selectedAssistantIds = [];

  // Eligible Staff Cache
  List<AssignedAdminEntity> _eligibleAdmins = [];
  bool _isLoadingAdmins = false;

  final Map<String, dynamic> _scopeTree = AdminController.defaultAccessScopeTree;

  List<String> getCountries() => _scopeTree.keys.toList();

  List<String> getZones(String? country) {
    if (country == null || !_scopeTree.containsKey(country)) return [];
    final val = _scopeTree[country];
    if (val is Map) return val.keys.cast<String>().toList();
    return [];
  }

  List<String> getStates(String? country, String? zone) {
    if (country == null || zone == null) return [];
    final countryMap = _scopeTree[country];
    if (countryMap is Map && countryMap.containsKey(zone)) {
      final zoneMap = countryMap[zone];
      if (zoneMap is Map) return zoneMap.keys.cast<String>().toList();
    }
    return [];
  }

  List<String> getDistricts(String? country, String? zone, String? state) {
    if (country == null || zone == null || state == null) return [];
    final countryMap = _scopeTree[country];
    if (countryMap is Map && countryMap.containsKey(zone)) {
      final zoneMap = countryMap[zone];
      if (zoneMap is Map && zoneMap.containsKey(state)) {
        final stateMap = zoneMap[state];
        if (stateMap is Map) return stateMap.keys.cast<String>().toList();
      }
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    final godown = widget.godownToEdit;

    _nameController = TextEditingController(text: godown?.name ?? '');
    _godownIdController = TextEditingController(text: godown?.godownId ?? '');
    _descriptionController = TextEditingController(text: godown?.description ?? '');
    _pincodeController = TextEditingController(text: godown?.pincode ?? '641001');

    _selectedType = godown?.type ?? widget.defaultType ?? GodownType.companyGodown;
    _isActive = godown?.isActive ?? true;

    if (godown != null) {
      _selectedCountry = godown.country;
      _selectedZone = godown.zone;
      _selectedState = godown.state;
      _selectedDistrict = godown.district;

      _selectedManagerId = godown.godownManager?.id;
      _selectedBillingUserId = godown.billingUser?.id;
      _selectedSupervisorIds.addAll(godown.supervisors.map((s) => s.id));
      _selectedAssistantIds.addAll(godown.assistants.map((a) => a.id));
    } else {
      // Default to first location in hierarchy
      final countries = getCountries();
      _selectedCountry = countries.isNotEmpty ? countries.first : 'India';

      final zones = getZones(_selectedCountry);
      _selectedZone = zones.isNotEmpty ? zones.first : 'SouthZone';

      final states = getStates(_selectedCountry, _selectedZone);
      _selectedState = states.isNotEmpty ? states.first : 'TamilNadu';

      final districts = getDistricts(_selectedCountry, _selectedZone, _selectedState);
      _selectedDistrict = districts.isNotEmpty ? districts.first : 'Coimbatore';
    }

    if (_selectedType != GodownType.jobworkGodown) {
      _loadEligibleAdmins();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _godownIdController.dispose();
    _descriptionController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadEligibleAdmins() async {
    if (_selectedType == GodownType.jobworkGodown) {
      if (mounted) {
        setState(() {
          _eligibleAdmins = [];
          _isLoadingAdmins = false;
        });
      }
      return;
    }
    setState(() => _isLoadingAdmins = true);
    try {
      final admins = await widget.controller.fetchEligibleAdmins(
        country: _selectedCountry,
        zone: _selectedZone,
        state: _selectedState,
        district: _selectedDistrict,
      );

      if (mounted) {
        setState(() {
          _eligibleAdmins = admins;
        });
      }
    } catch (e) {
      AppLogger().e('Error loading eligible admins: $e', tag: 'GodownForm');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAdmins = false);
      }
    }
  }

  List<AssignedAdminEntity> get _managers => _eligibleAdmins
      .where((a) => a.role.toUpperCase() == 'GODOWN_MANAGER')
      .toList();

  List<AssignedAdminEntity> get _supervisors => _eligibleAdmins
      .where((a) => a.role.toUpperCase() == 'SUPERVISOR')
      .toList();

  List<AssignedAdminEntity> get _assistants => _eligibleAdmins
      .where((a) => a.role.toUpperCase() == 'ASSISTANT')
      .toList();

  List<AssignedAdminEntity> get _billingUsers => _eligibleAdmins
      .where((a) => a.role.toUpperCase() == 'BILLING_USER')
      .toList();

  Future<void> _submit() async {
    setState(() => _formErrorMessage = null);

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_selectedCountry == null ||
          _selectedZone == null ||
          _selectedState == null ||
          _selectedDistrict == null) {
        _showError('Please select all regional scope fields (Country, Zone, State, District)');
        return;
      }

      final bool isJobwork = _selectedType == GodownType.jobworkGodown;
      bool success = false;
      if (widget.isEditing) {
        success = await widget.controller.updateGodown(
          id: widget.godownToEdit!.id,
          name: _nameController.text.trim(),
          godownId: _godownIdController.text.trim().isNotEmpty
              ? _godownIdController.text.trim()
              : null,
          type: _selectedType,
          description: _descriptionController.text.trim(),
          isActive: _isActive,
          godownManagerId: isJobwork ? null : _selectedManagerId,
          clearGodownManager: isJobwork || _selectedManagerId == null,
          supervisorId: isJobwork ? null : _selectedSupervisorIds,
          assistantId: isJobwork ? null : _selectedAssistantIds,
          billingUserId: isJobwork ? null : _selectedBillingUserId,
          clearBillingUser: isJobwork || _selectedBillingUserId == null,
        );
      } else {
        success = await widget.controller.createGodown(
          name: _nameController.text.trim(),
          godownId: _godownIdController.text.trim().isNotEmpty
              ? _godownIdController.text.trim()
              : null,
          type: _selectedType,
          description: _descriptionController.text.trim(),
          country: _selectedCountry!,
          zone: _selectedZone!,
          state: _selectedState!,
          district: _selectedDistrict!,
          pincode: _pincodeController.text.trim(),
          godownManagerId: isJobwork ? null : _selectedManagerId,
          supervisorId: isJobwork ? null : _selectedSupervisorIds,
          assistantId: isJobwork ? null : _selectedAssistantIds,
          billingUserId: isJobwork ? null : _selectedBillingUserId,
          isActive: _isActive,
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted && widget.controller.errorMessage != null) {
        _showError(widget.controller.errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countryList = getCountries();
    if (_selectedCountry != null && !countryList.contains(_selectedCountry)) {
      countryList.add(_selectedCountry!);
    }

    final zoneList = getZones(_selectedCountry);
    if (_selectedZone != null && !zoneList.contains(_selectedZone)) {
      zoneList.add(_selectedZone!);
    }

    final stateList = getStates(_selectedCountry, _selectedZone);
    if (_selectedState != null && !stateList.contains(_selectedState)) {
      stateList.add(_selectedState!);
    }

    final districtList = getDistricts(_selectedCountry, _selectedZone, _selectedState);
    if (_selectedDistrict != null && !districtList.contains(_selectedDistrict)) {
      districtList.add(_selectedDistrict!);
    }

    // Build Manager Dropdown items safely
    final managerItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(
        value: null,
        child: Text('None / Unassigned', style: TextStyle(color: Colors.grey)),
      ),
    ];
    if (_selectedManagerId != null && !_managers.any((m) => m.id == _selectedManagerId)) {
      final current = widget.godownToEdit?.godownManager;
      managerItems.add(
        DropdownMenuItem(
          value: _selectedManagerId,
          child: Text(
            current != null ? '${current.name} (${current.employeeId})' : 'Assigned Manager',
          ),
        ),
      );
    }
    for (final m in _managers) {
      managerItems.add(
        DropdownMenuItem(
          value: m.id,
          child: Text('${m.name} (${m.employeeId})'),
        ),
      );
    }

    // Build Billing User Dropdown items safely
    final billingItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(
        value: null,
        child: Text('None / Unassigned', style: TextStyle(color: Colors.grey)),
      ),
    ];
    if (_selectedBillingUserId != null && !_billingUsers.any((b) => b.id == _selectedBillingUserId)) {
      final current = widget.godownToEdit?.billingUser;
      billingItems.add(
        DropdownMenuItem(
          value: _selectedBillingUserId,
          child: Text(
            current != null ? '${current.name} (${current.employeeId})' : 'Assigned Billing User',
          ),
        ),
      );
    }
    for (final b in _billingUsers) {
      billingItems.add(
        DropdownMenuItem(
          value: b.id,
          child: Text('${b.name} (${b.employeeId})'),
        ),
      );
    }

    // Merge available staff with current assignments so chips never vanish during async loading
    final availableSupervisors = [
      ..._supervisors,
      if (widget.godownToEdit != null)
        ...widget.godownToEdit!.supervisors.where((s) => !_supervisors.any((m) => m.id == s.id)),
    ];

    final availableAssistants = [
      ..._assistants,
      if (widget.godownToEdit != null)
        ...widget.godownToEdit!.assistants.where((a) => !_assistants.any((m) => m.id == a.id)),
    ];

    return Dialog(
      insetPadding: _isFullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isFullScreen ? double.infinity : 620,
          maxHeight: _isFullScreen ? double.infinity : 780,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.warehouse,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing ? 'Edit Godown' : 'Create New Godown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.isEditing
                                ? 'Update details, region, or staff assignments'
                                : 'Add a company or jobwork godown with regional jurisdiction',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Details
                        const Text(
                          'General Information',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name & Type
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Godown Name *',
                                  hintText: 'e.g. Coimbatore Main Depot',
                                  prefixIcon: Icon(Icons.apartment, size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter godown name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<GodownType>(
                                value: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Godown Type *',
                                  prefixIcon: Icon(Icons.category, size: 20),
                                ),
                                items: GodownType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedType = val;
                                      if (val == GodownType.jobworkGodown) {
                                        _selectedManagerId = null;
                                        _selectedBillingUserId = null;
                                        _selectedSupervisorIds.clear();
                                        _selectedAssistantIds.clear();
                                      }
                                    });
                                    if (val == GodownType.companyGodown) {
                                      _loadEligibleAdmins();
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Godown ID & Pincode
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _godownIdController,
                                decoration: const InputDecoration(
                                  labelText: 'Godown ID (Optional)',
                                  hintText: 'Auto-generated if empty',
                                  prefixIcon: Icon(Icons.tag, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Pin Code *',
                                  hintText: '6-digit PIN code',
                                  prefixIcon: Icon(Icons.pin_drop, size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter PIN code';
                                  }
                                  if (!RegExp(r'^\d{6}$').hasMatch(val.trim())) {
                                    return 'PIN code must be 6 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Notes regarding location, capacity, or jobwork client',
                            prefixIcon: Icon(Icons.notes, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Regional Jurisdiction
                        const Text(
                          'Regional Scope (Matches Company Hierarchy)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Only admins having access to this region can manage this godown.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),

                        // Country & Zone
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCountry,
                                decoration: const InputDecoration(
                                  labelText: 'Country *',
                                  prefixIcon: Icon(Icons.public, size: 20),
                                ),
                                items: countryList.map((c) {
                                  return DropdownMenuItem(value: c, child: Text(c));
                                }).toList(),
                                onChanged: widget.isEditing
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedCountry = val;
                                          final zones = getZones(val);
                                          _selectedZone = zones.isNotEmpty ? zones.first : null;
                                          final states = getStates(val, _selectedZone);
                                          _selectedState = states.isNotEmpty ? states.first : null;
                                          final districts = getDistricts(val, _selectedZone, _selectedState);
                                          _selectedDistrict = districts.isNotEmpty ? districts.first : null;
                                        });
                                        _loadEligibleAdmins();
                                      },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedZone,
                                decoration: const InputDecoration(
                                  labelText: 'Zone *',
                                  prefixIcon: Icon(Icons.map, size: 20),
                                ),
                                items: zoneList.map((z) {
                                  return DropdownMenuItem(value: z, child: Text(z));
                                }).toList(),
                                onChanged: widget.isEditing
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedZone = val;
                                          final states = getStates(_selectedCountry, val);
                                          _selectedState = states.isNotEmpty ? states.first : null;
                                          final districts = getDistricts(_selectedCountry, val, _selectedState);
                                          _selectedDistrict = districts.isNotEmpty ? districts.first : null;
                                        });
                                        _loadEligibleAdmins();
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // State & District
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedState,
                                decoration: const InputDecoration(
                                  labelText: 'State *',
                                  prefixIcon: Icon(Icons.location_city, size: 20),
                                ),
                                items: stateList.map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s));
                                }).toList(),
                                onChanged: widget.isEditing
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedState = val;
                                          final districts = getDistricts(_selectedCountry, _selectedZone, val);
                                          _selectedDistrict = districts.isNotEmpty ? districts.first : null;
                                        });
                                        _loadEligibleAdmins();
                                      },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedDistrict,
                                decoration: const InputDecoration(
                                  labelText: 'District *',
                                  prefixIcon: Icon(Icons.share_location, size: 20),
                                ),
                                items: districtList.map((d) {
                                  return DropdownMenuItem(value: d, child: Text(d));
                                }).toList(),
                                onChanged: widget.isEditing
                                    ? null
                                    : (val) {
                                        setState(() => _selectedDistrict = val);
                                        _loadEligibleAdmins();
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Assigned Admin Section (Company Godown only)
                        if (_selectedType == GodownType.jobworkGodown) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 22, color: Colors.amber.shade900),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jobwork Godown Facility',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Admin user assigning is not required for jobwork godowns.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Assign Admin & Operational Staff (All Optional)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (_isLoadingAdmins)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Candidates are filtered automatically based on the chosen jurisdiction.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),

                          // 1. Godown Manager (Single)
                          DropdownButtonFormField<String?>(
                            value: _selectedManagerId,
                            decoration: const InputDecoration(
                              labelText: 'Godown Manager (Single User)',
                              hintText: 'Select Godown Manager (Optional)',
                              prefixIcon: Icon(Icons.person_pin, size: 20),
                            ),
                            items: managerItems,
                            onChanged: (val) => setState(() => _selectedManagerId = val),
                          ),
                          const SizedBox(height: 14),

                          // 2. Billing User (Single)
                          DropdownButtonFormField<String?>(
                            value: _selectedBillingUserId,
                            decoration: const InputDecoration(
                              labelText: 'Billing User (Single User)',
                              hintText: 'Select Billing User (Optional)',
                              prefixIcon: Icon(Icons.receipt_long, size: 20),
                            ),
                            items: billingItems,
                            onChanged: (val) => setState(() => _selectedBillingUserId = val),
                          ),
                          const SizedBox(height: 16),

                          // 3. Supervisors (Multi-select)
                          _buildMultiSelectSection(
                            title: 'Supervisors (SUPERVISOR [])',
                            hint: 'Select one or more supervisors for this godown',
                            color: Colors.blue,
                            available: availableSupervisors,
                            selectedIds: _selectedSupervisorIds,
                            onToggle: (id) {
                              setState(() {
                                if (_selectedSupervisorIds.contains(id)) {
                                  _selectedSupervisorIds.remove(id);
                                } else {
                                  _selectedSupervisorIds.add(id);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Assistants (Multi-select)
                          _buildMultiSelectSection(
                            title: 'Assistants (ASSISTANT [])',
                            hint: 'Select one or more assistants for this godown',
                            color: Colors.orange.shade800,
                            available: availableAssistants,
                            selectedIds: _selectedAssistantIds,
                            onToggle: (id) {
                              setState(() {
                                if (_selectedAssistantIds.contains(id)) {
                                  _selectedAssistantIds.remove(id);
                                } else {
                                  _selectedAssistantIds.add(id);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Status Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Status',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    _isActive
                                        ? 'Godown is operational and accepting inventory'
                                        : 'Godown is inactive and disabled for operations',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isActive,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _isActive = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              if (_formErrorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
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

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    onPressed: widget.controller.isActionLoading ? null : _submit,
                    child: widget.controller.isActionLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.isEditing ? 'Save Changes' : 'Create Godown'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectSection({
    required String title,
    required String hint,
    required Color color,
    required List<AssignedAdminEntity> available,
    required List<String> selectedIds,
    required ValueChanged<String> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedIds.length} Selected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(hint, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 10),

          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                'No eligible users found for this role in the selected region.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: available.map((admin) {
                final isSelected = selectedIds.contains(admin.id);
                return FilterChip(
                  label: Text('${admin.name} (${admin.employeeId})'),
                  selected: isSelected,
                  selectedColor: color.withOpacity(0.18),
                  checkmarkColor: color,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? color : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (_) => onToggle(admin.id),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
