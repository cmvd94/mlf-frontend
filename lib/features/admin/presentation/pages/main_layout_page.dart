import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/config/env_config.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/core/utils/app_notification.dart';
import 'package:mlf_frontend/core/utils/error_boundary.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';
import 'package:mlf_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:mlf_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:mlf_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/admin_controller.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/environment_badge.dart';
import 'package:mlf_frontend/features/admin/presentation/widgets/change_password_dialog.dart';
import 'package:mlf_frontend/features/admin/presentation/pages/admin_management_page.dart';
import 'package:mlf_frontend/features/admin/presentation/pages/godown_management_page.dart';
import 'package:mlf_frontend/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:mlf_frontend/features/inventory/presentation/pages/account_inventory_page.dart';
import 'package:mlf_frontend/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:mlf_frontend/features/purchase/presentation/pages/purchase_management_page.dart';
import 'package:mlf_frontend/features/stock_summary/presentation/controllers/stock_summary_controller.dart';
import 'package:mlf_frontend/features/stock_summary/presentation/pages/stock_summary_page.dart';
import 'package:mlf_frontend/features/stock_transfer/presentation/pages/stock_transfer_page.dart';
import 'package:mlf_frontend/features/sales/presentation/pages/sales_page.dart';
import 'package:mlf_frontend/features/debit_note/presentation/pages/debit_note_page.dart';
import 'package:mlf_frontend/features/credit_note/presentation/pages/credit_note_page.dart';

class MainLayoutPage extends StatefulWidget {
  final UserEntity? currentUser;

  const MainLayoutPage({super.key, this.currentUser});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 1; // Default to Admin Management tab as requested
  late final AdminController _adminController;
  late final GodownController _godownController;
  late final InventoryController _inventoryController;
  late final PurchaseController _purchaseController;
  late final StockSummaryController _stockSummaryController;

  @override
  void initState() {
    super.initState();
    _adminController = sl<AdminController>();
    _godownController = sl<GodownController>();
    _inventoryController = sl<InventoryController>();
    _purchaseController = sl<PurchaseController>();
    _stockSummaryController = sl<StockSummaryController>();
    AppLogger().i(
      'MainLayoutPage mounted successfully for user: ${widget.currentUser?.name ?? "Admin"} (phone: ${widget.currentUser?.phoneNumber ?? "N/A"})',
      tag: 'PortalUI',
    );
  }

  Future<void> _logout() async {
    AppLogger().i('User opened logout confirmation dialog', tag: 'PortalUI');
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Do you want to log out from this device or all active sessions across all devices?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            onPressed: () => Navigator.pop(ctx, 'all'),
            child: const Text('Logout All Devices'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, 'current'),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (action != null) {
      try {
        if (action == 'all') {
          await sl<AuthRepository>().logoutAll();
        } else {
          await sl<AuthRepository>().logout();
        }
      } catch (e, st) {
        AppLogger().e('Error logging out from server: $e', tag: 'PortalUI', error: e, stackTrace: st);
      } finally {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      }
    }
  }

