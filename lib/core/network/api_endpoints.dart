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

  // Account & Inventory Masters
  static const String masters = '/admin/account-inventory/masters';
  
  static const String createParty = '/admin/account-inventory/party/create';
  static const String getPartyList = '/admin/account-inventory/party/list';
  static String updateParty(String id) => '/admin/account-inventory/party/update/$id';
  static String deleteParty(String id) => '/admin/account-inventory/party/delete/$id';

  static const String createPurchaseType = '/admin/account-inventory/purchase-type/create';
  static const String getPurchaseTypeList = '/admin/account-inventory/purchase-type/list';
  static String updatePurchaseType(String id) => '/admin/account-inventory/purchase-type/update/$id';
  static String deletePurchaseType(String id) => '/admin/account-inventory/purchase-type/delete/$id';

  static const String createUom = '/admin/account-inventory/uom/create';
  static const String getUomList = '/admin/account-inventory/uom/list';
  static String updateUom(String id) => '/admin/account-inventory/uom/update/$id';
  static String deleteUom(String id) => '/admin/account-inventory/uom/delete/$id';

  static const String createPerUnit = '/admin/account-inventory/per-unit/create';
  static const String getPerUnitList = '/admin/account-inventory/per-unit/list';
  static String updatePerUnit(String id) => '/admin/account-inventory/per-unit/update/$id';
  static String deletePerUnit(String id) => '/admin/account-inventory/per-unit/delete/$id';

  static const String createItemGroup = '/admin/account-inventory/item-group/create';
  static const String getItemGroupList = '/admin/account-inventory/item-group/list';
  static String updateItemGroup(String id) => '/admin/account-inventory/item-group/update/$id';
  static String deleteItemGroup(String id) => '/admin/account-inventory/item-group/delete/$id';

  static const String createItem = '/admin/account-inventory/item/create';
  static const String getItemList = '/admin/account-inventory/item/list';
  static String updateItem(String id) => '/admin/account-inventory/item/update/$id';
  static String deleteItem(String id) => '/admin/account-inventory/item/delete/$id';

  // Purchase Entries
  static const String createPurchase = '/admin/purchase/create';
  static const String getPurchaseList = '/admin/purchase/list';
  static String getPurchaseById(String id) => '/admin/purchase/get-a-purchase/$id';
  static String updatePurchase(String id) => '/admin/purchase/update/$id';
  static String deletePurchase(String id) => '/admin/purchase/delete/$id';

  // Stock Summary (Tally Stock View)
  static const String stockSummary = '/admin/stock-summary';
  static String groupStockSummary(String groupId) => '/admin/stock-summary/group/$groupId';
}
