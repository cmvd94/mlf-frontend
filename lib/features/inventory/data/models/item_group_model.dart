import '../../domain/entities/item_group_entity.dart';

class ItemGroupModel extends ItemGroupEntity {
  const ItemGroupModel({
    required super.id,
    required super.name,
    super.code,
    super.description,
    super.isActive,
    super.createdAt,
  });

  factory ItemGroupModel.fromJson(Map<String, dynamic> json) {
    return ItemGroupModel(
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
