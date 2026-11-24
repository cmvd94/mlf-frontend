import '../../domain/entities/hsn_code_entity.dart';

class HsnCodeModel extends HsnCodeEntity {
  const HsnCodeModel({
    required super.id,
    required super.hsnCode,
    super.description,
    super.gstRate,
    super.isActive,
    super.createdAt,
  });

  factory HsnCodeModel.fromJson(Map<String, dynamic> json) {
    return HsnCodeModel(
      id: json['_id']?.toString() ?? '',
      hsnCode: json['hsnCode']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      gstRate: json['gstRate'] != null ? (json['gstRate'] as num).toDouble() : 5.0,
      isActive: json['isActive'] == null ? true : json['isActive'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'hsnCode': hsnCode,
      if (description.isNotEmpty) 'description': description,
      'gstRate': gstRate,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'hsnCode': hsnCode,
      'description': description,
      'gstRate': gstRate,
      'isActive': isActive,
    };
  }
}
