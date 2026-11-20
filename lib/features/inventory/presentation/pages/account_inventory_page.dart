import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/utils/confirm_delete_dialog.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/party_form_dialog.dart';
import '../widgets/purchase_type_form_dialog.dart';
import '../widgets/item_group_form_dialog.dart';
import '../widgets/uom_form_dialog.dart';
import '../widgets/per_unit_form_dialog.dart';
import '../widgets/item_form_dialog.dart';

class AccountInventoryPage extends StatefulWidget {
  final InventoryController controller;

  const AccountInventoryPage({super.key, required this.controller});

  @override
  State<AccountInventoryPage> createState() => _AccountInventoryPageState();
}

class _AccountInventoryPageState extends State<AccountInventoryPage> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Parties', 'icon': Icons.business},
    {'title': 'Purchase Types', 'icon': Icons.category},
    {'title': 'Item Groups', 'icon': Icons.folder},
    {'title': 'Items', 'icon': Icons.inventory_2},
    {'title': 'Units (UOM)', 'icon': Icons.straighten},
    {'title': 'Per Units', 'icon': Icons.calculate},
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.fetchMasters();
    widget.controller.fetchCurrentTabData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateDialog() {
    final subTab = widget.controller.selectedSubTab;
    switch (subTab) {
      case 0:
        showDialog(
          context: context,
          builder: (_) => PartyFormDialog(controller: widget.controller),
        );
        break;
      case 1:
        showDialog(
          context: context,
          builder: (_) => PurchaseTypeFormDialog(controller: widget.controller),
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (_) => ItemGroupFormDialog(controller: widget.controller),
        );
        break;
      case 3:
        showDialog(
          context: context,
          builder: (_) => ItemFormDialog(controller: widget.controller),
        );
        break;
      case 4:
        showDialog(
          context: context,
          builder: (_) => UomFormDialog(controller: widget.controller),
        );
        break;
      case 5:
        showDialog(
          context: context,
          builder: (_) => PerUnitFormDialog(controller: widget.controller),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account & Inventory Info',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage dynamic masters: Parties, Purchase Types, Items, Units & Per unit conventions',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add ${_tabs[ctrl.selectedSubTab]['title']}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _openCreateDialog,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sub-Tabs navigation pills
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isSelected = ctrl.selectedSubTab == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            avatar: Icon(
                              tab['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            label: Text(tab['title'] as String),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              _searchController.clear();
                              ctrl.setSubTab(index);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search ${_tabs[ctrl.selectedSubTab]['title']}...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ctrl.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) => ctrl.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ctrl.fetchMasters();
                      ctrl.fetchCurrentTabData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tab Content Body
              if (ctrl.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (ctrl.errorMessage != null)
                Card(
                  color: AppColors.error.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ctrl.errorMessage!, style: const TextStyle(color: AppColors.error))),
                        TextButton(
                          onPressed: () => ctrl.fetchCurrentTabData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildTabContent(ctrl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(InventoryController ctrl) {
    switch (ctrl.selectedSubTab) {
      case 0:
        return _buildPartyTable(ctrl);
      case 1:
        return _buildPurchaseTypeTable(ctrl);
      case 2:
        return _buildItemGroupTable(ctrl);
      case 3:
        return _buildItemTable(ctrl);
      case 4:
        return _buildUomTable(ctrl);
      case 5:
        return _buildPerUnitTable(ctrl);
      default:
        return const SizedBox.shrink();
    }
  }

  // Parties Table
  Widget _buildPartyTable(InventoryController ctrl) {
    if (ctrl.parties.isEmpty) {
      return _buildEmptyState('No parties found. Click "+ Add Parties" to create one.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Party Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Contact Person', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('GSTIN', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.parties.map((p) {
            return DataRow(
              cells: [
                DataCell(Text(p.partyCode, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600))),
                DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(p.contactPerson.isEmpty ? '-' : p.contactPerson)),
                DataCell(Text(p.phoneNumber.isEmpty ? '-' : p.phoneNumber)),
                DataCell(Text(p.gstin.isEmpty ? '-' : p.gstin)),
                DataCell(_buildStatusChip(p.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PartyFormDialog(controller: ctrl, party: p),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete Party',
                              content: 'Are you sure you want to delete "${p.name}"?',
                            ),
                          );
                          if (confirm == true) {
                            await ctrl.deleteParty(p.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Purchase Types Table
  Widget _buildPurchaseTypeTable(InventoryController ctrl) {
    if (ctrl.purchaseTypes.isEmpty) {
      return _buildEmptyState('No purchase types found. Click "+ Add Purchase Types" to create one.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Type Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.purchaseTypes.map((t) {
            return DataRow(
              cells: [
                DataCell(Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(t.code, style: const TextStyle(fontFamily: 'monospace'))),
                DataCell(Text(t.description.isEmpty ? '-' : t.description)),
                DataCell(_buildStatusChip(t.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PurchaseTypeFormDialog(controller: ctrl, purchaseType: t),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete Purchase Type',
                              content: 'Are you sure you want to delete "${t.name}"?',
                            ),
                          );
                          if (confirm == true) {
                            await ctrl.deletePurchaseType(t.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Item Groups Table
  Widget _buildItemGroupTable(InventoryController ctrl) {
    if (ctrl.itemGroups.isEmpty) {
      return _buildEmptyState('No item groups found. Click "+ Add Item Groups" to create one.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Group Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.itemGroups.map((g) {
            return DataRow(
              cells: [
                DataCell(Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(g.code, style: const TextStyle(fontFamily: 'monospace'))),
                DataCell(Text(g.description.isEmpty ? '-' : g.description)),
                DataCell(_buildStatusChip(g.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ItemGroupFormDialog(controller: ctrl, itemGroup: g),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete Item Group',
                              content: 'Are you sure you want to delete "${g.name}"?',
                            ),
                          );
                          if (confirm == true) {
                            await ctrl.deleteItemGroup(g.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Items Table
  Widget _buildItemTable(InventoryController ctrl) {
    if (ctrl.items.isEmpty) {
      return _buildEmptyState('No items found. Click "+ Add Items" to create one.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Item Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Group', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Default UOM', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Default Per', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Current Stock', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Std. Rate (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.itemCode, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600))),
                DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(item.itemGroup?.name ?? '-')),
                DataCell(Text(item.defaultUom?.symbol ?? item.defaultUom?.name ?? '-')),
                DataCell(Text(item.defaultPer?.name ?? item.defaultPer?.symbol ?? '-')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.currentStock > 0
                          ? AppColors.success.withValues(alpha: 0.12)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.currentStock.toStringAsFixed(2)} ${item.defaultUom?.symbol ?? ""}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.currentStock > 0 ? AppColors.success : Colors.black87,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('₹${item.standardRate.toStringAsFixed(2)}')),
                DataCell(_buildStatusChip(item.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ItemFormDialog(controller: ctrl, item: item),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete Item',
                              content: 'Are you sure you want to delete "${item.name}"?',
                            ),
                          );
                          if (confirm == true) {
                            await ctrl.deleteItem(item.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // UOM Table
  Widget _buildUomTable(InventoryController ctrl) {
    if (ctrl.uoms.isEmpty) {
      return _buildEmptyState('No units of measurement found. Click "+ Add Units (UOM)" to create one.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Symbol', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.uoms.map((u) {
            return DataRow(
              cells: [
                DataCell(Text(u.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                DataCell(Text(u.name)),
                DataCell(Text(u.description.isEmpty ? '-' : u.description)),
                DataCell(_buildStatusChip(u.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => UomFormDialog(controller: ctrl, uom: u),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete UOM',
                              content: 'Are you sure you want to delete "${u.symbol}"?',
                            ),
                          );
                          if (confirm == true) {
                            await ctrl.deleteUom(u.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Per Units Table
  Widget _buildPerUnitTable(InventoryController ctrl) {
    if (ctrl.perUnits.isEmpty) {
      return _buildEmptyState('No per units found. Click "+ Add Per Units" to create one.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Per Unit Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Symbol', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Multiplier', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: ctrl.perUnits.map((p) {
            return DataRow(
              cells: [
                DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(p.symbol)),
                DataCell(Text(p.multiplier.toString())),
                DataCell(Text(p.description.isEmpty ? '-' : p.description)),
                DataCell(_buildStatusChip(p.isActive)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Edit',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PerUnitFormDialog(controller: ctrl, perUnit: p),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: 'Delete Per Unit',
                              content: 'Are you sure you want to delete "${p.name}"?',
                            ),
                          );
                          if (confirm == true) {
                            await ctrl.deletePerUnit(p.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
