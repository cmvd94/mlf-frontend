import '../domain/entities/admin_role.dart';
import '../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.employeeId,
    required super.role,
    super.isActive = true,
    super.language,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      employeeId: (json['employeeId'] ?? '').toString(),
      role: AdminRole.fromString(json['role']?.toString()),
      isActive: json['isActive'] ?? true,
      language: json['language']?.toString(),
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'employeeId': employeeId,
      'role': role.value,
      'isActive': isActive,
      if (language != null) 'language': language,
    };
  }
}
