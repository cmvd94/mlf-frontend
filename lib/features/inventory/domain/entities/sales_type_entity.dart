class SalesTypeEntity {
  final String id;
  final String name;
  final String code;
  final String description;
  final bool isActive;
  final DateTime? createdAt;

  const SalesTypeEntity({
    required this.id,
    required this.name,
    this.code = '',
    this.description = '',
    this.isActive = true,
    this.createdAt,
  });
}
