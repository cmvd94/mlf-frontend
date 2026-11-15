class ApiEndpoints {
  // Authentication
  static const String login = '/admin/auth/login';
  static const String clientLogin = '/client/auth/login';

  // Admin CRUD
  static const String createAdmin = '/admin/crud/create-admin-user';
  static const String getAdminList = '/admin/crud/get-admin-user-list';
  static const String updateIsActiveAdmin = '/admin/crud/update-isactive-admin-user';
  static String getAdminById(String id) => '/admin/crud/get-a-admin-user/$id';
  static String updateAdmin(String id) => '/admin/crud/update-admin-user/$id';
  static String deleteAdmin(String id) => '/admin/crud/delete-admin-user/$id';
}
