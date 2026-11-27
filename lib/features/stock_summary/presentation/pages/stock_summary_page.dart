import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/di/service_locator.dart';
import 'package:mlf_frontend/features/admin/presentation/controllers/godown_controller.dart';
import '../controllers/stock_summary_controller.dart';

class StockSummaryPage extends StatefulWidget {
  final StockSummaryController controller;

  const StockSummaryPage({super.key, required this.controller});

  @override
  State<StockSummaryPage> createState() => _StockSummaryPageState();
}

class _StockSummaryPageState extends State<StockSummaryPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();
  late final GodownController _godownController;

  @override
  void initState() {
    super.initState();
    _godownController = sl<GodownController>();
    widget.controller.init();
    if (_godownController.godowns.isEmpty) {
      _godownController.fetchGodowns();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        widget.controller.toggleDetailedView();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (widget.controller.isSingleGroupMode) {
          widget.controller.navigateBackToAllGroups();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.controller, _godownController]),
        builder: (context, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F6F9),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTallyHeaderBar(isMobile: isMobile),
                _buildControlFilterBar(isMobile: isMobile),
                if (isMobile)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                    child: Row(
                      children: [
                        Icon(Icons.swipe, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Swipe horizontally to view all stock columns',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: isMobile
                      ? Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1050,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: widget.controller.isLoading
                                        ? const Center(child: CircularProgressIndicator())
                                        : widget.controller.errorMessage != null
                                            ? _buildErrorView()
                                            : widget.controller.isSingleGroupMode
                                                ? _buildSingleGroupView()
                                                : _buildAllGroupsView(),
                                  ),
                                  _buildGrandTotalFooter(),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: widget.controller.isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : widget.controller.errorMessage != null
                                      ? _buildErrorView()
                                      : widget.controller.isSingleGroupMode
                                          ? _buildSingleGroupView()
                                          : _buildAllGroupsView(),
                            ),
                            _buildGrandTotalFooter(),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTallyHeaderBar({bool isMobile = false}) {
    final summary = widget.controller.stockSummary;
    final companyName = summary?.companyName ?? 'ML Fabric';
    final period = summary?.period.formattedPeriod ?? 'Current Period';
    final isSingleGroup = widget.controller.isSingleGroupMode;
    final selectedGroup = widget.controller.selectedGroup;

    if (isMobile) {
      return Container(
        color: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isSingleGroup) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    tooltip: 'Back to All Groups (Esc)',
                    onPressed: widget.controller.navigateBackToAllGroups,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSingleGroup
                            ? 'Stock Summary > ${selectedGroup?.groupName}'
                            : 'Stock Summary',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$companyName ($period)',
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh Stock',
                  icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                  onPressed: widget.controller.fetchStockSummary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.controller.isDetailedView
                    ? AppColors.yellow
                    : const Color(0xFF1E3A8A),
                foregroundColor: widget.controller.isDetailedView
                    ? AppColors.primaryDark
                    : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: widget.controller.isDetailedView
                        ? AppColors.yellowDark
                        : Colors.white30,
                  ),
                ),
              ),
              icon: Icon(
                widget.controller.isDetailedView
                    ? Icons.unfold_less
                    : Icons.unfold_more,
                size: 16,
              ),
              label: Text(
                widget.controller.isDetailedView ? 'Condensed' : 'Detailed',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: widget.controller.toggleDetailedView,
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSingleGroup) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  tooltip: 'Back to All Groups (Esc)',
                  onPressed: widget.controller.navigateBackToAllGroups,
                ),
                const SizedBox(width: 4),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSingleGroup
                        ? 'Stock Summary > ${selectedGroup?.groupName}'
                        : 'Stock Summary',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    '$companyName ($period)',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // F1: Detailed / Condensed button styled exactly as Tally action key
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.controller.isDetailedView
                      ? AppColors.yellow
                      : const Color(0xFF1E3A8A),
                  foregroundColor: widget.controller.isDetailedView
                    ? AppColors.primaryDark
                    : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: widget.controller.isDetailedView
                          ? AppColors.yellowDark
                          : Colors.white30,
                    ),
                  ),
                ),
                icon: Icon(
                  widget.controller.isDetailedView
                      ? Icons.unfold_less
                      : Icons.unfold_more,
                  size: 16,
                ),
                label: Text(
                  widget.controller.isDetailedView ? 'Condensed' : 'Detailed',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: widget.controller.toggleDetailedView,
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh Stock',
                icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                onPressed: widget.controller.fetchStockSummary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlFilterBar({bool isMobile = false}) {
    final godowns = _godownController.godowns;

    if (isMobile) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search group, item, DC, lot...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            widget.controller.setSearch('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSubmitted: widget.controller.setSearch,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: (widget.controller.selectedGodownId != null &&
                                godowns.any((g) => g.id == widget.controller.selectedGodownId))
                            ? widget.controller.selectedGodownId
                            : null,
                        isExpanded: true,
                        hint: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warehouse, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text('All Godowns', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Godowns (Accessible)', style: TextStyle(fontSize: 13)),
                          ),
                          ...godowns.map(
                            (g) => DropdownMenuItem<String?>(
                              value: g.id,
                              child: Text(g.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: widget.controller.setGodownFilter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: widget.controller.toggleZeroStock,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: widget.controller.showZeroStock,
                          onChanged: (_) => widget.controller.toggleZeroStock(),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          activeColor: AppColors.primary,
                        ),
                        const Text(
                          'Zero Bal',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search group, item, DC, lot...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.setSearch('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onSubmitted: widget.controller.setSearch,
                ),
              ),
              const SizedBox(width: 12),
              // Godown filter
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: (widget.controller.selectedGodownId != null &&
                            godowns.any((g) => g.id == widget.controller.selectedGodownId))
                        ? widget.controller.selectedGodownId
                        : null,
                    hint: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warehouse, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('All Godowns', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Godowns (Accessible)', style: TextStyle(fontSize: 13)),
                      ),
                      ...godowns.map(
                        (g) => DropdownMenuItem<String?>(
                          value: g.id,
                          child: Text(g.name, style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                    onChanged: widget.controller.setGodownFilter,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zero stock toggle
              InkWell(
                onTap: widget.controller.toggleZeroStock,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: widget.controller.showZeroStock,
                        onChanged: (_) => widget.controller.toggleZeroStock(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        'Show Zero Balance',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Error Loading Stock Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.controller.errorMessage ?? 'An error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: widget.controller.fetchStockSummary,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFE2E8F0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Particulars',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Godown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'DC No',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Lot No',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'UOM Qty',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Quantity',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rate',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 1 & 2: ALL GROUPS SUMMARY (IMAGE 1 & 2)
  // ==========================================
  Widget _buildAllGroupsView() {
    final summary = widget.controller.stockSummary;
    final groups = summary?.groups ?? [];
    final isDetailed = widget.controller.isDetailedView;

    if (groups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No Stock Records Found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.controller.selectedGodownId != null
                        ? 'This godown currently has no stock.'
                        : 'No items or purchase records exist for the selected filters.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        Expanded(
          child: ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final group = groups[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group Summary Row (Clickable to Drill Down to Image 3)
                  InkWell(
                    onTap: () => widget.controller.drillDownGroup(group),
                    hoverColor: const Color(0xFFF1F5F9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: isDetailed ? const Color(0xFFF8FAFC) : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 16,
                                  color: Colors.blueGrey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    group.groupName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '-',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '-',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '-',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '-',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              group.formattedUomQuantity.isNotEmpty ? group.formattedUomQuantity : '-',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              group.formattedQuantity,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              group.formattedRate,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // DETAILED VIEW (IMAGE 2): Expand each item indented under group
                  if (isDetailed)
                    ...group.items.map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Text(
                                  item.itemName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.blueGrey.shade800,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '-',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '-',
                                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '-',
                                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '-',
                                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.formattedUomQuantity.isNotEmpty ? item.formattedUomQuantity : '-',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.formattedQuantity,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.formattedRate,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 3: SINGLE GROUP DETAIL VIEW (IMAGE 3)
  // ==========================================
  Widget _buildSingleGroupView() {
    final group = widget.controller.selectedGroup;
    if (group == null) return _buildAllGroupsView();

    final isDetailed = widget.controller.isDetailedView;
    final items = group.items;

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No Items in ${group.groupName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.controller.selectedGodownId != null
                        ? 'This godown currently has no stock for ${group.groupName}.'
                        : 'No stock records exist for this group.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Item Total Row (Bold header for this item)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '-',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.formattedUomQuantity.isNotEmpty ? item.formattedUomQuantity : '-',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.formattedQuantity,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.formattedRate,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DETAILED VIEW (IMAGE 3): Split-up by Godown, DC Number, Lot Number with inward creation date in front
                  if (isDetailed)
                    ...item.batches.map(
                      (batch) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                batch.formattedDate,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                batch.godownName,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                batch.dcNo.isNotEmpty ? batch.dcNo : '-',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                batch.lotNo.isNotEmpty ? batch.lotNo : '-',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                batch.formattedUomQuantity.isNotEmpty ? batch.formattedUomQuantity : '-',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                batch.formattedQuantity,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                batch.formattedRate,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotalFooter() {
    final summary = widget.controller.stockSummary;
    final isSingleGroup = widget.controller.isSingleGroupMode;
    final selectedGroup = widget.controller.selectedGroup;

    // If single group mode, show that group's totals as Grand Total (as in Image 3)
    final totalQtyStr = isSingleGroup
        ? selectedGroup?.formattedQuantity ?? '0.000 kg'
        : summary?.grandTotal.formattedQuantity ?? '0.000 kg';

    final totalUomQtyStr = isSingleGroup
        ? selectedGroup?.formattedUomQuantity ?? ''
        : summary?.grandTotal.formattedUomQuantity ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: Text(
              'Grand Total',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
          const Expanded(
            flex: 3,
            child: SizedBox.shrink(),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
          Expanded(
            flex: 2,
            child: Text(
              totalUomQtyStr,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.yellow,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              totalQtyStr,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.yellow,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox.shrink(), // No rate on grand total row
          ),
        ],
      ),
    );
  }
}
