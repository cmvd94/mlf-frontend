import 'package:mlf_frontend/features/admin/domain/entities/admin_list_entity.dart';
import 'admin_user_model.dart';

class AdminListModel extends AdminListEntity {
  const AdminListModel({
    required super.users,
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

    final users = (userListRaw as List)
        .map((u) => AdminUserModel.fromJson(u as Map<String, dynamic>))
        .toList();

    return AdminListModel(
      users: users,
      totalItems: pagination['totalItems'] ?? users.length,
      currentPage: pagination['currentPage'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
      hasNextPage: pagination['hasNextPage'] ?? false,
      hasPrevPage: pagination['hasPrevPage'] ?? false,
    );
  }
}
