import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/validators.dart';
import '../../../admin/presentation/pages/main_layout_page.dart';
import '../../../admin/presentation/widgets/environment_badge.dart';
import '../controllers/login_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  final LoginController? controller;

  const LoginPage({super.key, this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? sl<LoginController>();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    if (_controller.status == LoginStatus.failure &&
        _controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (_controller.status == LoginStatus.success &&
        _controller.user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainLayoutPage(currentUser: _controller.user),
        ),
      );
    }
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.login(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Environment switcher in top-right
            const Positioned(
              top: 16,
              right: 16,
              child: EnvironmentBadge(),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ResponsiveLayout(
                  mobile: _buildForm(context, isWeb: false),
                  web: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      color: AppColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: _buildForm(context, isWeb: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isWeb}) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isLoading = _controller.isLoading;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Brand Icon
              Center(
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and Subtitle
              const Text(
                AppStrings.loginTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.loginSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Input
              CustomTextField(
                controller: _phoneController,
                label: AppStrings.phoneNumberLabel,
                hint: AppStrings.phoneNumberHint,
                keyboardType: TextInputType.phone,
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 20,
                        child: VerticalDivider(color: AppColors.border, width: 1),
                      ),
                    ],
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: Validators.validatePhoneNumber,
                onChanged: (_) => _controller.clearError(),
              ),
              const SizedBox(height: 20),

              // Password Input
              CustomTextField(
                controller: _passwordController,
                label: AppStrings.passwordLabel,
                hint: AppStrings.passwordHint,
                obscureText: _controller.obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _controller.obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: _controller.togglePasswordVisibility,
                ),
                validator: Validators.validatePassword,
                onChanged: (_) => _controller.clearError(),
              ),
              const SizedBox(height: 12),

              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _controller.rememberMe,
                          onChanged: _controller.toggleRememberMe,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        AppStrings.rememberMe,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Submit Button
              PrimaryButton(
                text: isLoading ? AppStrings.loggingIn : AppStrings.loginButton,
                isLoading: isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              // Sign Up Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.noAccount,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      AppStrings.signUp,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
