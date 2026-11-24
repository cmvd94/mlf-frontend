import '../../domain/entities/masters_entity.dart';
import '../../domain/entities/party_entity.dart';
import '../../domain/entities/purchase_type_entity.dart';
import '../../domain/entities/sales_type_entity.dart';
import '../../domain/entities/uom_entity.dart';
import '../../domain/entities/per_unit_entity.dart';
import '../../domain/entities/item_group_entity.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/entities/hsn_code_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/godown_entity.dart';
import 'party_model.dart';
import 'purchase_type_model.dart';
import 'sales_type_model.dart';
import 'uom_model.dart';
import 'per_unit_model.dart';
import 'item_group_model.dart';
import 'item_model.dart';
import 'hsn_code_model.dart';
import 'package:mlf_frontend/features/admin/data/models/godown_model.dart';

class MastersModel extends MastersEntity {
  const MastersModel({
    super.parties = const [],
    super.purchaseTypes = const [],
    super.salesTypes = const [],
    super.uoms = const [],
    super.perUnits = const [],
    super.itemGroups = const [],
    super.items = const [],
    super.godowns = const [],
    super.hsnCodes = const [],
  });

  factory MastersModel.fromJson(Map<String, dynamic> json) {
    return MastersModel(
      parties: (json['parties'] as List? ?? [])
          .map<PartyEntity>((e) => PartyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      purchaseTypes: (json['purchaseTypes'] as List? ?? [])
          .map<PurchaseTypeEntity>((e) => PurchaseTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      salesTypes: (json['salesTypes'] as List? ?? [])
          .map<SalesTypeEntity>((e) => SalesTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      uoms: (json['uoms'] as List? ?? [])
          .map<UomEntity>((e) => UomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      perUnits: (json['perUnits'] as List? ?? [])
          .map<PerUnitEntity>((e) => PerUnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemGroups: (json['itemGroups'] as List? ?? [])
          .map<ItemGroupEntity>((e) => ItemGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List? ?? [])
          .map<ItemEntity>((e) => ItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      godowns: (json['godowns'] as List? ?? [])
          .map<GodownEntity>((e) => GodownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hsnCodes: (json['hsnCodes'] as List? ?? [])
          .map<HsnCodeEntity>((e) => HsnCodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
