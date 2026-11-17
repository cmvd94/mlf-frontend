import '../../domain/entities/access_scope_entity.dart';

class AccessScopeModel extends AccessScopeEntity {
  const AccessScopeModel({
    super.country,
    super.zone,
    super.state,
    super.district,
    super.pincode,
  });

  factory AccessScopeModel.fromEntity(AccessScopeEntity entity) {
    return AccessScopeModel(
      country: entity.country,
      zone: entity.zone,
      state: entity.state,
      district: entity.district,
      pincode: entity.pincode,
    );
  }

  factory AccessScopeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AccessScopeModel();
    return AccessScopeModel(
      country: json['country']?.toString(),
      zone: json['zone']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      pincode: (json['pincode'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (country != null && country!.isNotEmpty) map['country'] = country;
    if (zone != null && zone!.isNotEmpty) map['zone'] = zone;
    if (state != null && state!.isNotEmpty) map['state'] = state;
    if (district != null && district!.isNotEmpty) map['district'] = district;
    if (pincode != null && pincode!.isNotEmpty) map['pincode'] = pincode;
    return map;
  }
}
