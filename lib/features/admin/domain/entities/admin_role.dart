enum AdminRole {
  superAdmin('SUPER_ADMIN', 'Super Admin'),
  generalManager('GENERAL_MANAGER', 'General Manager'),
  zoneHead('ZONE_HEAD', 'Zone Head'),
  regionalManager('REGIONAL_MANAGER', 'Regional Manager'),
  districtManager('DISTRICT_MANAGER', 'District Manager'),
  godownManager('GODOWN_MANAGER', 'Godown Manager'),
  supervisor('SUPERVISOR', 'Supervisor'),
  assistant('ASSISTANT', 'Assistant'),
  billingUser('BILLING_USER', 'Billing User');

  final String value;
  final String label;

  const AdminRole(this.value, this.label);

  static AdminRole fromString(String? role) {
    if (role == null) return AdminRole.billingUser;
    for (final r in AdminRole.values) {
      if (r.value.toUpperCase() == role.toUpperCase()) {
        return r;
      }
    }
    return AdminRole.billingUser;
  }

  /// List of roles that can be created/selected in dropdown (excludes superAdmin)
  static List<AdminRole> get selectableRoles => [
        AdminRole.generalManager,
        AdminRole.zoneHead,
        AdminRole.regionalManager,
        AdminRole.districtManager,
        AdminRole.godownManager,
        AdminRole.supervisor,
        AdminRole.assistant,
        AdminRole.billingUser,
      ];
}
