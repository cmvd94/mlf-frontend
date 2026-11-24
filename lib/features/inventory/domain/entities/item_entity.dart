import 'uom_entity.dart';
import 'per_unit_entity.dart';
import 'item_group_entity.dart';

class ItemEntity {
  final String id;
  final String itemCode;
  final String name;
  final String? itemGroupId;
  final ItemGroupEntity? itemGroup;
  final String description;
  final String defaultUomId;
  final UomEntity? defaultUom;
  final String defaultPerId;
  final PerUnitEntity? defaultPer;
  final String? hsnCodeId;
  final String hsnCode;
  final double standardRate;
  final double currentStock; // Reflects stock value updated by purchases
  final bool isActive;
  final DateTime? createdAt;

  const ItemEntity({
    required this.id,
    required this.itemCode,
    required this.name,
    this.itemGroupId,
    this.itemGroup,
    this.description = '',
    required this.defaultUomId,
    this.defaultUom,
    required this.defaultPerId,
    this.defaultPer,
    this.hsnCodeId,
    this.hsnCode = '',
    this.standardRate = 0.0,
    this.currentStock = 0.0,
    this.isActive = true,
    this.createdAt,
  });
}
