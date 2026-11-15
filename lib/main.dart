import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/pages/main_layout_page.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
