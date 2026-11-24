import '../entities/party_entity.dart';
import '../entities/purchase_type_entity.dart';
import '../entities/sales_type_entity.dart';
import '../entities/uom_entity.dart';
import '../entities/per_unit_entity.dart';
import '../entities/item_group_entity.dart';
import '../entities/item_entity.dart';
import '../entities/masters_entity.dart';

abstract class InventoryRepository {
  Future<MastersEntity> getMasters();

  // Parties
  Future<List<PartyEntity>> getParties({String? search, bool? isActive});
  Future<PartyEntity> createParty({
    required String name,
    String? partyCode,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? gstin,
    bool isActive = true,
  });
  Future<PartyEntity> updateParty(String id, {
    String? name,
    String? partyCode,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? gstin,
    bool? isActive,
  });
  Future<void> deleteParty(String id);

  // Purchase Types
  Future<List<PurchaseTypeEntity>> getPurchaseTypes({String? search, bool? isActive});
  Future<PurchaseTypeEntity> createPurchaseType({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  });
  Future<PurchaseTypeEntity> updatePurchaseType(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  });
  Future<void> deletePurchaseType(String id);

  // Sales Types
  Future<List<SalesTypeEntity>> getSalesTypes({String? search, bool? isActive});
  Future<SalesTypeEntity> createSalesType({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  });
  Future<SalesTypeEntity> updateSalesType(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  });
  Future<void> deleteSalesType(String id);

  // Units
  Future<List<UomEntity>> getUoms({String? search, bool? isActive});
  Future<UomEntity> createUom({
    required String name,
    required String symbol,
    String? description,
    bool isActive = true,
  });
  Future<UomEntity> updateUom(String id, {
    String? name,
    String? symbol,
    String? description,
    bool? isActive,
  });
  Future<void> deleteUom(String id);

  // Per Units
  Future<List<PerUnitEntity>> getPerUnits({String? search, bool? isActive});
  Future<PerUnitEntity> createPerUnit({
    required String name,
    required String symbol,
    double multiplier = 1.0,
    String? description,
    bool isActive = true,
  });
  Future<PerUnitEntity> updatePerUnit(String id, {
    String? name,
    String? symbol,
    double? multiplier,
    String? description,
    bool? isActive,
  });
  Future<void> deletePerUnit(String id);

  // Item Groups
  Future<List<ItemGroupEntity>> getItemGroups({String? search, bool? isActive});
  Future<ItemGroupEntity> createItemGroup({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  });
  Future<ItemGroupEntity> updateItemGroup(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  });
  Future<void> deleteItemGroup(String id);

  // Items
  Future<List<ItemEntity>> getItems({String? search, bool? isActive});
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
  });
  Future<ItemEntity> updateItem(String id, {
    String? name,
    String? itemCode,
    String? itemGroupId,
    String? description,
    String? defaultUomId,
    String? defaultPerId,
    double? standardRate,
    bool? isActive,
  });
  Future<void> deleteItem(String id);
}
