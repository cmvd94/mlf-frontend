class HsnCodeEntity {
  final String id;
  final String hsnCode;
  final String description;
  final double gstRate;
  final bool isActive;
  final DateTime? createdAt;

  const HsnCodeEntity({
    required this.id,
    required this.hsnCode,
    this.description = '',
    this.gstRate = 5.0,
    this.isActive = true,
    this.createdAt,
  });
}
