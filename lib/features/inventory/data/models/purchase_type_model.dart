import '../../domain/entities/purchase_type_entity.dart';

class PurchaseTypeModel extends PurchaseTypeEntity {
  const PurchaseTypeModel({
    required super.id,
    required super.name,
    super.code,
    super.description,
    super.isActive,
    super.createdAt,
  });

  factory PurchaseTypeModel.fromJson(Map<String, dynamic> json) {
    return PurchaseTypeModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
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
      if (code.isNotEmpty) 'code': code,
      if (description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'isActive': isActive,
    };
  }
}
