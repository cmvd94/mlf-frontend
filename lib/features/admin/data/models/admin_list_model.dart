import 'package:mlf_frontend/features/admin/domain/entities/admin_list_entity.dart';
import 'package:mlf_frontend/features/admin/domain/entities/admin_role.dart';
import 'admin_user_model.dart';

class AdminListModel extends AdminListEntity {
  const AdminListModel({
    required super.users,
    super.assignableRoles = const [],
    required super.totalItems,
    required super.currentPage,
    required super.totalPages,
    required super.hasNextPage,
    required super.hasPrevPage,
  });

  factory AdminListModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final userListRaw = data['userList'] ?? data['users'] ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final assignableRolesRaw = data['assignableRoles'] as List<dynamic>? ?? [];

    final users = (userListRaw as List)
        .map((u) => AdminUserModel.fromJson(u as Map<String, dynamic>))
        .toList();

    final assignableRoles = assignableRolesRaw
        .map((r) => AdminRole.fromString(r.toString()))
        .toList();

    return AdminListModel(
      users: users,
      assignableRoles: assignableRoles,
      totalItems: pagination['totalItems'] ?? users.length,
      currentPage: pagination['currentPage'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
      hasNextPage: pagination['hasNextPage'] ?? false,
      hasPrevPage: pagination['hasPrevPage'] ?? false,
    );
  }
}
