import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_role.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_user_entity.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/admin_detail_dialog.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/admin_form_dialog.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/delete_confirm_dialog.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/environment_badge.dart';

class AdminManagementPage extends StatefulWidget {
  final AdminController controller;

  const AdminManagementPage({super.key, required this.controller});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleColor(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return Colors.purple;
      case AdminRole.generalManager:
        return Colors.indigo;
      case AdminRole.zoneHead:
        return Colors.blue;
      case AdminRole.regionalManager:
        return Colors.teal;
      case AdminRole.districtManager:
        return Colors.green;
      case AdminRole.godownManager:
        return Colors.deepOrange;
      case AdminRole.supervisor:
        return Colors.amber.shade800;
      case AdminRole.assistant:
        return Colors.cyan;
      case AdminRole.billingUser:
        return Colors.blueGrey;
    }
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AdminFormDialog(controller: widget.controller),
    );
  }

  void _openEditDialog(AdminUserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AdminFormDialog(
        controller: widget.controller,
        userToEdit: user,
      ),
    );
  }

  void _openDetailDialog(AdminUserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AdminDetailDialog(user: user),
    );
  }

  void _openDeleteDialog(AdminUserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteConfirmDialog(
        user: user,
        controller: widget.controller,
      ),
    );
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
              // Page Header
              _buildHeader(isDesktop),
              const SizedBox(height: 20),

              // Filters & Search Bar
              _buildFilterBar(isDesktop),
              const SizedBox(height: 16),

              // Error Banner
              if (ctrl.errorMessage != null) ...[
                _buildErrorBanner(ctrl.errorMessage!),
                const SizedBox(height: 16),
              ],

              // User Table / Cards Area
              Expanded(
                child: ctrl.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.adminList.users.isEmpty
                        ? _buildEmptyState()
                        : isDesktop
                            ? _buildDesktopTable(ctrl.adminList.users)
                            : _buildMobileList(ctrl.adminList.users),
              ),

              // Pagination Footer
              if (ctrl.adminList.users.isNotEmpty) ...[
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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Admin Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const EnvironmentBadge(),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage company admin accounts, credentials, and roles',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 14,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _openCreateDialog,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Admin'),
        ),
      ],
    );
  }

  Widget _buildFilterBar(bool isDesktop) {
    final ctrl = widget.controller;
    final selectedRoleValue = ctrl.roleFilter ?? 'ALL';
    final selectedStatusValue = ctrl.isActiveFilter == null
        ? 'ALL'
        : (ctrl.isActiveFilter! ? 'ACTIVE' : 'INACTIVE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Box
          SizedBox(
            width: isDesktop ? 260 : 200,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search user...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          ctrl.setSearch('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: (val) => ctrl.setSearch(val),
            ),
          ),

          // Role Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRoleValue,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('All Roles'),
                  ),
                  ...AdminRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role.value,
                      child: Text(role.label),
                    );
                  }),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ctrl.setRoleFilter(val == 'ALL' ? null : val);
                  }
                },
              ),
            ),
          ),

          // Status Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatusValue,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active Only')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive Only')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    if (val == 'ALL') {
                      ctrl.setIsActiveFilter(null);
                    } else if (val == 'ACTIVE') {
                      ctrl.setIsActiveFilter(true);
                    } else {
                      ctrl.setIsActiveFilter(false);
                    }
                  }
                },
              ),
            ),
          ),

          // Refresh Button
          IconButton(
            tooltip: 'Refresh list',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => ctrl.fetchUsers(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => widget.controller.fetchUsers(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Admin Users Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a new administrator or adjust filter parameters.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _openCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Admin User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(List<AdminUserEntity> users) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(
                    label: Text('Name & ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Phone Number',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Email',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Role',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Status',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Actions',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: users.map((user) {
                final roleColor = _getRoleColor(user.role);

                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            user.employeeId,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(user.phoneNumber)),
                    DataCell(Text(user.email)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: roleColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          user.role.label,
                          style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: user.isActive,
                            activeColor: AppColors.success,
                            onChanged: (val) {
                              widget.controller.toggleUserStatus(user.id, val);
                            },
                          ),
                          Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: user.isActive
                                  ? AppColors.success
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'View Details',
                            icon: const Icon(Icons.visibility_outlined,
                                size: 20, color: Colors.blueGrey),
                            onPressed: () => _openDetailDialog(user),
                          ),
                          IconButton(
                            tooltip: 'Edit User',
                            icon: const Icon(Icons.edit_outlined,
                                size: 20, color: AppColors.primary),
                            onPressed: () => _openEditDialog(user),
                          ),
                          if (user.role != AdminRole.superAdmin)
                            IconButton(
                              tooltip: 'Delete User',
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: AppColors.error),
                              onPressed: () => _openDeleteDialog(user),
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
    );
  }

  Widget _buildMobileList(List<AdminUserEntity> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final roleColor = _getRoleColor(user.role);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        user.role.label,
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('ID: ${user.employeeId}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text('Phone: ${user.phoneNumber}',
                    style: const TextStyle(fontSize: 13)),
                Text('Email: ${user.email}',
                    style: const TextStyle(fontSize: 13)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: user.isActive,
                          activeColor: AppColors.success,
                          onChanged: (val) {
                            widget.controller.toggleUserStatus(user.id, val);
                          },
                        ),
                        Text(
                          user.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                user.isActive ? AppColors.success : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.visibility_outlined, size: 20),
                          onPressed: () => _openDetailDialog(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 20, color: AppColors.primary),
                          onPressed: () => _openEditDialog(user),
                        ),
                        if (user.role != AdminRole.superAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.error),
                            onPressed: () => _openDeleteDialog(user),
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
    final list = widget.controller.adminList;
    final ctrl = widget.controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total: ${list.totalItems} user(s) | Page ${list.currentPage} of ${list.totalPages}',
          style:
              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: list.hasPrevPage
                  ? () => ctrl.fetchUsers(page: list.currentPage - 1)
                  : null,
            ),
            Text(
              '${list.currentPage}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: list.hasNextPage
                  ? () => ctrl.fetchUsers(page: list.currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
