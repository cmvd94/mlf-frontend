import 'package:mlf_frontend/features/inventory/domain/entities/party_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/purchase_type_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/uom_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/per_unit_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/item_group_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/item_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/entities/masters_entity.dart';
import 'package:mlf_frontend/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:mlf_frontend/features/purchase/domain/entities/purchase_entity.dart';
import 'package:mlf_frontend/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';

class MockInventoryRepository implements InventoryRepository {
  List<PartyEntity> parties = [
    const PartyEntity(id: 'p1', partyCode: 'PRT_001', name: 'Alpha Steel Corp', phoneNumber: '9876543210'),
  ];
  List<PurchaseTypeEntity> purchaseTypes = [
    const PurchaseTypeEntity(id: 't1', name: 'Local Purchase', code: 'LOCAL'),
  ];
  List<ItemGroupEntity> itemGroups = [
    const ItemGroupEntity(id: 'g1', name: 'Raw Material', code: 'RAW'),
  ];
  List<UomEntity> uoms = [
    const UomEntity(id: 'u1', name: 'Kilogram', symbol: 'KGS'),
    const UomEntity(id: 'u2', name: 'Pieces', symbol: 'PCS'),
  ];
  List<PerUnitEntity> perUnits = [
    const PerUnitEntity(id: 'pu1', name: 'per Kg', symbol: 'kg', multiplier: 1.0),
  ];
  List<GodownEntity> godowns = [
    const GodownEntity(
      id: 'gd1',
      godownId: 'GD_01',
      name: 'Main Central Godown',
      type: GodownType.companyGodown,
      country: 'India',
      zone: 'South',
      state: 'Tamil Nadu',
      district: 'Coimbatore',
      pincode: '641001',
      isActive: true,
    ),
  ];
  List<ItemEntity> items = [
    const ItemEntity(
      id: 'i1',
      itemCode: 'ITM_001',
      name: 'Steel Rod 12mm',
      itemGroupId: 'g1',
      itemGroup: ItemGroupEntity(id: 'g1', name: 'Raw Material', code: 'RAW'),
      defaultUomId: 'u1',
      defaultUom: UomEntity(id: 'u1', name: 'Kilogram', symbol: 'KGS'),
      defaultPerId: 'pu1',
      defaultPer: PerUnitEntity(id: 'pu1', name: 'per Kg', symbol: 'kg', multiplier: 1.0),
      standardRate: 55.0,
      currentStock: 100.0,
    ),
  ];

  @override
  Future<MastersEntity> getMasters() async {
    return MastersEntity(
      parties: parties,
      purchaseTypes: purchaseTypes,
      itemGroups: itemGroups,
      uoms: uoms,
      perUnits: perUnits,
      items: items,
      godowns: godowns,
    );
  }

