import 'package:flutter_test/flutter_test.dart';
import 'package:mlf_frontend/core/utils/validators.dart';
import 'package:mlf_frontend/features/auth/data/models/user_model.dart';
import 'package:mlf_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:mlf_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:mlf_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:mlf_frontend/features/auth/presentation/controllers/login_controller.dart';

// Mock AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  String? failureMessage;

  @override
  Future<UserEntity> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    if (shouldFail) {
      throw Exception(failureMessage ?? 'Invalid credentials');
    }
    return UserEntity(
      id: 'usr_123',
      phoneNumber: phoneNumber,
      name: 'Test User',
      token: 'jwt_mock_token_12345',
    );
  }

  @override
  Future<String?> getAuthToken() async => 'jwt_mock_token_12345';

  @override
  Future<void> saveAuthToken(String token) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  group('Validators Test', () {
    test('Validates phone numbers accurately', () {
      expect(Validators.validatePhoneNumber(''), isNotNull);
      expect(Validators.validatePhoneNumber('12345'), isNotNull);
      expect(Validators.validatePhoneNumber('9876543210'), isNull);
    });

    test('Validates passwords accurately', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
    });
  });

  group('UserModel Serialization', () {
    test('UserModel fromJson deserialization', () {
      final json = {
        'id': 'u100',
        'phoneNumber': '9876543210',
        'name': 'John Doe',
        'token': 'jwt_abc',
      };
      final user = UserModel.fromJson(json);

      expect(user.id, 'u100');
      expect(user.phoneNumber, '9876543210');
      expect(user.name, 'John Doe');
      expect(user.token, 'jwt_abc');
    });

    test('UserModel toJson serialization', () {
      const user = UserModel(
        id: 'u100',
        phoneNumber: '9876543210',
        name: 'John Doe',
        token: 'jwt_abc',
      );
      final json = user.toJson();

      expect(json['id'], 'u100');
      expect(json['phoneNumber'], '9876543210');
      expect(json['token'], 'jwt_abc');
    });
  });

  group('LoginWithPhoneAndPasswordUseCase', () {
    late MockAuthRepository mockRepository;
    late LoginWithPhoneAndPasswordUseCase useCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginWithPhoneAndPasswordUseCase(mockRepository);
    });

    test('successful execution returns UserEntity', () async {
      final user = await useCase.execute(
        phoneNumber: '9876543210',
        password: 'password123',
      );

      expect(user.phoneNumber, '9876543210');
      expect(user.token, 'jwt_mock_token_12345');
    });

    test('empty phone number throws ArgumentError', () async {
      expect(
        () => useCase.execute(phoneNumber: '', password: 'password123'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('empty password throws ArgumentError', () async {
      expect(
        () => useCase.execute(phoneNumber: '9876543210', password: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('LoginController State Flow', () {
    late MockAuthRepository mockRepository;
    late LoginWithPhoneAndPasswordUseCase useCase;
    late LoginController controller;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginWithPhoneAndPasswordUseCase(mockRepository);
      controller = LoginController(loginUseCase: useCase);
    });

    test('Initial state is initial and not loading', () {
      expect(controller.status, LoginStatus.initial);
      expect(controller.isLoading, false);
      expect(controller.obscurePassword, true);
      expect(controller.rememberMe, false);
    });

    test('Toggling password visibility works', () {
      controller.togglePasswordVisibility();
      expect(controller.obscurePassword, false);
      controller.togglePasswordVisibility();
      expect(controller.obscurePassword, true);
    });

    test('Successful login sets status to success and populates user', () async {
      final success = await controller.login(
        phoneNumber: '9876543210',
        password: 'password123',
      );

      expect(success, true);
      expect(controller.status, LoginStatus.success);
      expect(controller.user?.phoneNumber, '9876543210');
      expect(controller.errorMessage, isNull);
    });

    test('Failed login sets status to failure and sets errorMessage', () async {
      mockRepository.shouldFail = true;
      mockRepository.failureMessage = 'Bad credentials';

      final success = await controller.login(
        phoneNumber: '9876543210',
        password: 'wrong_password',
      );

      expect(success, false);
      expect(controller.status, LoginStatus.failure);
      expect(controller.errorMessage, contains('Bad credentials'));
    });
  });
}
