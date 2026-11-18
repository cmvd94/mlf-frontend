class ApiEndpoints {
  // Authentication
  static const String login = '/admin/auth/login';
  static const String clientLogin = '/client/auth/login';
  static const String changePassword = '/admin/auth/change-password';
  static const String logout = '/admin/auth/logout';
  static const String logoutAll = '/admin/auth/logout-all';

  // Admin CRUD (matches backend CRUDAdminUserController routes)
  static const String staticData = '/admin/static-data';
  static const String createAdmin = '/admin/crud/create-admin';
  static const String getAdminList = '/admin/crud/get-user-list';
  static const String updateIsActiveAdmin = '/admin/crud/update-is-active-user';
  static String getAdminById(String id) => '/admin/crud/get-a-user/$id';
  static String updateAdmin(String id) => '/admin/crud/update-admin/$id';
  static String deleteAdmin(String id) => '/admin/crud/delete-admin/$id';

  // Godown CRUD (matches backend GodownController routes)
  static const String createGodown = '/admin/godown/create';
  static const String getGodownList = '/admin/godown/get-godown-list';
  static const String updateIsActiveGodown = '/admin/godown/update-is-active';
  static const String eligibleGodownAdmins = '/admin/godown/eligible-admins';
  static String getGodownById(String id) => '/admin/godown/get-a-godown/$id';
  static String updateGodown(String id) => '/admin/godown/update/$id';
  static String deleteGodown(String id) => '/admin/godown/delete/$id';
}
