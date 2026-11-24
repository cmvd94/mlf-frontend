import '../../domain/entities/item_entity.dart';
import 'uom_model.dart';
import 'per_unit_model.dart';
import 'item_group_model.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.itemCode,
    required super.name,
    super.itemGroupId,
    super.itemGroup,
    super.description,
    required super.defaultUomId,
    super.defaultUom,
    required super.defaultPerId,
    super.defaultPer,
    super.hsnCodeId,
    super.hsnCode,
    super.standardRate,
    super.currentStock,
    super.isActive,
    super.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final groupData = json['itemGroupId'];
    final uomData = json['defaultUomId'];
    final perData = json['defaultPerId'];
    final hsnData = json['hsnCodeId'];

    final hsnCodeStr = json['hsnCode']?.toString() ??
        (hsnData is Map ? hsnData['hsnCode']?.toString() ?? '' : '');

    return ItemModel(
      id: json['_id']?.toString() ?? '',
      itemCode: json['itemCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      itemGroupId: groupData is Map
          ? groupData['_id']?.toString()
          : (groupData != null ? groupData.toString() : null),
      itemGroup: groupData is Map
          ? ItemGroupModel.fromJson(groupData as Map<String, dynamic>)
          : null,
      description: json['description']?.toString() ?? '',
      defaultUomId: uomData is Map ? uomData['_id']?.toString() ?? '' : uomData?.toString() ?? '',
      defaultUom: uomData is Map ? UomModel.fromJson(uomData as Map<String, dynamic>) : null,
      defaultPerId: perData is Map ? perData['_id']?.toString() ?? '' : perData?.toString() ?? '',
      defaultPer: perData is Map ? PerUnitModel.fromJson(perData as Map<String, dynamic>) : null,
      hsnCodeId: hsnData is Map ? hsnData['_id']?.toString() : hsnData?.toString(),
      hsnCode: hsnCodeStr,
      standardRate: json['standardRate'] != null
          ? (json['standardRate'] as num).toDouble()
          : 0.0,
      currentStock: json['currentStock'] != null
          ? (json['currentStock'] as num).toDouble()
          : 0.0,
      isActive: json['isActive'] == null ? true : json['isActive'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreatePayload({double? openingStock}) {
    return {
      'name': name,
      if (itemCode.isNotEmpty) 'itemCode': itemCode,
      if (itemGroupId != null && itemGroupId!.isNotEmpty) 'itemGroupId': itemGroupId,
      if (description.isNotEmpty) 'description': description,
      'defaultUomId': defaultUomId,
      'defaultPerId': defaultPerId,
      if (hsnCodeId != null && hsnCodeId!.isNotEmpty) 'hsnCodeId': hsnCodeId,
      if (hsnCode.isNotEmpty) 'hsnCode': hsnCode,
      'standardRate': standardRate,
      if (openingStock != null && openingStock > 0) 'openingStock': openingStock,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'itemCode': itemCode,
      if (itemGroupId != null && itemGroupId!.isNotEmpty) 'itemGroupId': itemGroupId,
      'description': description,
      'defaultUomId': defaultUomId,
      'defaultPerId': defaultPerId,
      'hsnCodeId': hsnCodeId,
      'hsnCode': hsnCode,
      'standardRate': standardRate,
      'isActive': isActive,
    };
  }
}
