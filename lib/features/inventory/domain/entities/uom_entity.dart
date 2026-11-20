class UomEntity {
  final String id;
  final String name;
  final String symbol;
  final String description;
  final bool isActive;
  final DateTime? createdAt;

  const UomEntity({
    required this.id,
    required this.name,
    required this.symbol,
    this.description = '',
    this.isActive = true,
    this.createdAt,
  });
}
