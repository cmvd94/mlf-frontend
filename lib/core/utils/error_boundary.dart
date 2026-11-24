import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../logger/app_logger.dart';

class AppErrorBoundary extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context)? builder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)? errorBuilder;
  final String? sectionName;

  const AppErrorBoundary({
    super.key,
    this.child,
    this.builder,
    this.errorBuilder,
    this.sectionName,
  }) : assert(child != null || builder != null, 'Either child or builder must be provided');

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  void _reportError(Object error, StackTrace stackTrace) {
    AppLogger().e(
      'AppErrorBoundary caught error in [${widget.sectionName ?? "UnknownSection"}]: $error',
      tag: 'ErrorBoundary',
      error: error,
      stackTrace: stackTrace,
    );
    _error = error;
    _stackTrace = stackTrace;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _resetError);
      }
      return _buildDefaultErrorUI(context);
    }

    if (widget.builder != null) {
      try {
        return widget.builder!(context);
      } catch (e, st) {
        _reportError(e, st);
        if (widget.errorBuilder != null) {
          return widget.errorBuilder!(context, e, _resetError);
        }
        return _buildDefaultErrorUI(context);
      }
    }

    return widget.child!;
  }

  Widget _buildDefaultErrorUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.sectionName != null
                    ? 'Something went wrong in ${widget.sectionName}'
                    : 'Something went wrong',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'An unexpected error occurred while rendering this view. The application is running safely.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _resetError,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