  @override
  Future<List<PartyEntity>> getParties({String? search, bool? isActive}) async => parties;

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
    final party = PartyEntity(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      partyCode: partyCode ?? 'PRT_999',
      name: name,
      contactPerson: contactPerson ?? '',
      phoneNumber: phoneNumber ?? '',
      email: email ?? '',
      address: address ?? '',
      gstin: gstin ?? '',
      isActive: isActive,
    );
    parties.add(party);
    return party;
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
    final index = parties.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final old = parties[index];
      final updated = PartyEntity(
        id: old.id,
        partyCode: partyCode ?? old.partyCode,
        name: name ?? old.name,
        contactPerson: contactPerson ?? old.contactPerson,
        phoneNumber: phoneNumber ?? old.phoneNumber,
        email: email ?? old.email,
        address: address ?? old.address,
        gstin: gstin ?? old.gstin,
        isActive: isActive ?? old.isActive,
      );
      parties[index] = updated;
      return updated;
    }
    throw Exception('Party not found');
  }

  @override
  Future<void> deleteParty(String id) async {
    parties.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<PurchaseTypeEntity>> getPurchaseTypes({String? search, bool? isActive}) async => purchaseTypes;

  @override
  Future<PurchaseTypeEntity> createPurchaseType({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    final t = PurchaseTypeEntity(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code ?? '',
      description: description ?? '',
      isActive: isActive,
    );
    purchaseTypes.add(t);
    return t;
  }

  @override
  Future<PurchaseTypeEntity> updatePurchaseType(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    final index = purchaseTypes.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final old = purchaseTypes[index];
      final updated = PurchaseTypeEntity(
        id: old.id,
        name: name ?? old.name,
        code: code ?? old.code,
        description: description ?? old.description,
        isActive: isActive ?? old.isActive,
      );
      purchaseTypes[index] = updated;
      return updated;
    }
    throw Exception('Purchase type not found');
  }

  @override
  Future<void> deletePurchaseType(String id) async {
    purchaseTypes.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<UomEntity>> getUoms({String? search, bool? isActive}) async => uoms;

  @override
  Future<UomEntity> createUom({
    required String name,
    required String symbol,
    String? description,
    bool isActive = true,
  }) async {
    final u = UomEntity(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      symbol: symbol,
      description: description ?? '',
      isActive: isActive,
    );
    uoms.add(u);
    return u;
  }

  @override
  Future<UomEntity> updateUom(String id, {
    String? name,
    String? symbol,
    String? description,
    bool? isActive,
  }) async {
    final index = uoms.indexWhere((u) => u.id == id);
    if (index >= 0) {
      final old = uoms[index];
      final updated = UomEntity(
        id: old.id,
        name: name ?? old.name,
        symbol: symbol ?? old.symbol,
        description: description ?? old.description,
        isActive: isActive ?? old.isActive,
      );
      uoms[index] = updated;
      return updated;
    }
    throw Exception('UOM not found');
  }

  @override
  Future<void> deleteUom(String id) async {
    uoms.removeWhere((u) => u.id == id);
  }

  @override
  Future<List<PerUnitEntity>> getPerUnits({String? search, bool? isActive}) async => perUnits;

  @override
  Future<PerUnitEntity> createPerUnit({
    required String name,
    required String symbol,
    double multiplier = 1.0,
    String? description,
    bool isActive = true,
  }) async {
    final p = PerUnitEntity(
      id: 'pu_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      symbol: symbol,
      multiplier: multiplier,
      description: description ?? '',
      isActive: isActive,
    );
    perUnits.add(p);
    return p;
  }

  @override
  Future<PerUnitEntity> updatePerUnit(String id, {
    String? name,
    String? symbol,
    double? multiplier,
    String? description,
    bool? isActive,
  }) async {
    final index = perUnits.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final old = perUnits[index];
      final updated = PerUnitEntity(
        id: old.id,
        name: name ?? old.name,
        symbol: symbol ?? old.symbol,
        multiplier: multiplier ?? old.multiplier,
        description: description ?? old.description,
        isActive: isActive ?? old.isActive,
      );
      perUnits[index] = updated;
      return updated;
    }
    throw Exception('Per unit not found');
  }

  @override
  Future<void> deletePerUnit(String id) async {
    perUnits.removeWhere((p) => p.id == id);
  }

  // Item Groups
  @override
  Future<List<ItemGroupEntity>> getItemGroups({String? search, bool? isActive}) async => itemGroups;

  @override
  Future<ItemGroupEntity> createItemGroup({
    required String name,
    String? code,
    String? description,
    bool isActive = true,
  }) async {
    final g = ItemGroupEntity(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code ?? name.toUpperCase().replaceAll(' ', '_'),
      description: description ?? '',
      isActive: isActive,
    );
    itemGroups.add(g);
    return g;
  }

  @override
  Future<ItemGroupEntity> updateItemGroup(String id, {
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    final index = itemGroups.indexWhere((g) => g.id == id);
    if (index >= 0) {
      final old = itemGroups[index];
      final updated = ItemGroupEntity(
        id: old.id,
        name: name ?? old.name,
        code: code ?? old.code,
        description: description ?? old.description,
        isActive: isActive ?? old.isActive,
      );
      itemGroups[index] = updated;
      return updated;
    }
    throw Exception('Item group not found');
  }

  @override
  Future<void> deleteItemGroup(String id) async {
    itemGroups.removeWhere((g) => g.id == id);
  }

  @override
  Future<List<ItemEntity>> getItems({String? search, bool? isActive}) async => items;

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
    final group = itemGroupId != null
        ? itemGroups.firstWhere((g) => g.id == itemGroupId, orElse: () => const ItemGroupEntity(id: '', name: ''))
        : null;
    final it = ItemEntity(
      id: 'it_${DateTime.now().millisecondsSinceEpoch}',
      itemCode: itemCode ?? 'ITM_999',
      name: name,
      itemGroupId: itemGroupId,
      itemGroup: group?.id.isNotEmpty == true ? group : null,
      description: description ?? '',
      defaultUomId: defaultUomId,
      defaultPerId: defaultPerId,
      standardRate: standardRate,
      currentStock: openingStock,
      isActive: isActive,
    );
    items.add(it);
    return it;
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
    final index = items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final old = items[index];
      final targetGroupId = itemGroupId ?? old.itemGroupId;
      final group = targetGroupId != null
          ? itemGroups.firstWhere((g) => g.id == targetGroupId, orElse: () => const ItemGroupEntity(id: '', name: ''))
          : null;
      final updated = ItemEntity(
        id: old.id,
        itemCode: itemCode ?? old.itemCode,
        name: name ?? old.name,
        itemGroupId: targetGroupId,
        itemGroup: group?.id.isNotEmpty == true ? group : null,
        description: description ?? old.description,
        defaultUomId: defaultUomId ?? old.defaultUomId,
        defaultPerId: defaultPerId ?? old.defaultPerId,
        standardRate: standardRate ?? old.standardRate,
        currentStock: old.currentStock,
        isActive: isActive ?? old.isActive,
      );
      items[index] = updated;
      return updated;
    }
    throw Exception('Item not found');
  }

  @override
  Future<void> deleteItem(String id) async {
    items.removeWhere((i) => i.id == id);
  }
}

