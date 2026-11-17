import 'package:mlf_frontend/features/admin/domain/entities/access_scope_entity.dart';

class UserEntity {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? role;
  final AccessScopeEntity? accessScope;
  final String token;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.role,
    this.accessScope,
    required this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ phoneNumber.hashCode;
}
