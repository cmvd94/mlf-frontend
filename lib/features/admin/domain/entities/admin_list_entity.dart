import 'admin_user_entity.dart';

class AdminListEntity {
  final List<AdminUserEntity> users;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const AdminListEntity({
    required this.users,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AdminListEntity.empty() {
    return const AdminListEntity(
      users: [],
      totalItems: 0,
      currentPage: 1,
      totalPages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }
}