  void _openChangePasswordDialog() async {
    try {
      final changed = await showDialog<bool>(
        context: context,
        builder: (_) => const ChangePasswordDialog(),
      );

      if (changed == true && mounted) {
        AppNotification.showSuccess(context, 'Password changed successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(context, 'Failed to open change password dialog: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: true,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MLF',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(width: 8),
                  EnvironmentBadge(),
                ],
              ),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 1,
            ),
      drawer: _buildSidebar(isDrawer: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) _buildTopBar(),
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final userName = widget.currentUser?.name ?? 'Admin User';
    final userPhone = widget.currentUser?.phoneNumber ?? '';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu, color: AppColors.primaryDark),
                  onPressed: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.pop(context);
                    } else {
                      _scaffoldKey.currentState?.openDrawer();
                    }
                  },
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _getTabTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const EnvironmentBadge(),

              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.yellow,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userPhone.isNotEmpty)
                      Text(
                        userPhone,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Change Password',
                icon: const Icon(Icons.lock_reset, size: 20, color: AppColors.primary),
                onPressed: _openChangePasswordDialog,
              ),
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout, size: 20, color: Colors.grey),
                onPressed: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool isDrawer}) {
    return Material(
      color: AppColors.primaryDark,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.primary.withOpacity(0.3))),
        ),
        child: Column(
          children: [
            // Branding Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.apartment,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MLF Internal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Management Portal',
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isDrawer)
                    IconButton(
                      tooltip: 'Hide Menu',
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),
            Divider(color: AppColors.primary.withOpacity(0.3), height: 1),
            const SizedBox(height: 12),

            // Scrollable Nav Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Dashboard',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.admin_panel_settings_outlined,
                      activeIcon: Icons.admin_panel_settings,
                      label: 'Admin Users',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.warehouse_outlined,
                      activeIcon: Icons.warehouse,
                      label: 'Godowns',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet,
                      label: 'Account & Inventory Info',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.shopping_cart_outlined,
                      activeIcon: Icons.shopping_cart,
                      label: 'Purchase',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 5,
                      icon: Icons.assessment_outlined,
                      activeIcon: Icons.assessment,
                      label: 'Stock Summary',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 6,
                      icon: Icons.sync_alt_outlined,
                      activeIcon: Icons.sync_alt,
                      label: 'Stock Transfer',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 7,
                      icon: Icons.point_of_sale_outlined,
                      activeIcon: Icons.point_of_sale,
                      label: 'Sales',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 8,
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      label: 'Debit Note',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 9,
                      icon: Icons.note_alt_outlined,
                      activeIcon: Icons.note_alt,
                      label: 'Credit Note',
                      isDrawer: isDrawer,
                    ),
                    _buildNavItem(
                      index: 10,
                      icon: Icons.tune_outlined,
                      activeIcon: Icons.tune,
                      label: 'Environment & Config',
                      isDrawer: isDrawer,
                    ),
                  ],
                ),
              ),
            ),

          // Change Password
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.grey),
            title: const Text(
              'Change Password',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              _openChangePasswordDialog();
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              _logout();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    String? badge,
    required bool isDrawer,
  }) {
    final isSelected = _selectedTabIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppColors.primary,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.yellow : Colors.grey.shade400,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellow : AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryDark : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          setState(() => _selectedTabIndex = index);
          if (isDrawer) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  String _getTabTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Overview Dashboard';
      case 1:
        return 'Admin Users Management';
      case 2:
        return 'Godown Management';
      case 3:
        return 'Account & Inventory Info';
      case 4:
        return 'Purchase Entries & Stock Management';
      case 5:
        return 'Stock Summary';
      case 6:
        return 'Stock Transfer / Inventory Transfer';
      case 7:
        return 'Sales Management';
      case 8:
        return 'Debit Note Management';
      case 9:
        return 'Credit Note Management';
      case 10:
        return 'Environment & Configuration';
      default:
        return 'Portal';
    }
  }

  Widget _buildTabContent() {
    Widget content;
    String sectionName;

    switch (_selectedTabIndex) {
      case 0:
        sectionName = 'Dashboard';
        content = _buildDashboardTab();
        break;
      case 1:
        sectionName = 'Admin Management';
        content = AdminManagementPage(controller: _adminController);
        break;
      case 2:
        sectionName = 'Godown Management';
        content = GodownManagementPage(controller: _godownController);
        break;
      case 3:
        sectionName = 'Account & Inventory';
        content = AccountInventoryPage(controller: _inventoryController);
        break;
      case 4:
        sectionName = 'Purchase Management';
        content = PurchaseManagementPage(
          purchaseController: _purchaseController,
          inventoryController: _inventoryController,
        );
        break;
      case 5:
        sectionName = 'Stock Summary';
        content = StockSummaryPage(controller: _stockSummaryController);
        break;
      case 6:
        sectionName = 'Stock Transfer';
        content = const StockTransferPage();
        break;
      case 7:
        sectionName = 'Sales Management';
        content = const SalesPage();
        break;
      case 8:
        sectionName = 'Debit Note';
        content = const DebitNotePage();
        break;
      case 9:
        sectionName = 'Credit Note';
        content = const CreditNotePage();
        break;
      case 10:
        sectionName = 'Environment Settings';
        content = _buildEnvironmentTab();
        break;
      default:
        sectionName = 'Admin Management';
        content = AdminManagementPage(controller: _adminController);
        break;
    }

    return AppErrorBoundary(
      key: ValueKey('tab_boundary_$_selectedTabIndex'),
      sectionName: sectionName,
      child: content,
    );
  }

  Widget _buildDashboardTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final int crossAxisCount = constraints.maxWidth < 650
            ? 1
            : (constraints.maxWidth < 1100 ? 2 : 3);
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

        final cards = [
          _buildStatCard(
            title: 'Admin Users',
            subtitle: 'Manage roles & permissions',
            icon: Icons.admin_panel_settings,
            color: AppColors.primary,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
          _buildStatCard(
            title: 'Godowns',
            subtitle: 'Manage branches & jobworks',
            icon: Icons.warehouse,
            color: Colors.indigo,
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
          _buildStatCard(
            title: 'Inventory & Masters',
            subtitle: 'Parties, Items, UOMs, Per',
            icon: Icons.account_balance_wallet,
            color: Colors.teal,
            onTap: () => setState(() => _selectedTabIndex = 3),
          ),
          _buildStatCard(
            title: 'Purchase Entries',
            subtitle: 'New purchase & stock updates',
            icon: Icons.shopping_cart,
            color: Colors.deepOrange,
            onTap: () => setState(() => _selectedTabIndex = 4),
          ),
          _buildStatCard(
            title: 'Stock Summary',
            subtitle: 'Tally group & stock summary',
            icon: Icons.assessment,
            color: Colors.green.shade700,
            onTap: () => setState(() => _selectedTabIndex = 5),
          ),
          _buildStatCard(
            title: 'Stock Transfer',
            subtitle: 'Material transfer & stock journal',
            icon: Icons.sync_alt,
            color: Colors.orange.shade800,
            onTap: () => setState(() => _selectedTabIndex = 6),
          ),
          _buildStatCard(
            title: 'Sales Management',
            subtitle: 'Outward sales & stock deduction',
            icon: Icons.point_of_sale,
            color: Colors.purple,
            onTap: () => setState(() => _selectedTabIndex = 7),
          ),
          _buildStatCard(
            title: 'Debit Note',
            subtitle: 'Outward debit voucher management',
            icon: Icons.receipt_long,
            color: Colors.blueGrey,
            onTap: () => setState(() => _selectedTabIndex = 8),
          ),
          _buildStatCard(
            title: 'Credit Note',
            subtitle: 'Inward credit voucher & returns',
            icon: Icons.note_alt,
            color: Colors.cyan.shade700,
            onTap: () => setState(() => _selectedTabIndex = 9),
          ),
          _buildStatCard(
            title: 'Environment',
            subtitle: EnvConfig().environment.displayName,
            icon: Icons.tune,
            color: AppColors.yellowDark,
            onTap: () => setState(() => _selectedTabIndex = 10),
          ),
        ];

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.currentUser?.name ?? "Administrator"}!',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Internal company portal for user management and operations.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards
                    .map((card) => SizedBox(width: itemWidth, child: card))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentTab() {
    final envConfig = EnvConfig();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'API Environment Configuration',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Switch between Local testing, Development, and Production API endpoints on demand.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: envConfig,
            builder: (context, _) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preset Environments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...AppEnvironment.values.map((env) {
                        final isSelected = envConfig.environment == env &&
                            envConfig.customBaseUrl == null;
                        return RadioListTile<AppEnvironment>(
                          value: env,
                          groupValue: envConfig.customBaseUrl != null
                              ? null
                              : envConfig.environment,
                          title: Text(
                            env.displayName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            env.defaultBaseUrl,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              envConfig.setEnvironment(val);
                            }
                          },
                        );
                      }),
                      const Divider(height: 32),
                      const Text(
                        'Active Base URL in use for all network requests:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                envConfig.baseUrl,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
