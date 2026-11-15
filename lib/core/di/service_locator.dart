import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final SharedPreferences sharedPreferences;
  late final ApiClient apiClient;
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthLocalDataSource authLocalDataSource;
  late final AuthRepository authRepository;
  late final LoginWithPhoneAndPasswordUseCase loginUseCase;
  late final LoginController loginController;

  static Future<void> init() async {
    final sl = ServiceLocator._instance;

    // External
    sl.sharedPreferences = await SharedPreferences.getInstance();
    sl.apiClient = ApiClient();

    // Data Sources
    sl.authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: sl.apiClient);
    sl.authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences: sl.sharedPreferences);

    // Repository
    sl.authRepository = AuthRepositoryImpl(
      remoteDataSource: sl.authRemoteDataSource,
      localDataSource: sl.authLocalDataSource,
    );

    // Use Cases
    sl.loginUseCase = LoginWithPhoneAndPasswordUseCase(sl.authRepository);

    // Presentation Controllers
    sl.loginController = LoginController(loginUseCase: sl.loginUseCase);
  }
}