class MockPurchaseRepository implements PurchaseRepository {
  List<PurchaseEntity> purchases = [];

  @override
  Future<List<PurchaseEntity>> getPurchases({
    int page = 1,
    int limit = 20,
    String? search,
    String? partyId,
    String? itemId,
    String? purchaseTypeId,
    String? godownId,
  }) async => purchases;

  @override
  Future<PurchaseEntity> getPurchaseById(String id) async => purchases.firstWhere((p) => p.id == id);

  @override
  Future<PurchaseEntity> createPurchase({
    required DateTime date,
    required String partyId,
    required String purchaseTypeId,
    String? godownId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
    String? itemId,
    String? batchNo,
    String? uomId,
    double? uomQuantity,
    double? actualQuantity,
    double? billedQuantity,
    double? rate,
    String? perId,
  }) async {
    final List<PurchaseItemEntity> itemEntities = [];
    if (items != null && items.isNotEmpty) {
      for (final it in items) {
        itemEntities.add(PurchaseItemEntity(
          itemId: it.itemId,
          itemName: 'Item ${it.itemId}',
          itemCode: 'ITM_${it.itemId}',
          godownId: it.godownId.isNotEmpty ? it.godownId : (godownId ?? 'gd1'),
          godownName: 'Godown ${it.godownId}',
          godownCode: 'GD_${it.godownId}',
          batchNo: it.batchNo,
          uomId: it.uomId,
          uomSymbol: 'PCS',
          uomQuantity: it.uomQuantity,
          actualQuantity: it.actualQuantity,
          billedQuantity: it.billedQuantity,
          rate: it.rate,
          perId: it.perId,
          perSymbol: 'unit',
          amount: it.billedQuantity * it.rate,
        ));
      }
    } else if (itemId != null && uomId != null && perId != null) {
      itemEntities.add(PurchaseItemEntity(
        itemId: itemId,
        itemName: 'Steel Rod 12mm',
        itemCode: 'STL_12',
        godownId: godownId ?? 'gd1',
        godownName: 'Main Central Godown',
        godownCode: 'GD_01',
        batchNo: batchNo ?? 'LOT_2026_01',
        uomId: uomId,
        uomSymbol: 'KGS',
        uomQuantity: uomQuantity ?? actualQuantity ?? 1.0,
        actualQuantity: actualQuantity ?? 0.0,
        billedQuantity: billedQuantity ?? 0.0,
        rate: rate ?? 0.0,
        perId: perId,
        perSymbol: 'kg',
        amount: (billedQuantity ?? 0.0) * (rate ?? 0.0),
      ));
    }

    final subTotal = itemEntities.fold<double>(0.0, (s, i) => s + i.amount);
    final totalActual = itemEntities.fold<double>(0.0, (s, i) => s + i.actualQuantity);
    final totalBilled = itemEntities.fold<double>(0.0, (s, i) => s + i.billedQuantity);
    final hasGst = isGstBill ?? false;
    final gstPct = hasGst ? (gstPercentage ?? 18.0) : 0.0;
    final gstAmt = hasGst ? (subTotal * (gstPct / 100)) : 0.0;
    final totalAmt = subTotal + gstAmt;

    final p = PurchaseEntity(
      id: 'pur_${DateTime.now().millisecondsSinceEpoch}',
      purchaseNumber: 'PUR_0001',
      date: date,
      partyId: partyId,
      partyName: 'Alpha Steel Corp',
      purchaseTypeId: purchaseTypeId,
      purchaseTypeName: 'Local Purchase',
      godownId: godownId ?? 'gd1',
      godownName: 'Main Central Godown',
      godownCode: 'GD_01',
      items: itemEntities,
      subTotal: subTotal,
      isGstBill: hasGst,
      gstPercentage: gstPct,
      gstAmount: gstAmt,
      totalAmount: totalAmt,
      totalActualQuantity: totalActual,
      totalBilledQuantity: totalBilled,
      notes: notes ?? '',
    );
    purchases.add(p);
    return p;
  }

