class PerUnitEntity {
  final String id;
  final String name;
  final String symbol;
  final double multiplier;
  final String description;
  final bool isActive;
  final DateTime? createdAt;

  const PerUnitEntity({
    required this.id,
    required this.name,
    required this.symbol,
    this.multiplier = 1.0,
    this.description = '',
    this.isActive = true,
    this.createdAt,
  });
}
