import '../../domain/entities/per_unit_entity.dart';

class PerUnitModel extends PerUnitEntity {
  const PerUnitModel({
    required super.id,
    required super.name,
    required super.symbol,
    super.multiplier,
    super.description,
    super.isActive,
    super.createdAt,
  });

  factory PerUnitModel.fromJson(Map<String, dynamic> json) {
    return PerUnitModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      multiplier: json['multiplier'] != null
          ? (json['multiplier'] as num).toDouble()
          : 1.0,
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] == null ? true : json['isActive'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'symbol': symbol,
      'multiplier': multiplier,
      if (description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'symbol': symbol,
      'multiplier': multiplier,
      'description': description,
      'isActive': isActive,
    };
  }
}
