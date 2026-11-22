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
  final String dcNo;
  final String lotNo;
  String get batchNo => dcNo;
  final double currentStock;
  final double rate;
  final double amount;
  final String uomId;
  final String uomName;
  final String uomSymbol;
  final double uomQuantity;
  final String perId;
  final String perName;
  final String perSymbol;
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
    String dcNo = '',
    this.lotNo = '',
    String batchNo = '',
    required this.currentStock,
    this.rate = 0.0,
    this.amount = 0.0,
    this.uomId = '',
    this.uomName = '',
    this.uomSymbol = '',
    this.uomQuantity = 1.0,
    this.perId = '',
    this.perName = '',
    this.perSymbol = '',
    this.perMultiplier = 1.0,
  }) : dcNo = dcNo != '' ? dcNo : batchNo;

  String get displayName {
    final refParts = [
      if (dcNo.isNotEmpty) 'DC: $dcNo',
      if (lotNo.isNotEmpty) 'Lot: $lotNo',
    ];
    final refStr = refParts.isNotEmpty
        ? ' [${refParts.join(", ")}]'
        : (batchNo.isNotEmpty ? ' [$batchNo]' : '');

    final uomPart = uomQuantity > 0 && uomSymbol.isNotEmpty
        ? '${uomQuantity.toStringAsFixed(uomQuantity.truncateToDouble() == uomQuantity ? 0 : 2)} $uomSymbol'
        : '';
    final qtyPart = '${currentStock.toStringAsFixed(currentStock.truncateToDouble() == currentStock ? 0 : 2)} ${perSymbol.isNotEmpty ? perSymbol : ''}'.trim();
    final stockInfo = uomPart.isNotEmpty ? '$uomPart | $qtyPart' : qtyPart;

    return '$itemName$refStr - $godownName${companyGodownName.isNotEmpty && companyGodownName != godownName ? " (Owner: $companyGodownName)" : ""} (Stock: $stockInfo)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableStockEntity &&
          runtimeType == other.runtimeType &&
          godownStockId == other.godownStockId;

  @override
  int get hashCode => godownStockId.hashCode;
}
