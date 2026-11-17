class AccessScopeEntity {
  final String? country;
  final String? zone;
  final String? state;
  final String? district;
  final List<String>? pincode;

  const AccessScopeEntity({
    this.country,
    this.zone,
    this.state,
    this.district,
    this.pincode,
  });

  bool get isEmpty =>
      (country == null || country!.isEmpty) &&
      (zone == null || zone!.isEmpty) &&
      (state == null || state!.isEmpty) &&
      (district == null || district!.isEmpty);

  bool get isGlobal => isEmpty;

  /// Returns a clean hierarchical breadcrumb string:
  /// e.g. "India > SouthZone > TamilNadu > Coimbatore" or "Global (All Regions)"
  String get displayString {
    if (isEmpty) return 'Global (All Regions)';
    final parts = [country, zone, state, district]
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    return parts.join(' > ');
  }

  /// Compact single-line label for tables
  String get shortSummary {
    if (isEmpty) return 'Global';
    if (district != null && district!.isNotEmpty) {
      return '$district ($state)';
    }
    if (state != null && state!.isNotEmpty) {
      return '$state ($zone)';
    }
    if (zone != null && zone!.isNotEmpty) {
      return '$zone ($country)';
    }
    return country ?? 'Global';
  }

  AccessScopeEntity copyWith({
    String? country,
    String? zone,
    String? state,
    String? district,
    List<String>? pincode,
  }) {
    return AccessScopeEntity(
      country: country ?? this.country,
      zone: zone ?? this.zone,
      state: state ?? this.state,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessScopeEntity &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          zone == other.zone &&
          state == other.state &&
          district == other.district;

  @override
  int get hashCode =>
      country.hashCode ^ zone.hashCode ^ state.hashCode ^ district.hashCode;
}
