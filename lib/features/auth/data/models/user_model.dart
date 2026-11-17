import 'package:mlf_frontend/features/admin/data/models/access_scope_model.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.name,
    super.email,
    super.role,
    super.accessScope,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Accommodates both wrapped response: { data: { user: ..., token: ... } }
    // and flat response
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final user = data['user'] is Map<String, dynamic> ? data['user'] : data;

    return UserModel(
      id: (user['id'] ?? user['_id'] ?? '').toString(),
      phoneNumber: (user['phoneNumber'] ?? user['phone'] ?? '').toString(),
      name: user['name']?.toString(),
      email: user['email']?.toString(),
      role: user['role']?.toString(),
      accessScope: user['accessScope'] != null && user['accessScope'] is Map<String, dynamic>
          ? AccessScopeModel.fromJson(user['accessScope'] as Map<String, dynamic>)
          : null,
      token: (data['token'] ?? data['accessToken'] ?? json['token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'role': role,
      if (accessScope != null)
        'accessScope': accessScope is AccessScopeModel
            ? (accessScope as AccessScopeModel).toJson()
            : AccessScopeModel.fromEntity(accessScope!).toJson(),
      'token': token,
    };
  }
}
