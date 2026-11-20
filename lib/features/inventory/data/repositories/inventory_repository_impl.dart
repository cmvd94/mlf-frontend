import 'package:mlf_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/purchase_type_entity.dart';
import '../../domain/entities/uom_entity.dart';
import '../../domain/entities/per_unit_entity.dart';
import '../../domain/entities/item_group_entity.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/masters_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<MastersEntity> getMasters() async {
    final token = await _getToken();
    return await remoteDataSource.getMasters(token: token);
  }

  // Parties
  @override
  Future<List<PartyEntity>> getParties({String? search, bool? isActive}) async {
    final token = await _getToken();
    return await remoteDataSource.getParties(search: search, isActive: isActive, token: token);
  }

  @override
  Future<PartyEntity> createParty({
    required String name,
    String? partyCode,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? gstin,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = {
      'name': name,
      if (partyCode != null && partyCode.isNotEmpty) 'partyCode': partyCode,
      if (contactPerson != null && contactPerson.isNotEmpty) 'contactPerson': contactPerson,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (email != null && email.isNotEmpty) 'email': email,
      if (address != null && address.isNotEmpty) 'address': address,
      if (gstin != null && gstin.isNotEmpty) 'gstin': gstin,
      'isActive': isActive,
    };
    return await remoteDataSource.createParty(body, token: token);
  }

  @override
  Future<PartyEntity> updateParty(String id, {
    String? name,
    String? partyCode,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? gstin,
    bool? isActive,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (partyCode != null) 'partyCode': partyCode,
      if (contactPerson != null) 'contactPerson': contactPerson,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (gstin != null) 'gstin': gstin,
      if (isActive != null) 'isActive': isActive,
    };
    return await remoteDataSource.updateParty(id, body, token: token);
  }

  @override
  Future<void> deleteParty(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteParty(id, token: token);
  }

  // Purchase Types
  @override
  Future<List<PurchaseTypeEntity>> getPurchaseTypes({String? search, bool? isActive}) async {
    final token = await _getToken();
    return await remoteDataSource.getPurchaseTypes(search: search, isActive: isActive, token: token);
  }

  @override
  Future<PurchaseTypeEntity> createPurchaseType({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = {
      'name': name,
      if (code != null && code.isNotEmpty) 'code': code,
      if (description != null && description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
    return await remoteDataSource.createPurchaseType(body, token: token);
  }

  @override
  Future<PurchaseTypeEntity> updatePurchaseType(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
    return await remoteDataSource.updatePurchaseType(id, body, token: token);
  }

  @override
  Future<void> deletePurchaseType(String id) async {
    final token = await _getToken();
    await remoteDataSource.deletePurchaseType(id, token: token);
  }

  // Units
  @override
  Future<List<UomEntity>> getUoms({String? search, bool? isActive}) async {
    final token = await _getToken();
    return await remoteDataSource.getUoms(search: search, isActive: isActive, token: token);
  }

  @override
  Future<UomEntity> createUom({
    required String name,
    required String symbol,
    String? description,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = {
      'name': name,
      'symbol': symbol,
      if (description != null && description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
    return await remoteDataSource.createUom(body, token: token);
  }

  @override
  Future<UomEntity> updateUom(String id, {
    String? name,
    String? symbol,
    String? description,
    bool? isActive,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
    return await remoteDataSource.updateUom(id, body, token: token);
  }

  @override
  Future<void> deleteUom(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteUom(id, token: token);
  }

  // Per Units
  @override
  Future<List<PerUnitEntity>> getPerUnits({String? search, bool? isActive}) async {
    final token = await _getToken();
    return await remoteDataSource.getPerUnits(search: search, isActive: isActive, token: token);
  }

  @override
  Future<PerUnitEntity> createPerUnit({
    required String name,
    required String symbol,
    double multiplier = 1.0,
    String? description,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = {
      'name': name,
      'symbol': symbol,
      'multiplier': multiplier,
      if (description != null && description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
    return await remoteDataSource.createPerUnit(body, token: token);
  }

  @override
  Future<PerUnitEntity> updatePerUnit(String id, {
    String? name,
    String? symbol,
    double? multiplier,
    String? description,
    bool? isActive,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (multiplier != null) 'multiplier': multiplier,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
    return await remoteDataSource.updatePerUnit(id, body, token: token);
  }

  @override
  Future<void> deletePerUnit(String id) async {
    final token = await _getToken();
    await remoteDataSource.deletePerUnit(id, token: token);
  }

  // Item Groups
  @override
  Future<List<ItemGroupEntity>> getItemGroups({String? search, bool? isActive}) async {
    final token = await _getToken();
    return await remoteDataSource.getItemGroups(search: search, isActive: isActive, token: token);
  }

  @override
  Future<ItemGroupEntity> createItemGroup({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = {
      'name': name,
      if (code != null && code.isNotEmpty) 'code': code,
      if (description != null && description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
    return await remoteDataSource.createItemGroup(body, token: token);
  }

  @override
  Future<ItemGroupEntity> updateItemGroup(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
    return await remoteDataSource.updateItemGroup(id, body, token: token);
  }

  @override
  Future<void> deleteItemGroup(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteItemGroup(id, token: token);
  }

  // Items
  @override
  Future<List<ItemEntity>> getItems({String? search, bool? isActive}) async {
    final token = await _getToken();
    return await remoteDataSource.getItems(search: search, isActive: isActive, token: token);
  }

  @override
  Future<ItemEntity> createItem({
    required String name,
    String? itemCode,
    String? itemGroupId,
    String? description,
    required String defaultUomId,
    required String defaultPerId,
    double standardRate = 0.0,
    double openingStock = 0.0,
    bool isActive = true,
  }) async {
    final token = await _getToken();
    final body = {
      'name': name,
      if (itemCode != null && itemCode.isNotEmpty) 'itemCode': itemCode,
      if (itemGroupId != null && itemGroupId.isNotEmpty) 'itemGroupId': itemGroupId,
      if (description != null && description.isNotEmpty) 'description': description,
      'defaultUomId': defaultUomId,
      'defaultPerId': defaultPerId,
      'standardRate': standardRate,
      if (openingStock > 0) 'openingStock': openingStock,
      'isActive': isActive,
    };
    return await remoteDataSource.createItem(body, token: token);
  }

  @override
  Future<ItemEntity> updateItem(String id, {
    String? name,
    String? itemCode,
    String? itemGroupId,
    String? description,
    String? defaultUomId,
    String? defaultPerId,
    double? standardRate,
    bool? isActive,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (itemCode != null) 'itemCode': itemCode,
      if (itemGroupId != null && itemGroupId.isNotEmpty) 'itemGroupId': itemGroupId,
      if (description != null) 'description': description,
      if (defaultUomId != null) 'defaultUomId': defaultUomId,
      if (defaultPerId != null) 'defaultPerId': defaultPerId,
      if (standardRate != null) 'standardRate': standardRate,
      if (isActive != null) 'isActive': isActive,
    };
    return await remoteDataSource.updateItem(id, body, token: token);
  }

  @override
  Future<void> deleteItem(String id) async {
    final token = await _getToken();
    await remoteDataSource.deleteItem(id, token: token);
  }
}
