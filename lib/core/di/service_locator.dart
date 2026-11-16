import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';
import '../network/api_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';

// Admin
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/create_admin_user_usecase.dart';
import '../../features/admin/domain/usecases/delete_admin_user_usecase.dart';
import '../../features/admin/domain/usecases/get_admin_user_details_usecase.dart';
import '../../features/admin/domain/usecases/get_admin_users_usecase.dart';
import '../../features/admin/domain/usecases/update_admin_is_active_usecase.dart';
import '../../features/admin/domain/usecases/update_admin_user_usecase.dart';
import '../../features/admin/presentation/controllers/admin_controller.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  factory ServiceLocator() => instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  void _register<T>(T service) {
    _services[T] = service;
  }

  void register<T>(T service) {
    _services[T] = service;
  }

  void reset() {
    _services.clear();
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T is not registered in ServiceLocator');
    }
    return service as T;
  }

  static Future<void> init() async {
    final sl = ServiceLocator.instance;

    // 1. Config & External
    final envConfig = EnvConfig();
    await envConfig.init();
    sl._register<EnvConfig>(envConfig);

    final prefs = await SharedPreferences.getInstance();
    sl._register<SharedPreferences>(prefs);

    final apiClient = ApiClient(envConfig: envConfig);
    sl._register<ApiClient>(apiClient);

    // 2. Auth Data Sources & Repositories
    final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences: prefs);
    sl._register<AuthLocalDataSource>(authLocalDataSource);

    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
    sl._register<AuthRemoteDataSource>(authRemoteDataSource);

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    sl._register<AuthRepository>(authRepository);

    // 3. Auth Use Cases & Controller
    final loginUseCase = LoginWithPhoneAndPasswordUseCase(authRepository);
    sl._register<LoginWithPhoneAndPasswordUseCase>(loginUseCase);

    final changePasswordUseCase = ChangePasswordUseCase(authRepository);
    sl._register<ChangePasswordUseCase>(changePasswordUseCase);

    final loginController = LoginController(loginUseCase: loginUseCase);
    sl._register<LoginController>(loginController);

    // 4. Admin Data Sources & Repositories
    final adminRemoteDataSource = AdminRemoteDataSourceImpl(apiClient: apiClient);
    sl._register<AdminRemoteDataSource>(adminRemoteDataSource);

    final adminRepository = AdminRepositoryImpl(
      remoteDataSource: adminRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    sl._register<AdminRepository>(adminRepository);

    // 5. Admin Use Cases
    final getAdminUsersUseCase = GetAdminUsersUseCase(adminRepository);
    sl._register<GetAdminUsersUseCase>(getAdminUsersUseCase);

    final getAdminUserDetailsUseCase = GetAdminUserDetailsUseCase(adminRepository);
    sl._register<GetAdminUserDetailsUseCase>(getAdminUserDetailsUseCase);

    final createAdminUserUseCase = CreateAdminUserUseCase(adminRepository);
    sl._register<CreateAdminUserUseCase>(createAdminUserUseCase);

    final updateAdminUserUseCase = UpdateAdminUserUseCase(adminRepository);
    sl._register<UpdateAdminUserUseCase>(updateAdminUserUseCase);

    final updateAdminIsActiveUseCase = UpdateAdminIsActiveUseCase(adminRepository);
    sl._register<UpdateAdminIsActiveUseCase>(updateAdminIsActiveUseCase);

    final deleteAdminUserUseCase = DeleteAdminUserUseCase(adminRepository);
    sl._register<DeleteAdminUserUseCase>(deleteAdminUserUseCase);

    // 6. Admin Controller
    final adminController = AdminController(
      getAdminUsersUseCase: getAdminUsersUseCase,
      getAdminUserDetailsUseCase: getAdminUserDetailsUseCase,
      createAdminUserUseCase: createAdminUserUseCase,
      updateAdminUserUseCase: updateAdminUserUseCase,
      updateAdminIsActiveUseCase: updateAdminIsActiveUseCase,
      deleteAdminUserUseCase: deleteAdminUserUseCase,
    );
    sl._register<AdminController>(adminController);
  }
}

/// Global convenience accessor for dependencies
T sl<T>() => ServiceLocator.instance.get<T>();
