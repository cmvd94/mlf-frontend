import 'package:mlf_frontend/core/network/api_client.dart';
import 'package:mlf_frontend/core/network/api_endpoints.dart';
import '../models/party_model.dart';
import '../models/purchase_type_model.dart';
import '../models/sales_type_model.dart';
import '../models/uom_model.dart';
import '../models/per_unit_model.dart';
import '../models/item_group_model.dart';
import '../models/item_model.dart';
import '../models/masters_model.dart';

abstract class InventoryRemoteDataSource {
  Future<MastersModel> getMasters({String? token});

  // Parties
  Future<List<PartyModel>> getParties({String? search, bool? isActive, String? token});
  Future<PartyModel> createParty(Map<String, dynamic> body, {String? token});
  Future<PartyModel> updateParty(String id, Map<String, dynamic> body, {String? token});
  Future<void> deleteParty(String id, {String? token});

  // Purchase Types
  Future<List<PurchaseTypeModel>> getPurchaseTypes({String? search, bool? isActive, String? token});
  Future<PurchaseTypeModel> createPurchaseType(Map<String, dynamic> body, {String? token});
  Future<PurchaseTypeModel> updatePurchaseType(String id, Map<String, dynamic> body, {String? token});
  Future<void> deletePurchaseType(String id, {String? token});

  // Sales Types
  Future<List<SalesTypeModel>> getSalesTypes({String? search, bool? isActive, String? token});
  Future<SalesTypeModel> createSalesType(Map<String, dynamic> body, {String? token});
  Future<SalesTypeModel> updateSalesType(String id, Map<String, dynamic> body, {String? token});
  Future<void> deleteSalesType(String id, {String? token});

  // Units (UOM)
  Future<List<UomModel>> getUoms({String? search, bool? isActive, String? token});
  Future<UomModel> createUom(Map<String, dynamic> body, {String? token});
  Future<UomModel> updateUom(String id, Map<String, dynamic> body, {String? token});
  Future<void> deleteUom(String id, {String? token});

  // Per Units
  Future<List<PerUnitModel>> getPerUnits({String? search, bool? isActive, String? token});
  Future<PerUnitModel> createPerUnit(Map<String, dynamic> body, {String? token});
  Future<PerUnitModel> updatePerUnit(String id, Map<String, dynamic> body, {String? token});
  Future<void> deletePerUnit(String id, {String? token});

  // Item Groups
  Future<List<ItemGroupModel>> getItemGroups({String? search, bool? isActive, String? token});
  Future<ItemGroupModel> createItemGroup(Map<String, dynamic> body, {String? token});
  Future<ItemGroupModel> updateItemGroup(String id, Map<String, dynamic> body, {String? token});
  Future<void> deleteItemGroup(String id, {String? token});

  // Items
  Future<List<ItemModel>> getItems({String? search, bool? isActive, String? token});
  Future<ItemModel> createItem(Map<String, dynamic> body, {String? token});
  Future<ItemModel> updateItem(String id, Map<String, dynamic> body, {String? token});
  Future<void> deleteItem(String id, {String? token});
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;

  InventoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MastersModel> getMasters({String? token}) async {
    final response = await apiClient.get(ApiEndpoints.masters, token: token);
    return MastersModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // Parties
  @override
  Future<List<PartyModel>> getParties({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getPartyList, queryParams: queryParams, token: token);
    final list = response['data']?['parties'] as List? ?? [];
    return list.map((e) => PartyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PartyModel> createParty(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createParty, body: body, token: token);
    return PartyModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PartyModel> updateParty(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updateParty(id), body: body, token: token);
    return PartyModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteParty(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deleteParty(id), token: token);
  }

  // Purchase Types
  @override
  Future<List<PurchaseTypeModel>> getPurchaseTypes({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getPurchaseTypeList, queryParams: queryParams, token: token);
    final list = response['data']?['purchaseTypes'] as List? ?? [];
    return list.map((e) => PurchaseTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PurchaseTypeModel> createPurchaseType(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createPurchaseType, body: body, token: token);
    return PurchaseTypeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PurchaseTypeModel> updatePurchaseType(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updatePurchaseType(id), body: body, token: token);
    return PurchaseTypeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePurchaseType(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deletePurchaseType(id), token: token);
  }

  // Sales Types
  @override
  Future<List<SalesTypeModel>> getSalesTypes({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getSalesTypeList, queryParams: queryParams, token: token);
    final list = response['data']?['salesTypes'] as List? ?? [];
    return list.map((e) => SalesTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<SalesTypeModel> createSalesType(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createSalesType, body: body, token: token);
    return SalesTypeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SalesTypeModel> updateSalesType(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updateSalesType(id), body: body, token: token);
    return SalesTypeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSalesType(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deleteSalesType(id), token: token);
  }

  // Units
  @override
  Future<List<UomModel>> getUoms({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getUomList, queryParams: queryParams, token: token);
    final list = response['data']?['uoms'] as List? ?? [];
    return list.map((e) => UomModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<UomModel> createUom(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createUom, body: body, token: token);
    return UomModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<UomModel> updateUom(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updateUom(id), body: body, token: token);
    return UomModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteUom(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deleteUom(id), token: token);
  }

  // Per Units
  @override
  Future<List<PerUnitModel>> getPerUnits({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getPerUnitList, queryParams: queryParams, token: token);
    final list = response['data']?['perUnits'] as List? ?? [];
    return list.map((e) => PerUnitModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PerUnitModel> createPerUnit(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createPerUnit, body: body, token: token);
    return PerUnitModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PerUnitModel> updatePerUnit(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updatePerUnit(id), body: body, token: token);
    return PerUnitModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePerUnit(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deletePerUnit(id), token: token);
  }

  // Item Groups
  @override
  Future<List<ItemGroupModel>> getItemGroups({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getItemGroupList, queryParams: queryParams, token: token);
    final list = response['data']?['itemGroups'] as List? ?? [];
    return list.map((e) => ItemGroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ItemGroupModel> createItemGroup(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createItemGroup, body: body, token: token);
    return ItemGroupModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ItemGroupModel> updateItemGroup(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updateItemGroup(id), body: body, token: token);
    return ItemGroupModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItemGroup(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deleteItemGroup(id), token: token);
  }

  // Items
  @override
  Future<List<ItemModel>> getItems({String? search, bool? isActive, String? token}) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (isActive != null) 'isActive': isActive,
    };
    final response = await apiClient.get(ApiEndpoints.getItemList, queryParams: queryParams, token: token);
    final list = response['data']?['items'] as List? ?? [];
    return list.map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ItemModel> createItem(Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.post(ApiEndpoints.createItem, body: body, token: token);
    return ItemModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ItemModel> updateItem(String id, Map<String, dynamic> body, {String? token}) async {
    final response = await apiClient.patch(ApiEndpoints.updateItem(id), body: body, token: token);
    return ItemModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItem(String id, {String? token}) async {
    await apiClient.delete(ApiEndpoints.deleteItem(id), token: token);
  }
}
