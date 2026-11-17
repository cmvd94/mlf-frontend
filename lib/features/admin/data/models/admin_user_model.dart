import 'package:mlf_frontend/features/admin/data/models/access_scope_model.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_role.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_user_entity.dart';

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
    super.accessScope,
    super.createdBy,
    super.updatedBy,
    super.createdAt,
    super.updatedAt,
    super.canEdit = true,
    super.canDelete = false,
    super.canToggleStatus = true,
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
      accessScope: json['accessScope'] != null && json['accessScope'] is Map<String, dynamic>
          ? AccessScopeModel.fromJson(json['accessScope'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      canEdit: json['canEdit'] ?? true,
      canDelete: json['canDelete'] ?? false,
      canToggleStatus: json['canToggleStatus'] ?? true,
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
      if (accessScope != null)
        'accessScope': accessScope is AccessScopeModel
            ? (accessScope as AccessScopeModel).toJson()
            : AccessScopeModel.fromEntity(accessScope!).toJson(),
    };
  }
}
