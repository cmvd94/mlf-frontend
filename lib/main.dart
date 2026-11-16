import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/logger/app_logger.dart';
import 'core/logger/log_viewer_dialog.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/pages/main_layout_page.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().init();

  AppLogger().i('MLF Frontend Application Starting...', tag: 'Bootstrap');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger().e(
      'Flutter Framework Exception: ${details.exception}',
      tag: 'FlutterFramework',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger().e(
      'Uncaught Async Error: $error',
      tag: 'AsyncPlatform',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                'Application Error: ${details.exceptionAsString()}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  await ServiceLocator.init();

  final token = await sl<AuthRepository>().getAuthToken();
  final isLoggedIn = token != null && token.isNotEmpty;
  AppLogger().i('Auth check on boot: isLoggedIn=$isLoggedIn', tag: 'Auth');

  runApp(MLFApp(initialIsLoggedIn: isLoggedIn));
}

class MLFApp extends StatelessWidget {
  final bool initialIsLoggedIn;

  const MLFApp({super.key, required this.initialIsLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialIsLoggedIn ? const MainLayoutPage() : const LoginPage(),
    );
  }
}
