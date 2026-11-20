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
import '../../features/admin/domain/usecases/get_admin_static_data_usecase.dart';
import '../../features/admin/domain/usecases/get_admin_user_details_usecase.dart';
import '../../features/admin/domain/usecases/get_admin_users_usecase.dart';
import '../../features/admin/domain/usecases/update_admin_is_active_usecase.dart';
import '../../features/admin/domain/usecases/update_admin_user_usecase.dart';
import '../../features/admin/presentation/controllers/admin_controller.dart';

// Godown
import '../../features/admin/data/datasources/godown_remote_data_source.dart';
import '../../features/admin/data/repositories/godown_repository_impl.dart';
import '../../features/admin/domain/repositories/godown_repository.dart';
import '../../features/admin/domain/usecases/create_godown_usecase.dart';
import '../../features/admin/domain/usecases/delete_godown_usecase.dart';
import '../../features/admin/domain/usecases/get_eligible_godown_admins_usecase.dart';
import '../../features/admin/domain/usecases/get_godown_by_id_usecase.dart';
import '../../features/admin/domain/usecases/get_godowns_usecase.dart';
import '../../features/admin/domain/usecases/update_godown_is_active_usecase.dart';
import '../../features/admin/domain/usecases/update_godown_usecase.dart';
import '../../features/admin/presentation/controllers/godown_controller.dart';

// Inventory & Masters
import '../../features/inventory/data/datasources/inventory_remote_data_source.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/presentation/controllers/inventory_controller.dart';

// Purchase
import '../../features/purchase/data/datasources/purchase_remote_data_source.dart';
import '../../features/purchase/data/repositories/purchase_repository_impl.dart';
import '../../features/purchase/domain/repositories/purchase_repository.dart';
import '../../features/purchase/presentation/controllers/purchase_controller.dart';

// Stock Summary (Tally Stock View)
import '../../features/stock_summary/data/datasources/stock_summary_remote_data_source.dart';
import '../../features/stock_summary/data/repositories/stock_summary_repository_impl.dart';
import '../../features/stock_summary/domain/repositories/stock_summary_repository.dart';
import '../../features/stock_summary/domain/usecases/get_stock_summary_usecase.dart';
import '../../features/stock_summary/presentation/controllers/stock_summary_controller.dart';

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

    final getAdminStaticDataUseCase = GetAdminStaticDataUseCase(adminRepository);
    sl._register<GetAdminStaticDataUseCase>(getAdminStaticDataUseCase);

    // 6. Admin Controller
    final adminController = AdminController(
      getAdminUsersUseCase: getAdminUsersUseCase,
      getAdminUserDetailsUseCase: getAdminUserDetailsUseCase,
      createAdminUserUseCase: createAdminUserUseCase,
      updateAdminUserUseCase: updateAdminUserUseCase,
      updateAdminIsActiveUseCase: updateAdminIsActiveUseCase,
      deleteAdminUserUseCase: deleteAdminUserUseCase,
      getAdminStaticDataUseCase: getAdminStaticDataUseCase,
    );
    sl._register<AdminController>(adminController);

    // 7. Godown Data Source & Repository
    final godownRemoteDataSource = GodownRemoteDataSourceImpl(apiClient: apiClient);
    sl._register<GodownRemoteDataSource>(godownRemoteDataSource);

    final godownRepository = GodownRepositoryImpl(
      remoteDataSource: godownRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    sl._register<GodownRepository>(godownRepository);

    // 8. Godown Use Cases
    final getGodownsUseCase = GetGodownsUseCase(godownRepository);
    sl._register<GetGodownsUseCase>(getGodownsUseCase);

    final getGodownByIdUseCase = GetGodownByIdUseCase(godownRepository);
    sl._register<GetGodownByIdUseCase>(getGodownByIdUseCase);

    final createGodownUseCase = CreateGodownUseCase(godownRepository);
    sl._register<CreateGodownUseCase>(createGodownUseCase);

    final updateGodownUseCase = UpdateGodownUseCase(godownRepository);
    sl._register<UpdateGodownUseCase>(updateGodownUseCase);

    final updateGodownIsActiveUseCase = UpdateGodownIsActiveUseCase(godownRepository);
    sl._register<UpdateGodownIsActiveUseCase>(updateGodownIsActiveUseCase);

    final deleteGodownUseCase = DeleteGodownUseCase(godownRepository);
    sl._register<DeleteGodownUseCase>(deleteGodownUseCase);

    final getEligibleGodownAdminsUseCase = GetEligibleGodownAdminsUseCase(godownRepository);
    sl._register<GetEligibleGodownAdminsUseCase>(getEligibleGodownAdminsUseCase);

    // 9. Godown Controller
    final godownController = GodownController(
      getGodownsUseCase: getGodownsUseCase,
      getGodownByIdUseCase: getGodownByIdUseCase,
      createGodownUseCase: createGodownUseCase,
      updateGodownUseCase: updateGodownUseCase,
      updateGodownIsActiveUseCase: updateGodownIsActiveUseCase,
      deleteGodownUseCase: deleteGodownUseCase,
      getEligibleGodownAdminsUseCase: getEligibleGodownAdminsUseCase,
    );
    sl._register<GodownController>(godownController);

    // 10. Inventory Data Sources, Repositories & Controller
    final inventoryRemoteDataSource = InventoryRemoteDataSourceImpl(apiClient: apiClient);
    sl._register<InventoryRemoteDataSource>(inventoryRemoteDataSource);

    final inventoryRepository = InventoryRepositoryImpl(
      remoteDataSource: inventoryRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    sl._register<InventoryRepository>(inventoryRepository);

    final inventoryController = InventoryController(repository: inventoryRepository);
    sl._register<InventoryController>(inventoryController);

    // 11. Purchase Data Sources, Repositories & Controller
    final purchaseRemoteDataSource = PurchaseRemoteDataSourceImpl(apiClient: apiClient);
    sl._register<PurchaseRemoteDataSource>(purchaseRemoteDataSource);

    final purchaseRepository = PurchaseRepositoryImpl(
      remoteDataSource: purchaseRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    sl._register<PurchaseRepository>(purchaseRepository);

    final purchaseController = PurchaseController(repository: purchaseRepository);
    sl._register<PurchaseController>(purchaseController);

    // 12. Stock Summary Data Sources, Repositories, Use Cases & Controller
    final stockSummaryRemoteDataSource = StockSummaryRemoteDataSourceImpl(apiClient: apiClient);
    sl._register<StockSummaryRemoteDataSource>(stockSummaryRemoteDataSource);

    final stockSummaryRepository = StockSummaryRepositoryImpl(
      remoteDataSource: stockSummaryRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    sl._register<StockSummaryRepository>(stockSummaryRepository);

    final getStockSummaryUseCase = GetStockSummaryUseCase(stockSummaryRepository);
    sl._register<GetStockSummaryUseCase>(getStockSummaryUseCase);

    final stockSummaryController = StockSummaryController(getStockSummaryUseCase: getStockSummaryUseCase);
    sl._register<StockSummaryController>(stockSummaryController);
  }
}

/// Global convenience accessor for dependencies
T sl<T>() => ServiceLocator.instance.get<T>();
