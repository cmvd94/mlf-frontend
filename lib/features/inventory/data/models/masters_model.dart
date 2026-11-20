import '../../domain/entities/masters_entity.dart';
import 'party_model.dart';
import 'purchase_type_model.dart';
import 'uom_model.dart';
import 'per_unit_model.dart';
import 'item_group_model.dart';
import 'item_model.dart';
import 'package:mlf_frontend/features/admin/data/models/godown_model.dart';

class MastersModel extends MastersEntity {
  const MastersModel({
    super.parties = const [],
    super.purchaseTypes = const [],
    super.uoms = const [],
    super.perUnits = const [],
    super.itemGroups = const [],
    super.items = const [],
    super.godowns = const [],
  });

  factory MastersModel.fromJson(Map<String, dynamic> json) {
    return MastersModel(
      parties: (json['parties'] as List? ?? [])
          .map((e) => PartyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      purchaseTypes: (json['purchaseTypes'] as List? ?? [])
          .map((e) => PurchaseTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      uoms: (json['uoms'] as List? ?? [])
          .map((e) => UomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      perUnits: (json['perUnits'] as List? ?? [])
          .map((e) => PerUnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemGroups: (json['itemGroups'] as List? ?? [])
          .map((e) => ItemGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List? ?? [])
          .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      godowns: (json['godowns'] as List? ?? [])
          .map((e) => GodownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
