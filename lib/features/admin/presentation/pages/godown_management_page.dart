import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/environment_badge.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchGodowns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => GodownFormDialog(controller: widget.controller),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Godown created successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Godown updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    if (confirmed == true) {
      final success = await widget.controller.deleteGodown(godown.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Godown deleted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ctrl.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
              const SizedBox(height: 20),

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
                  Text(
                    'Godown Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  EnvironmentBadge(),
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
            isDesktop ? 'Create Godown' : 'Add',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: _openCreateDialog,
        ),
      ],
    );
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
                hintText: 'Search by name or ID...',
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

          // Type Filter Dropdown
          SizedBox(
            width: isDesktop ? 190 : 160,
            height: 40,
            child: DropdownButtonFormField<GodownType?>(
              value: widget.controller.typeFilter,
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
              hint: const Text('All Godown Types', style: TextStyle(fontSize: 12)),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Godown Types', style: TextStyle(fontSize: 12)),
                ),
                ...GodownType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.label, style: const TextStyle(fontSize: 12)),
                  );
                }),
              ],
              onChanged: (val) => widget.controller.setTypeFilter(val),
            ),
          ),

          // Status Filter Dropdown
          SizedBox(
            width: isDesktop ? 150 : 130,
            height: 40,
            child: DropdownButtonFormField<bool?>(
              value: widget.controller.isActiveFilter,
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
          const Text(
            'No Godowns Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            widget.controller.searchQuery != null ||
                    widget.controller.typeFilter != null ||
                    widget.controller.isActiveFilter != null
                ? 'Try adjusting your filters or search keywords.'
                : 'Get started by creating your first godown.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Godown'),
            onPressed: _openCreateDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<GodownEntity> godowns) {
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
                columns: const [
                  DataColumn(label: Text('GODOWN NAME & ID')),
                  DataColumn(label: Text('TYPE')),
                  DataColumn(label: Text('REGIONAL JURISDICTION')),
                  DataColumn(label: Text('MANAGER')),
                  DataColumn(label: Text('STAFF SUMMARY')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTIONS')),
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

                      // Type Badge
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: g.typeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: g.typeColor.withOpacity(0.25)),
                          ),
                          child: Text(
                            g.type.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: g.typeColor,
                            ),
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
