class ApiEndpoints {
  // Authentication
  static const String login = '/admin/auth/login';
  static const String clientLogin = '/client/auth/login';
  static const String changePassword = '/admin/auth/change-password';

  // Admin CRUD (matches backend CRUDAdminUserController routes)
  static const String staticData = '/admin/static-data';
  static const String createAdmin = '/admin/crud/create-admin';
  static const String getAdminList = '/admin/crud/get-user-list';
  static const String updateIsActiveAdmin = '/admin/crud/update-is-active-user';
  static String getAdminById(String id) => '/admin/crud/get-a-user/$id';
  static String updateAdmin(String id) => '/admin/crud/update-admin/$id';
  static String deleteAdmin(String id) => '/admin/crud/delete-admin/$id';
}
