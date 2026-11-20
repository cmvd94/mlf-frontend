import '../../domain/entities/available_stock_entity.dart';

class AvailableStockModel extends AvailableStockEntity {
  const AvailableStockModel({
    required super.godownStockId,
    required super.godownId,
    required super.godownName,
    super.godownCode,
    required super.itemId,
    required super.itemName,
    super.itemCode,
    super.batchNo,
    required super.currentStock,
    super.rate,
    super.amount,
    super.uomId,
    super.uomName,
    super.uomSymbol,
    super.uomQuantity,
    super.perId,
    super.perMultiplier,
  });

  factory AvailableStockModel.fromJson(Map<String, dynamic> json) {
    return AvailableStockModel(
      godownStockId: (json['godownStockId'] ?? json['_id'] ?? '').toString(),
      godownId: (json['godownId'] ?? '').toString(),
      godownName: (json['godownName'] ?? 'Unknown Godown').toString(),
      godownCode: (json['godownCode'] ?? '').toString(),
      itemId: (json['itemId'] ?? '').toString(),
      itemName: (json['itemName'] ?? 'Unknown Item').toString(),
      itemCode: (json['itemCode'] ?? '').toString(),
      batchNo: (json['batchNo'] ?? '').toString(),
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      uomId: (json['uomId'] ?? '').toString(),
      uomName: (json['uomName'] ?? '').toString(),
      uomSymbol: (json['uomSymbol'] ?? '').toString(),
      uomQuantity: (json['uomQuantity'] as num?)?.toDouble() ?? 1.0,
      perId: (json['perId'] ?? '').toString(),
      perMultiplier: (json['perMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