  @override
  Future<PurchaseEntity> updatePurchase({
    required String id,
    DateTime? date,
    String? partyId,
    String? purchaseTypeId,
    List<PurchaseItemInput>? items,
    bool? isGstBill,
    double? gstPercentage,
    String? notes,
  }) async {
    final existingIndex = purchases.indexWhere((p) => p.id == id);
    if (existingIndex == -1) throw Exception('Purchase not found');
    final existing = purchases[existingIndex];

    List<PurchaseItemEntity> itemEntities = existing.items;
    if (items != null && items.isNotEmpty) {
      itemEntities = items
          .map((it) => PurchaseItemEntity(
                itemId: it.itemId,
                itemName: 'Item ${it.itemId}',
                itemCode: 'ITM_${it.itemId}',
                godownId: it.godownId,
                godownName: 'Godown ${it.godownId}',
                godownCode: 'GD_${it.godownId}',
                batchNo: it.batchNo,
                uomId: it.uomId,
                uomSymbol: 'PCS',
                uomQuantity: it.uomQuantity,
                actualQuantity: it.actualQuantity,
                billedQuantity: it.billedQuantity,
                rate: it.rate,
                perId: it.perId,
                perSymbol: 'unit',
                amount: it.billedQuantity * it.rate,
              ))
          .toList();
    }

    final subTotal = itemEntities.fold<double>(0.0, (s, i) => s + i.amount);
    final totalActual = itemEntities.fold<double>(0.0, (s, i) => s + i.actualQuantity);
    final totalBilled = itemEntities.fold<double>(0.0, (s, i) => s + i.billedQuantity);
    final hasGst = isGstBill ?? existing.isGstBill;
    final gstPct = hasGst ? (gstPercentage ?? existing.gstPercentage) : 0.0;
    final gstAmt = hasGst ? (subTotal * (gstPct / 100)) : 0.0;
    final totalAmt = subTotal + gstAmt;

    final updated = PurchaseEntity(
      id: existing.id,
      purchaseNumber: existing.purchaseNumber,
      date: date ?? existing.date,
      partyId: partyId ?? existing.partyId,
      partyName: existing.partyName,
      purchaseTypeId: purchaseTypeId ?? existing.purchaseTypeId,
      purchaseTypeName: existing.purchaseTypeName,
      godownId: existing.godownId,
      godownName: existing.godownName,
      godownCode: existing.godownCode,
      items: itemEntities,
      subTotal: subTotal,
      isGstBill: hasGst,
      gstPercentage: gstPct,
      gstAmount: gstAmt,
      totalAmount: totalAmt,
      totalActualQuantity: totalActual,
      totalBilledQuantity: totalBilled,
      notes: notes ?? existing.notes,
    );

    purchases[existingIndex] = updated;
    return updated;
  }

  @override
  Future<void> deletePurchase(String id) async {
    purchases.removeWhere((p) => p.id == id);
  }
}
