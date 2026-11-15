import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.name,
    super.email,
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
      token: (data['token'] ?? data['accessToken'] ?? json['token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
