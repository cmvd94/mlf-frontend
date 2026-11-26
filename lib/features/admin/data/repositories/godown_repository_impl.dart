import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/godown_entity.dart';
import '../../domain/entities/godown_list_entity.dart';
import '../../domain/repositories/godown_repository.dart';
import '../datasources/godown_remote_data_source.dart';
import '../models/godown_model.dart';

class GodownRepositoryImpl implements GodownRepository {
  final GodownRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  GodownRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<GodownListEntity> getGodowns({
    int page = 1,
    int limit = 10,
    String? search,
    GodownType? type,
    bool? isActive,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getGodowns(
      page: page,
      limit: limit,
      search: search,
      type: type?.value,
      isActive: isActive,
      country: country,
      zone: zone,
      state: state,
      district: district,
      pincode: pincode,
      token: token,
    );
  }

  @override
  Future<GodownEntity> getGodownById(String id) async {
    final token = await _getToken();
    return await remoteDataSource.getGodownById(id, token: token);
  }

  @override
  Future<String> createGodown({
    required String name,
    String? godownId,
    required GodownType type,
    String? description,
    required String country,
    required String zone,
    required String state,
    required String district,
    required String pincode,
    String? address,
    String? gstin,
    String? phoneNumber,
    String? godownManagerId,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = GodownModel.toCreatePayload(
      name: name,
      godownId: godownId,
      type: type,
      description: description,
      country: country,
      zone: zone,
      state: state,
      district: district,
      pincode: pincode,
      address: address,
      gstin: gstin,
      phoneNumber: phoneNumber,
      godownManagerId: godownManagerId,
      supervisorId: supervisorId,
      assistantId: assistantId,
      billingUserId: billingUserId,
      isActive: isActive,
    );
    return await remoteDataSource.createGodown(body, token: token);
  }

  @override
  Future<void> updateGodown({
    required String id,
    String? name,
    String? godownId,
    GodownType? type,
    String? description,
    String? address,
    String? gstin,
    String? phoneNumber,
    bool? isActive,
    String? godownManagerId,
    bool clearGodownManager = false,
    List<String>? supervisorId,
    List<String>? assistantId,
    String? billingUserId,
    bool clearBillingUser = false,
  }) async {
    final token = await _getToken();
    final body = GodownModel.toUpdatePayload(
      name: name,
      godownId: godownId,
      type: type,
      description: description,
      address: address,
      gstin: gstin,
      phoneNumber: phoneNumber,
      isActive: isActive,
      godownManagerId: godownManagerId,
      clearGodownManager: clearGodownManager,
      supervisorId: supervisorId,
      assistantId: assistantId,
      billingUserId: billingUserId,
      clearBillingUser: clearBillingUser,
    );
    await remoteDataSource.updateGodown(id, body, token: token);
  }

  @override
  Future<void> updateGodownIsActive({
    required List<String> godownIds,
    required bool isActive,
  }) async {
    final token = await _getToken();
    await remoteDataSource.updateGodownIsActive(
      godownIds: godownIds,
      isActive: isActive,
      token: token,
    );
  }

  @override
  Future<void> deleteGodown(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteGodown(id, token: token);
  }

  @override
  Future<List<AssignedAdminEntity>> getEligibleAdmins({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getEligibleAdmins(
      search: search,
      role: role,
      country: country,
      zone: zone,
      state: state,
      district: district,
      token: token,
    );
  }
}
