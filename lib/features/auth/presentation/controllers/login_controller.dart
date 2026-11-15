import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginController extends ChangeNotifier {
  final LoginWithPhoneAndPasswordUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  LoginStatus _status = LoginStatus.initial;
  LoginStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserEntity? _user;
  UserEntity? get user => _user;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  bool get isLoading => _status == LoginStatus.loading;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loggedInUser = await loginUseCase.execute(
        phoneNumber: phoneNumber,
        password: password,
      );

      _user = loggedInUser;
      _status = LoginStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = LoginStatus.failure;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on NetworkException catch (e) {
      _status = LoginStatus.failure;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ServerException catch (e) {
      _status = LoginStatus.failure;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = LoginStatus.failure;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
