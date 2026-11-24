import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import '../../domain/entities/godown_entity.dart';
import '../controllers/godown_controller.dart';
import '../widgets/godown_detail_dialog.dart';
import '../widgets/godown_form_dialog.dart';

class GodownManagementPage extends StatefulWidget {
  final GodownController controller;

  const GodownManagementPage({super.key, required this.controller});

  @override
  State<GodownManagementPage> createState() => _GodownManagementPageState();
}

class _GodownManagementPageState extends State<GodownManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSubTab = 0; // 0 = Company Godowns, 1 = Jobwork Godowns

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.setTypeFilter(GodownType.companyGodown);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _switchSubTab(int index) {
    if (_selectedSubTab == index) return;
    setState(() {
      _selectedSubTab = index;
    });
    final selectedType =
        index == 0 ? GodownType.companyGodown : GodownType.jobworkGodown;
    widget.controller.setTypeFilter(selectedType);
  }

  void _openCreateDialog([GodownType? defaultType]) async {
    final typeToCreate = defaultType ??
        (_selectedSubTab == 0
            ? GodownType.companyGodown
            : GodownType.jobworkGodown);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => GodownFormDialog(
        controller: widget.controller,
        defaultType: typeToCreate,
      ),
    );

    if (result == true && mounted) {
      AppNotification.showSuccess(context, 'Godown created successfully!');
    }
  }

  void _openEditDialog(GodownEntity godown) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => GodownFormDialog(
        controller: widget.controller,
        godownToEdit: godown,
      ),
    );

    if (result == true && mounted) {
      AppNotification.showSuccess(context, 'Godown updated successfully!');
    }
  }

  void _openDetailDialog(GodownEntity godown) {
    showDialog(
      context: context,
      builder: (ctx) => GodownDetailDialog(godown: godown),
    );
  }

  void _confirmDelete(GodownEntity godown) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Godown'),
        content: Text(
          'Are you sure you want to delete "${godown.name}" (${godown.godownId})?\n\nThis will remove access for all assigned staff and archive the godown.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await widget.controller.deleteGodown(godown.id);
        if (mounted) {
          if (success) {
            AppNotification.showSuccess(context, 'Godown deleted successfully!');
          } else if (widget.controller.errorMessage != null) {
            AppNotification.showError(context, widget.controller.errorMessage!);
          }
        }
      } catch (e) {
        if (mounted) {
          AppNotification.showError(context, 'Failed to delete godown: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;

        if (ctrl.successMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppNotification.showSuccess(context, ctrl.successMessage!);
            ctrl.clearMessages();
          });
        }

        final isDesktop = MediaQuery.of(context).size.width >= 900;

        return Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(isDesktop),
              const SizedBox(height: 16),

              // Sub-Tabs Bar: Company | Jobwork
              _buildSubTabBar(isDesktop),
              const SizedBox(height: 16),

              // Filter & Search Bar
              _buildFilterBar(isDesktop),
              const SizedBox(height: 16),

              // Error Banner
              if (ctrl.errorMessage != null) ...[
                _buildErrorBanner(ctrl.errorMessage!),
                const SizedBox(height: 16),
              ],

              // Table / Cards View
              Expanded(
                child: ctrl.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.godowns.isEmpty
                        ? _buildEmptyState()
                        : isDesktop
                            ? _buildDesktopTable(ctrl.godowns)
                            : _buildMobileList(ctrl.godowns),
              ),

              // Pagination Footer
              if (ctrl.godowns.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPaginationFooter(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  const Text(
                    'Godown Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Create and manage company and jobwork godowns with regional jurisdiction.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 14,
              vertical: isDesktop ? 14 : 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            isDesktop
                ? (_selectedSubTab == 0
                    ? 'Create Company Godown'
                    : 'Create Jobwork Godown')
                : 'Add',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => _openCreateDialog(
            _selectedSubTab == 0
                ? GodownType.companyGodown
                : GodownType.jobworkGodown,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabBar(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
        children: [
          _buildSubTabItem(
            index: 0,
            title: 'Company Godowns',
            icon: Icons.warehouse,
            isSelected: _selectedSubTab == 0,
            isDesktop: isDesktop,
          ),
          const SizedBox(width: 8),
          _buildSubTabItem(
            index: 1,
            title: 'Jobwork Godowns',
            icon: Icons.precision_manufacturing_outlined,
            isSelected: _selectedSubTab == 1,
            isDesktop: isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required int index,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDesktop,
  }) {
    final item = InkWell(
      onTap: () => _switchSubTab(index),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    return isDesktop ? item : Expanded(child: item);
  }

  Widget _buildFilterBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Input
          SizedBox(
            width: isDesktop ? 280 : double.infinity,
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _selectedSubTab == 0
                    ? 'Search company godowns by name or ID...'
                    : 'Search jobwork godowns by name or ID...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          widget.controller.setSearch(null);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: (val) => widget.controller.setSearch(val),
            ),
          ),

          // Status Filter Dropdown
          SizedBox(
            width: isDesktop ? 160 : 140,
            height: 40,
            child: DropdownButtonFormField<bool?>(
              value: widget.controller.isActiveFilter,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              hint: const Text('All Status', style: TextStyle(fontSize: 12)),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('All Status', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Active Only', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Inactive Only', style: TextStyle(fontSize: 12)),
                ),
              ],
              onChanged: (val) => widget.controller.setIsActiveFilter(val),
            ),
          ),

          // Refresh Button
          IconButton(
            tooltip: 'Refresh Godown List',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => widget.controller.fetchGodowns(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.error),
            onPressed: () => widget.controller.clearMessages(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _selectedSubTab == 0
                ? 'No Company Godowns Found'
                : 'No Jobwork Godowns Found',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            widget.controller.searchQuery != null ||
                    widget.controller.isActiveFilter != null
                ? 'Try adjusting your filters or search keywords.'
                : (_selectedSubTab == 0
                    ? 'Get started by creating your first company godown.'
                    : 'Get started by creating your first jobwork godown.'),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(_selectedSubTab == 0
                ? 'Create Company Godown'
                : 'Create Jobwork Godown'),
            onPressed: () => _openCreateDialog(
              _selectedSubTab == 0
                  ? GodownType.companyGodown
                  : GodownType.jobworkGodown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<GodownEntity> godowns) {
    final bool isCompanyTab = _selectedSubTab == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1000),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 74,
                columns: [
                  const DataColumn(label: Text('GODOWN NAME & ID')),
                  const DataColumn(label: Text('REGIONAL JURISDICTION')),
                  if (isCompanyTab) ...[
                    const DataColumn(label: Text('GODOWN MANAGER')),
                    const DataColumn(label: Text('STAFF SUMMARY')),
                  ] else ...[
                    const DataColumn(label: Text('DESCRIPTION / NOTES')),
                  ],
                  const DataColumn(label: Text('STATUS')),
                  const DataColumn(label: Text('ACTIONS')),
                ],
                rows: godowns.map((g) {
                  return DataRow(
                    cells: [
                      // Name & ID
                      DataCell(
                        InkWell(
                          onTap: () => _openDetailDialog(g),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  g.godownId,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Region
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${g.district}, ${g.state}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Text(
                              '${g.country} > ${g.zone} (PIN: ${g.pincode})',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),

                      // Staff or Description depending on tab
                      if (isCompanyTab) ...[
                        // Manager
                        DataCell(
                          g.godownManager != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.indigo.shade100,
                                      child: Text(
                                        g.godownManager!.name.isNotEmpty
                                            ? g.godownManager!.name[0].toUpperCase()
                                            : 'M',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      g.godownManager!.name,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Unassigned',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                                ),
                        ),

                        // Staff Summary
                        DataCell(
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (g.supervisors.isNotEmpty)
                                _buildCountPill(
                                  '${g.supervisors.length} Sup',
                                  Colors.blue,
                                ),
                              if (g.assistants.isNotEmpty)
                                _buildCountPill(
                                  '${g.assistants.length} Asst',
                                  Colors.amber.shade900,
                                ),
                              if (g.billingUser != null)
                                _buildCountPill(
                                  '1 Billing',
                                  Colors.teal,
                                ),
                              if (g.supervisors.isEmpty &&
                                  g.assistants.isEmpty &&
                                  g.billingUser == null)
                                Text(
                                  'No Staff',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Description / Notes
                        DataCell(
                          SizedBox(
                            width: 250,
                            child: Text(
                              (g.description != null && g.description!.isNotEmpty)
                                  ? g.description!
                                  : 'No description provided',
                              style: TextStyle(
                                fontSize: 12,
                                color: (g.description != null && g.description!.isNotEmpty)
                                    ? AppColors.textPrimary
                                    : Colors.grey.shade400,
                                fontStyle: (g.description != null && g.description!.isNotEmpty)
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],

                      // Status Switch
                      DataCell(
                        Switch(
                          value: g.isActive,
                          activeColor: AppColors.primary,
                          onChanged: (newVal) =>
                              widget.controller.toggleGodownStatus(g.id, newVal),
                        ),
                      ),

                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'View Details',
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                              color: AppColors.primary,
                              onPressed: () => _openDetailDialog(g),
                            ),
                            IconButton(
                              tooltip: 'Edit Godown',
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: Colors.grey.shade700,
                              onPressed: () => _openEditDialog(g),
                            ),
                            IconButton(
                              tooltip: 'Delete Godown',
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: AppColors.error,
                              onPressed: () => _confirmDelete(g),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMobileList(List<GodownEntity> godowns) {
    return ListView.builder(
      itemCount: godowns.length,
      itemBuilder: (ctx, idx) {
        final g = godowns[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            g.godownId,
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: g.typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        g.type.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: g.typeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${g.district}, ${g.state} (PIN: ${g.pincode})',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (g.type == GodownType.companyGodown) ...[
                  if (g.godownManager != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_pin, size: 14, color: Colors.indigo),
                        const SizedBox(width: 4),
                        Text(
                          'Manager: ${g.godownManager!.name}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (g.supervisors.isNotEmpty || g.assistants.isNotEmpty || g.billingUser != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (g.supervisors.isNotEmpty)
                          _buildCountPill('${g.supervisors.length} Sup', Colors.blue),
                        if (g.assistants.isNotEmpty)
                          _buildCountPill('${g.assistants.length} Asst', Colors.amber.shade900),
                        if (g.billingUser != null)
                          _buildCountPill('1 Billing', Colors.teal),
                      ],
                    ),
                  ],
                ] else ...[
                  if (g.description != null && g.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      g.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Active: ', style: TextStyle(fontSize: 12)),
                        Switch(
                          value: g.isActive,
                          activeColor: AppColors.primary,
                          onChanged: (newVal) =>
                              widget.controller.toggleGodownStatus(g.id, newVal),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          onPressed: () => _openDetailDialog(g),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _openEditDialog(g),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(g),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationFooter() {
    final pag = widget.controller.pagination;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing page ${pag.currentPage} of ${pag.totalPages} (${pag.totalCount} total)',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.chevron_left, size: 16),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: pag.hasPreviousPage
                    ? () => widget.controller.setPage(pag.currentPage - 1)
                    : null,
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                label: const Text('Next'),
                icon: const Icon(Icons.chevron_right, size: 16),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: pag.hasNextPage
                    ? () => widget.controller.setPage(pag.currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
