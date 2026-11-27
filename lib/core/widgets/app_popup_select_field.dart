import 'package:flutter/material.dart';
import 'package:mlf_frontend/core/constants/app_colors.dart';

/// Represents an item in the popup selection list.
class AppPopupOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final List<String>? tags;
  final IconData? icon;

  const AppPopupOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.tags,
    this.icon,
  });
}

/// A modern, fully-visible popup selection dialog with search and clean badges.
class AppPopupSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<AppPopupOption<T>> items;
  final T? selectedValue;
  final String? searchHint;
  final IconData? headerIcon;

  const AppPopupSelectDialog({
    super.key,
    required this.title,
    required this.items,
    this.selectedValue,
    this.searchHint,
    this.headerIcon,
  });

  @override
  State<AppPopupSelectDialog<T>> createState() => _AppPopupSelectDialogState<T>();
}

class _AppPopupSelectDialogState<T> extends State<AppPopupSelectDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppPopupOption<T>> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items.where((it) {
      final labelMatches = it.label.toLowerCase().contains(_searchQuery);
      final subtitleMatches = it.subtitle?.toLowerCase().contains(_searchQuery) ?? false;
      final tagsMatches = it.tags?.any((tag) => tag.toLowerCase().contains(_searchQuery)) ?? false;
      return labelMatches || subtitleMatches || tagsMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 768;
    final filtered = _filteredItems;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: screenSize.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.headerIcon ?? Icons.format_list_bulleted_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.items.length} ${widget.items.length == 1 ? "option" : "options"} available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    tooltip: 'Close',
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar (Always available in all cases)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: isDesktop,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText: widget.searchHint ?? 'Search...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // List of Options
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            widget.items.isEmpty
                                ? 'No options available'
                                : 'No matching results found for "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 6),
                      itemBuilder: (ctx, idx) {
                        final item = filtered[idx];
                        final isSelected = item.value == widget.selectedValue;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.of(context).pop(item.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.5)
                                      : Colors.grey.shade200,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (item.icon != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withOpacity(0.12)
                                            : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: 18,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                        if (item.tags != null && item.tags!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: item.tags!.map((tag) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary.withOpacity(0.12)
                                                      : const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.primary.withOpacity(0.3)
                                                        : const Color(0xFFCBD5E1),
                                                  ),
                                                ),
                                                child: Text(
                                                  tag,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? AppColors.primaryDark
                                                        : const Color(0xFF334155),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                      size: 20,
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade400,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer note if needed
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Click any option to select',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A form field drop-in replacement for DropdownButtonFormField that opens
/// an expansive, easy-to-read Pop UI dialog so options can be viewed fully.
class AppPopupSelectField<T> extends FormField<T> {
  final List<AppPopupOption<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? title;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final IconData? headerIcon;

  AppPopupSelectField({
    super.key,
    T? initialValue,
    T? value,
    required this.items,
    this.onChanged,
    super.validator,
    this.title,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.isDense = false,
    this.contentPadding,
    super.enabled = true,
    this.headerIcon,
  }) : super(
          initialValue: value ?? initialValue,
          builder: (FormFieldState<T> field) {
            final state = field as _AppPopupSelectFieldState<T>;
            return state.buildWidget();
          },
        );

  @override
  FormFieldState<T> createState() => _AppPopupSelectFieldState<T>();
}

class _AppPopupSelectFieldState<T> extends FormFieldState<T> {
  @override
  AppPopupSelectField<T> get widget => super.widget as AppPopupSelectField<T>;

  @override
  void didUpdateWidget(AppPopupSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  AppPopupOption<T>? get _selectedOption {
    try {
      return widget.items.firstWhere((it) => it.value == value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openSelectDialog() async {
    if (!widget.enabled) return;

    final selected = await showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppPopupSelectDialog<T>(
        title: widget.title ?? widget.labelText ?? widget.hintText ?? 'Select Option',
        items: widget.items,
        selectedValue: value,
        searchHint: 'Search ${widget.labelText ?? widget.hintText ?? "options"}...',
        headerIcon: widget.headerIcon,
      ),
    );

    if (selected != null) {
      didChange(selected);
      widget.onChanged?.call(selected);
    }
  }

  Widget buildWidget() {
    final selected = _selectedOption;
    final isSelected = selected != null;

    final defaultPadding = widget.isDense
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 14);

    return InkWell(
      onTap: widget.enabled ? _openSelectDialog : null,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: widget.isDense,
          contentPadding: widget.contentPadding ?? defaultPadding,
          labelText: widget.labelText,
          floatingLabelBehavior: widget.labelText != null
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.auto,
          prefixIcon: widget.prefixIcon,
          errorText: errorText,
          enabled: widget.enabled,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: widget.enabled ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
        isEmpty: false,
        child: Text(
          isSelected ? selected.label : (widget.hintText ?? 'Select'),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: widget.isDense ? 13 : 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: widget.enabled
                ? (isSelected ? AppColors.textPrimary : Colors.grey.shade500)
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
