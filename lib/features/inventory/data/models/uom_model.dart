import '../../domain/entities/uom_entity.dart';

class UomModel extends UomEntity {
  const UomModel({
    required super.id,
    required super.name,
    required super.symbol,
    super.description,
    super.isActive,
    super.createdAt,
  });

  factory UomModel.fromJson(Map<String, dynamic> json) {
    return UomModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
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
      if (description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'symbol': symbol,
      'description': description,
      'isActive': isActive,
    };
  }
}
