import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/logger/app_logger.dart';
import 'core/logger/log_viewer_dialog.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/error_boundary.dart';
import 'features/admin/presentation/pages/main_layout_page.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await AppLogger().init();
    } catch (e) {
      debugPrint('Failed to initialize AppLogger: $e');
    }

    AppLogger().i('MLF Frontend Application Starting...', tag: 'Bootstrap');

    // Framework synchronous error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger().e(
        'Flutter Framework Exception: ${details.exception}',
        tag: 'FlutterFramework',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    // Uncaught asynchronous platform error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger().e(
        'Uncaught Async Error: $error',
        tag: 'AsyncPlatform',
        error: error,
        stackTrace: stack,
      );
      return true; // Prevents process crash
    };

    // Safe error widget builder that handles bounded/unbounded boxes gracefully
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // If the parent space is very small (e.g. icon or table cell), render a compact indicator
            if (constraints.maxHeight < 80 || constraints.maxWidth < 120) {
              return const Center(
                child: Tooltip(
                  message: 'Rendering error in this component',
                  child: Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                ),
              );
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
                      const SizedBox(height: 10),
                      const Text(
                        'Unable to render component',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        details.exceptionAsString(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    };

    bool isLoggedIn = false;
    Object? startupError;

    try {
      await ServiceLocator.init();
      final token = await sl<AuthRepository>().getAuthToken();
      isLoggedIn = token != null && token.isNotEmpty;
      AppLogger().i('Auth check on boot: isLoggedIn=$isLoggedIn', tag: 'Auth');
    } catch (e, st) {
      startupError = e;
      AppLogger().e(
        'Critical initialization error on bootstrap: $e',
        tag: 'Bootstrap',
        error: e,
        stackTrace: st,
      );
    }

    runApp(MLFApp(
      initialIsLoggedIn: isLoggedIn,
      startupError: startupError,
    ));
  }, (error, stack) {
    AppLogger().e(
      'ZonedGuarded Uncaught Global Error: $error',
      tag: 'GlobalZone',
      error: error,
      stackTrace: stack,
    );
  });
}

class MLFApp extends StatelessWidget {
  final bool initialIsLoggedIn;
  final Object? startupError;

  const MLFApp({
    super.key,
    required this.initialIsLoggedIn,
    this.startupError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return AppErrorBoundary(
          sectionName: 'App Root',
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: startupError != null
          ? StartupErrorScreen(error: startupError!)
          : (initialIsLoggedIn ? const MainLayoutPage() : const LoginPage()),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  final Object error;

  const StartupErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.error,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Application Startup Issue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The application encountered a problem during initialization. You can retry launching or view debug logs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.toString(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => LogViewerDialog.show(context),
                      icon: const Icon(Icons.terminal, size: 18),
                      label: const Text('View Logs'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        main();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry Launch'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
