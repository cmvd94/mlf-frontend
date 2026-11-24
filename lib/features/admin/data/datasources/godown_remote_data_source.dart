import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/godown_model.dart';

abstract class GodownRemoteDataSource {
  Future<GodownListModel> getGodowns({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    bool? isActive,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
    String? token,
  });

  Future<GodownModel> getGodownById(String id, {String? token});

  Future<String> createGodown(Map<String, dynamic> body, {String? token});

  Future<void> updateGodown(
    String id,
    Map<String, dynamic> body, {
    String? token,
  });

  Future<void> updateGodownIsActive({
    required List<String> godownIds,
    required bool isActive,
    String? token,
  });

  Future<void> deleteGodown(String id, {String? token});

  Future<List<AssignedAdminModel>> getEligibleAdmins({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? token,
  });
}

class GodownRemoteDataSourceImpl implements GodownRemoteDataSource {
  final ApiClient apiClient;

  GodownRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<GodownListModel> getGodowns({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    bool? isActive,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? pincode,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null && type.isNotEmpty) 'type': type,
      if (isActive != null) 'isActive': isActive.toString(),
      if (country != null && country.isNotEmpty) 'country': country,
      if (zone != null && zone.isNotEmpty) 'zone': zone,
      if (state != null && state.isNotEmpty) 'state': state,
      if (district != null && district.isNotEmpty) 'district': district,
      if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
    };

    final response = await apiClient.get(
      ApiEndpoints.getGodownList,
      queryParams: queryParams,
      token: token,
    );

    final data = response is Map<String, dynamic> ? response['data'] ?? response : response;
    return GodownListModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<GodownModel> getGodownById(String id, {String? token}) async {
    final response = await apiClient.get(
      ApiEndpoints.getGodownById(id),
      token: token,
    );

    final data = response is Map<String, dynamic> ? response['data'] ?? response : response;
    return GodownModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<String> createGodown(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(
      ApiEndpoints.createGodown,
      body: body,
      token: token,
    );

    final data = response is Map<String, dynamic> ? response['data'] ?? response : response;
    return data?.toString() ?? '';
  }

  @override
  Future<void> updateGodown(
    String id,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    await apiClient.patch(
      ApiEndpoints.updateGodown(id),
      body: body,
      token: token,
    );
  }

  @override
  Future<void> updateGodownIsActive({
    required List<String> godownIds,
    required bool isActive,
    String? token,
  }) async {
    await apiClient.patch(
      ApiEndpoints.updateIsActiveGodown,
      body: {
        'godownIds': godownIds,
        'isActive': isActive,
      },
      token: token,
    );
  }

  @override
  Future<void> deleteGodown(String id, {String? token}) async {
    await apiClient.delete(
      ApiEndpoints.deleteGodown(id),
      token: token,
    );
  }

  @override
  Future<List<AssignedAdminModel>> getEligibleAdmins({
    String? search,
    String? role,
    String? country,
    String? zone,
    String? state,
    String? district,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty) 'role': role,
      if (country != null && country.isNotEmpty) 'country': country,
      if (zone != null && zone.isNotEmpty) 'zone': zone,
      if (state != null && state.isNotEmpty) 'state': state,
      if (district != null && district.isNotEmpty) 'district': district,
    };

    final response = await apiClient.get(
      ApiEndpoints.eligibleGodownAdmins,
      queryParams: queryParams,
      token: token,
    );

    final data = response is Map<String, dynamic> ? response['data'] ?? response : response;
    final adminsList = (data is Map<String, dynamic> ? data['admins'] : null) as List? ?? [];

    return adminsList
        .whereType<Map>()
        .map((item) => AssignedAdminModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
