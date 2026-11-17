import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';
import 'package:mlf_frontend/core/logger/app_logger.dart';

class LogViewerDialog extends StatefulWidget {
  const LogViewerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const LogViewerDialog(),
    );
  }

  @override
  State<LogViewerDialog> createState() => _LogViewerDialogState();
}

class _LogViewerDialogState extends State<LogViewerDialog> {
  final TextEditingController _searchController = TextEditingController();
  LogLevel? _filterLevel;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return AppColors.error;
      case LogLevel.warn:
        return Colors.orange.shade800;
      case LogLevel.info:
        return AppColors.primary;
      case LogLevel.debug:
        return Colors.grey.shade700;
    }
  }

  IconData _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return Icons.error_outline;
      case LogLevel.warn:
        return Icons.warning_amber_outlined;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.debug:
        return Icons.bug_report_outlined;
    }
  }

  void _copyAllLogs(BuildContext context) {
    final text = AppLogger().exportLogsText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All logs copied to clipboard! You can now paste it into chat.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logger = AppLogger();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.terminal, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Debug & Error Logs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Real-time logs captured from the frontend runtime',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Toolbar
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Filter Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('All', null),
                      _buildFilterChip('Errors', LogLevel.error),
                      _buildFilterChip('Warnings', LogLevel.warn),
                      _buildFilterChip('Info', LogLevel.info),
                    ],
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy All Logs'),
                        onPressed: () => _copyAllLogs(context),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Clear logs',
                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
                        onPressed: () async {
                          await logger.clearLogs();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Box
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search logs...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
              const SizedBox(height: 12),

              // Logs List
              Expanded(
                child: AnimatedBuilder(
                  animation: logger,
                  builder: (context, _) {
                    final filtered = logger.logs.where((entry) {
                      if (_filterLevel != null && entry.level != _filterLevel) {
                        return false;
                      }
                      if (_searchQuery.isNotEmpty) {
                        final text = '${entry.message} ${entry.tag} ${entry.error ?? ""} ${entry.stackTrace ?? ""}'.toLowerCase();
                        if (!text.contains(_searchQuery)) {
                          return false;
                        }
                      }
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No logs recorded matching filter',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A), // Dark terminal background
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E293B), height: 1),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final color = _getLevelColor(item.level);

                          return Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              leading: Icon(_getLevelIcon(item.level), color: color, size: 18),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.level.name.toUpperCase(),
                                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '[${item.tag}]',
                                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.message,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                item.formattedTime,
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        'Message: ${item.message}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                                      ),
                                      if (item.error != null) ...[
                                        const SizedBox(height: 8),
                                        SelectableText(
                                          'Error: ${item.error}',
                                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                      if (item.stackTrace != null && item.stackTrace!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'StackTrace:',
                                          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          item.stackTrace!,
                                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, LogLevel? level) {
    final isSelected = _filterLevel == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterLevel = level),
    );
  }
}
