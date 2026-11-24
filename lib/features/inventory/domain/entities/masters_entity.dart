import 'party_entity.dart';
import 'purchase_type_entity.dart';
import 'sales_type_entity.dart';
import 'uom_entity.dart';
import 'per_unit_entity.dart';
import 'item_group_entity.dart';
import 'item_entity.dart';
import 'hsn_code_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';

class MastersEntity {
  final List<PartyEntity> parties;
  final List<PurchaseTypeEntity> purchaseTypes;
  final List<SalesTypeEntity> salesTypes;
  final List<UomEntity> uoms;
  final List<PerUnitEntity> perUnits;
  final List<ItemGroupEntity> itemGroups;
  final List<ItemEntity> items;
  final List<GodownEntity> godowns;
  final List<HsnCodeEntity> hsnCodes;

  const MastersEntity({
    this.parties = const [],
    this.purchaseTypes = const [],
    this.salesTypes = const [],
    this.uoms = const [],
    this.perUnits = const [],
    this.itemGroups = const [],
    this.items = const [],
    this.godowns = const [],
    this.hsnCodes = const [],
  });
}
