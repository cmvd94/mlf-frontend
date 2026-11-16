import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/pages/main_layout_page.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER RUNTIME ERROR: ${details.exception}');
    debugPrint('${details.stack}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Application Error: ${details.exception}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  details.stack.toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  await ServiceLocator.init();

  final token = await sl<AuthRepository>().getAuthToken();
  final isLoggedIn = token != null && token.isNotEmpty;

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
