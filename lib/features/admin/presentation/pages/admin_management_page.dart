import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/admin_role.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_detail_dialog.dart';
import '../widgets/admin_form_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/environment_badge.dart';

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

        // Display snackbar on message
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Padding(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // User Table / Cards
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
      },
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontSize: 24,
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
                'Manage administrator accounts, roles, access permissions and credentials',
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Box
          SizedBox(
            width: isDesktop ? 300 : double.infinity,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, email...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ctrl.setSearch('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: (val) => ctrl.setSearch(val),
            ),
          ),

          // Role Filter
          DropdownButton<String?>(
            value: ctrl.roleFilter,
            hint: const Text('All Roles', style: TextStyle(fontSize: 13)),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Roles', style: TextStyle(fontSize: 13)),
              ),
              ...AdminRole.values.map((role) {
                return DropdownMenuItem<String?>(
                  value: role.value,
                  child: Text(role.label, style: const TextStyle(fontSize: 13)),
                );
              }),
            ],
            onChanged: (val) => ctrl.setRoleFilter(val),
          ),

          // Status Filter
          DropdownButton<bool?>(
            value: ctrl.isActiveFilter,
            hint: const Text('All Status', style: TextStyle(fontSize: 13)),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem<bool?>(
                value: null,
                child: Text('All Status', style: TextStyle(fontSize: 13)),
              ),
              DropdownMenuItem<bool?>(
                value: true,
                child: Text('Active Only', style: TextStyle(fontSize: 13)),
              ),
              DropdownMenuItem<bool?>(
                value: false,
                child: Text('Inactive Only', style: TextStyle(fontSize: 13)),
              ),
            ],
            onChanged: (val) => ctrl.setIsActiveFilter(val),
          ),

          // Refresh Button
          IconButton(
            tooltip: 'Refresh',
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
            'Try adjusting search or role filters, or create a new admin.',
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
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            columns: const [
              DataColumn(label: Text('Name & Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: users.map((user) {
              final roleColor = _getRoleColor(user.role);

              return DataRow(
                cells: [
                  // Name & Employee ID
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          user.employeeId,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Phone Number
                  DataCell(Text(user.phoneNumber)),

                  // Email
                  DataCell(Text(user.email)),

                  // Role Badge
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

                  // Status Switch
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
                            color: user.isActive ? AppColors.success : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'View Details',
                          icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.blueGrey),
                          onPressed: () => _openDetailDialog(user),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                          onPressed: () => _openEditDialog(user),
                        ),
                        if (user.role != AdminRole.superAdmin)
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                Text('ID: ${user.employeeId}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Phone: ${user.phoneNumber}', style: const TextStyle(fontSize: 13)),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 13)),
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
                            color: user.isActive ? AppColors.success : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          onPressed: () => _openDetailDialog(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                          onPressed: () => _openEditDialog(user),
                        ),
                        if (user.role != AdminRole.superAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
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
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
