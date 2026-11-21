class AvailableStockEntity {
  final String godownStockId;
  final String godownId;
  final String godownName;
  final String godownCode;
  final String companyGodownId;
  final String companyGodownName;
  final String companyGodownCode;
  final String itemId;
  final String itemName;
  final String itemCode;
  final String batchNo;
  final double currentStock;
  final double rate;
  final double amount;
  final String uomId;
  final String uomName;
  final String uomSymbol;
  final double uomQuantity;
  final String perId;
  final double perMultiplier;

  const AvailableStockEntity({
    required this.godownStockId,
    required this.godownId,
    required this.godownName,
    this.godownCode = '',
    this.companyGodownId = '',
    this.companyGodownName = '',
    this.companyGodownCode = '',
    required this.itemId,
    required this.itemName,
    this.itemCode = '',
    this.batchNo = '',
    required this.currentStock,
    this.rate = 0.0,
    this.amount = 0.0,
    this.uomId = '',
    this.uomName = '',
    this.uomSymbol = '',
    this.uomQuantity = 1.0,
    this.perId = '',
    this.perMultiplier = 1.0,
  });

  String get displayName =>
      '$itemName ${batchNo.isNotEmpty ? "[$batchNo]" : ""} - $godownName${companyGodownName.isNotEmpty && companyGodownName != godownName ? " (Owner: $companyGodownName)" : ""} (Stock: $currentStock ${uomSymbol.isNotEmpty ? uomSymbol : ""})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableStockEntity &&
          runtimeType == other.runtimeType &&
          godownStockId == other.godownStockId;

  @override
  int get hashCode => godownStockId.hashCode;
}
