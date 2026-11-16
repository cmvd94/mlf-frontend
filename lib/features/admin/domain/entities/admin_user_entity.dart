import 'admin_role.dart';

class AdminUserEntity {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String employeeId;
  final AdminRole role;
  final bool isActive;
  final String? language;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool canEdit;
  final bool canDelete;
  final bool canToggleStatus;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.employeeId,
    required this.role,
    this.isActive = true,
    this.language,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.canEdit = true,
    this.canDelete = false,
    this.canToggleStatus = true,
  });

  AdminUserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? employeeId,
    AdminRole? role,
    bool? isActive,
    String? language,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? canEdit,
    bool? canDelete,
    bool? canToggleStatus,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      language: language ?? this.language,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      canToggleStatus: canToggleStatus ?? this.canToggleStatus,
    );
  }
}
